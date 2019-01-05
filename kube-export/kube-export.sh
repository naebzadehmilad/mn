#!/bin/sh

kubexport()
{

datetime=$(date +%Y_%m_%d_%H%M)
while read line ; do
  if [[ $line = modu* ]] ; then
     echo $line > .module.tmp
  fi
  if [[ $line = namespac* ]] ; then
     echo $line > .namespace.tmp
  fi
  if [[ $line = minutes* ]] ; then
    echo $line > .minutes.tmp
  fi
  if [[ $line = keepbackup* ]] ; then
    echo $line > .keepbackup.tmp
  fi
  if [[ $line = KUBE-CA* ]] ; then
    echo $line > .ca.tmp
  fi
done < /opt/config/export.conf


   mkdir save ; mkdir export

sed -i -e 's/module=//g  ;  s/,/\n/g  ;  s/ /\n/g ' .module.tmp
sed -i -e 's/namespaces=//g  ;  s/,/\n/g  ;  s/ /\n/g ' .namespace.tmp
sed -i -e 's/minutes=//g  ;  s/,/\n/g  ;  s/ /\n/g ' .minutes.tmp
sed -i -e 's/keepbackup(days)=//g  ;  s/,/\n/g  ;  s/ /\n/g ' .keepbackup.tmp
sed -i -e 's/KUBE-CA-PATH=//g  ;  s/,/\n/g  ;  s/ /\n/g ' .ca.tmp

while read line ; do
  module[a++]=$line
done < .module.tmp

while read line ; do
  namespace[b++]=$line
done < .namespace.tmp

while read line ; do
  minutes=$line
done < .minutes.tmp

while read line ; do
  keepbackup=$line
done < .keepbackup.tmp

while read line ; do
  ca=$line
done < .ca.tmp

export KUBECONFIG=`echo $ca`

kubectl get namespace | awk '{if (NR!=1)print $1}' > .allnamespace.tmp



while read line ; do
  allnamespace[c++]=$line
done < .allnamespace.tmp


allname=`echo ${#allnamespace[*]}`
nspace=`echo ${#namespace[*]}`
modulecount=`echo ${#module[*]}`

if [ $namespace = "all"  ] ||  [ $namespace = "All" ] ; then

for((i=0;$i<$allname;i++)) ; do
  for((j=0;$j<$modulecount;j++)) ; do
    kubectl get ${module[$j]} -n ${allnamespace[$i]} | awk '{if (NR!=1)print $1}'  > save/${module[$j]}-${allnamespace[$i]}.yml
      while read line ; do
          if [ ! -d export/${allnamespace[$i]}/${module[$j]}  ] ; then
            mkdir -p  export/${allnamespace[$i]}/${module[$j]}
          fi
          kubectl get ${module[$j]} $line -n ${allnamespace[$i]} -o yaml --export >  export/${allnamespace[$i]}/${module[$j]}/$line-${module[$j]}-${allnamespace[$i]}-$datetime.yml
          find .   -type f -name *.tar -mtime +$keepbackup -exec rm -rf {} \;
      done < save/${module[$j]}-${allnamespace[$i]}.yml
done
done

else
for((i=0;$i<$nspace;i++)) ; do
  for((j=0;$j<$modulecount;j++)) ; do
    kubectl get ${module[$j]} -n ${namespace[$i]} | awk '{if (NR!=1)print $1}'  > save/${module[$j]}-${namespace[$i]}.yml
      while read line ; do
          if [ ! -d export/${namespace[$i]}/${module[$j]}  ] ; then
            mkdir -p  export/${namespace[$i]}/${module[$j]}
          fi
          kubectl get ${module[$j]} $line -n ${namespace[$i]} -o yaml --export >  export/${namespace[$i]}/${module[$j]}/$line-${module[$j]}-${namespace[$i]}-$datetime.yml
          find .   -type f  -name *.tar -mtime +$keepbackup -exec rm -rf {} \;
          tar -cvf export/${namespace[$i]}-$datetime.tar export/${namespace[$i]}/
      done < save/${module[$j]}-${namespace[$i]}.yml
done
done

fi

}

while true; do
  kubexport
   sleep $((minutes))m
  tar -cvf  export/export-$datetime.tar export
done

