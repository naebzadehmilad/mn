#!/bin/bash
ip_db_stg=172.16.90.80
ip_db_prod=172.16.90.82
user=app
export PGPASSWORD=""
TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`

stime=`date +%m`

#http://172.16.90.120:30121/seasons/items/1/reindex

cconf(){
echo -en "DB&NODEPORT=\nMODULE-Table=\n" > reindex.conf
}

while read -r line ; do
 if [[ $line == DB* ]] ; then
   echo $line > .DB.tmp
 else
   echo $line > .MODULE.tmp
 fi
done < reindex.conf

sed -ie "s/,/\n/g ; s/ /\n/g ; " .IPPORT.tmp .DB.tmp .MODULE.tmp
sed -ie "s/DB-NODEPORT=// ;  s/IPPORT=// ; s/MODULE-Table=//; " .IPPORT.tmp .DB.tmp .MODULE.tmp
########cut nodport & tablesname
sed -i 's/;/ /' .DB.tmp ; cut -d ' ' -f2 .DB.tmp > .SVC.tmp ; sed -i -r 's/\S+//2' .DB.tmp


while read -r line ; do
modulecount=$(($modulecount+1))
module[$modulecount]=$line
done < .MODULE.tmp

while read -r line ; do
ipportcount=$(($ipportcount+1))
ipport[$ipportcount]=$line
done < .SVC.tmp

while read -r line ; do
dbcount=$(($dbcount+1))
db[$dbcount]=$line
done < .DB.tmp

index=1
for ((j=1;j<=$dbcount;j++))  ;do 
  for ((modulec=1;modulec<=$modulecount;modulec++)) ;do 
    for i in  `psql -h  $ip_db_prod  -d ${db[$j]}  -U app -w  -c "select id from ${module[$modulec]}  "|  awk '{ print $1}' | sed  -e "s/------// ; s/count// ; s/id//; s/(// ; s/-----//" ` 
   do 
     if [[ ${module[$modulec]} = videos  ]] |  [[ ${module[$modulec]} = seasons  ]]  ; then
      modulee=`echo ${module[$modulec]} |  sed '$s/.$//' ` ###delete last word
    else 
    modulee=`echo ${module[$modulec]}`
     fi
       
url=`   echo curl   -IXPOST http://${ipport[$j]}/$modulee/items/$i/reindex | parallel  --no-notice -j50 -N255  | awk 'NR==1{print $2}'    ` ; echo $url  ${module[$modulec]} item:$i ${db[$j]} $TIMESTAMP     >>logs.txt 
done
 done
done
etime=`date +%m`
showtime=$(($etime-$stime)) 
echo $showtime

