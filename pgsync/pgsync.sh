#!/bin/bash
ip_db_stg=172.16.120.80
ip_db_prod=172.16.120.82
user=app
export PGPASSWORD=""
stime=`date +%S`
time=`date +%Y:%m:%d-TIME:%H`

black() { echo -en "$(tput setaf 0)$*$(tput setaf 9)"; }
red() { echo -en "$(tput setaf 1)$*$(tput setaf 9)"; }
green() { echo -en "$(tput setaf 2)$*$(tput setaf 9)"; }
yellow() { echo -en "$(tput setaf 3)$*$(tput setaf 9)"; }
blue() { echo -en "$(tput setaf 4)$*$(tput setaf 9)"; }
white() { echo -en "$(tput setaf 7)$*$(tput setaf 9)"; }

checkenv(){
if [ -z "$1" ] ; then 
echo -en "\nplease enter database STG && check pgsync.new.conf \n >>>>>>Example:  ./pgsync.new myapps_stg \n"
exit 
fi
}
finish(){
echo -en "\n #############Replace complete!! ------ DONE############ \n"
}
if [ ! -d tmp ] ; then 
mkdir tmp ; fi  
cconf(){
echo -en "copy=\nsynctc=\ntables=album_artist,album_cover,album_genre,album_tag,albums,android_genre,android_permissions,android_recentchanges,android_screenshot,android_tag,android_trailer,android_version_update,androidapps,bundle_content,bundles,categories,comments,companies,contents,countries,family_share,generic_files,groups,ios_files,iosapps,iosapps_genre,iosapps_permissions,iosapps_screenshot,iosapps_tag,iosapps_trailer,langs,music_artist,music_cover,music_downloads,music_genre,music_tag,musics,permissions,persons,picture_files,playlist_items,playlists,radiochannel_epg,radiochannel_tag,radiochannels,recentchanges,season_cast,season_genre,genres,season_screenshot,season_tag,season_trailer,seasons,series,series_cast,series_genre,series_tag,similar_video,stars,tags,tags_filter,translates,tvchannel_epg,tvchannel_tag,tvchannels,video_cast,video_country,video_director,video_genre,video_screenshot,video_subtitle,video_tag,video_trailer,video_writer,videos,subscriptions  " >pgsync.new.conf
}



befordump(){


######sequances select
#psql -A -h  $ip_db_stg  -d myappsv2_api  -U app -w -c " select  sequence_name from information_schema.sequences;" >  tmp/seq.txt  ;  
cat sequence.txt  > tmp/seq.txt 
sed -ie "s/,/\n/g " tmp/seq.txt
indexi=0
while read  -r line ; do
  indexi=$(($indexi+1))
  seq[$indexi]=$line 
done < tmp/seq.txt
clear ; 
}

#############before dump system messages ###sys_message fa title
selectpg(){
psql -A -h  $ip_db_stg  -d $1  -U app -w -c " select translates.text ,system_messages.id  , system_messages.key ,  componentid , languageid   
from translates join system_messages on translates.entryid = system_messages.translateentryid
where translates.componentid=1 and translates.languageid=1" > .system_messagesfa.tmp
awk  -F\| '{ print $1 }' .system_messagesfa.tmp > tmp/system_messages_title_fa.tmp ; awk  -F\| '{ print $3 }' .system_messagesfa.tmp > tmp/system_messages_title_key_fa.tmp 
sed -ie '/^$/d;/^(.*/d ; /^text.*/d  ; /^key.*/d ; /^lang.*/d ; /^comp.*/d '  tmp/system_messages_title_key_fa.tmp tmp/system_messages_title_fa.tmp 


############select urlapk download
apkurl=`psql -A -h  $ip_db_stg  -d $1  -U app -w -c " select apkurl from settings where id=1 " | sed -e 's/apkurl//;/^$/d;/^(.*/d'  ` 

####Select translate entry id
psql -A -h  $ip_db_stg   -d $1  -U app -w -c " select translateentryid from settings" > tmp/.selecttranslateid.tmp
sed -ie '/^$/d;/^($*/d ; /^text.*/d  ; /^translate.*/d; /^id/d' tmp/.selecttranslateid.tmp

#####sys_mesages_about_fa

psql -A -h  $ip_db_stg  -d $1  -U app -w -c " select translates.text ,system_messages.id  , system_messages.key ,  componentid , languageid
from translates join system_messages on translates.entryid = system_messages.translateentryid
where translates.componentid=2 and translates.languageid=1" > .system_messages_step2.tmp
awk  -F\| '{ print $1 }' .system_messages.tmp > tmp/system_messages_about_fa.tmp ; awk  -F\| '{ print $3 }' .system_messages.tmp > tmp/system_messages_about_key_fa.tmp
sed -ie '/^$/d;/^(.*/d ; /^text.*/d  ; /^key.*/d ; /^lang.*/d ; /^comp.*/d '  tmp/system_messages_about_key_fa.tmp tmp/system_messages_about_fa.tmp 


####sys_message_title)en
psql -A -h  $ip_db_stg  -d $1  -U app -w -c " select translates.text ,system_messages.id  , system_messages.key ,  componentid , languageid
from translates join system_messages on translates.entryid = system_messages.translateentryid
where translates.componentid=1 and translates.languageid=2" > .system_messages_en.tmp
awk  -F\| '{ print $1 }' .system_messages_en.tmp > tmp/system_messages_title_en.tmp ; awk  -F\| '{ print $3 }' .system_messages_en.tmp > tmp/system_messages_title_key_en.tmp
sed -ie '/^$/d;/^(.*/d ; /^text.*/d  ; /^key.*/d ; /^lang.*/d ; /^comp.*/d '  tmp/system_messages_title_en.tmp tmp/system_messages_title_key_en.tmp 

#####sys_message_about)en
psql -A -h  $ip_db_stg  -d $1  -U app -w -c " select translates.text ,system_messages.id  , system_messages.key ,  componentid , languageid
from translates join system_messages on translates.entryid = system_messages.translateentryid
where translates.componentid=2 and translates.languageid=2" > .system_messages_step2_en.tmp
awk  -F\| '{ print $1 }' .system_messages_step2_en.tmp > tmp/system_messages_about_en.tmp ; awk  -F\| '{ print $3 }' .system_messages_step2_en.tmp > tmp/system_messages_about_key_en.tmp
sed -ie '/^$/d;/^(.*/d ; /^text.*/d  ; /^key.*/d ; /^lang.*/d ; /^comp.*/d '  tmp/system_messages_about_key_en.tmp tmp/system_messages_about_en.tmp


#####subscriptions
#psql -A -h  $ip_db_stg  -d $1  -U app -w -c "SELECT translates.text, subscriptions.id,languageid  ,namecompid FROM translates join subscriptions on translates.entryid = subscriptions.translateentryid ; " > tmp/.subscriptions.tmp 
#awk  -F\| '{ print $1 }' tmp/.subscriptions.tmp > tmp/subscriptions_text.tmp ; 
#awk  -F\| '{ print $2 }' tmp/.subscriptions.tmp > tmp/subscriptions_id.tmp 
#awk  -F\| '{ print $3 }' tmp/.subscriptions.tmp > tmp/subscriptions_langid.tmp ; 
#awk  -F\| '{ print $4 }' tmp/.subscriptions.tmp > tmp/subscriptions_compnamid.tmp 
#sed -ie '/^$/d;/^(.*/d ; /^text.*/d  ; /^key.*/d; /^id.*/d;/^lang.*/d ; /^name.*/d'  tmp/subscriptions_text.tmp tmp/subscriptions_id.tmp tmp/subscriptions_langid.tmp tmp/subscriptions_compnamid.tmp


####settings

psql -A -h  $ip_db_stg   -d $1  -U app -w -c  "select translates.text,componentid,languageid  from translates join settings on translates.entryid = settings.translateentryid" > tmp/.Settings.tmp
sed -ie '/^$/d;/^($*/d ; /^text.*/d  ; /^translate.*/d; /^id/d ' tmp/.Settings.tmp
awk  -F\| '{ print $1 }' tmp/.Settings.tmp > tmp/.text.tmp ; awk  -F\| '{ print $2 }' tmp/.Settings.tmp > tmp/.componnentid.tmp ; awk  -F\| '{ print $3 }' tmp/.Settings.tmp > tmp/.langid.tmp
sed -ie '/^$/d;/^(.*/d ; /^text.*/d  ; /^key.*/d; /^id.*/d;/^lang.*/d ; /^name.*/d' tmp/.componnentid.tmp tmp/.langid.tmp tmp/.text.tmp 
}



dump(){
cat pgsync.new.conf > tmp/.temp  ;
while read  -r line ; do
if [[ $line == copy* ]]  ; then 
  echo $line > .DB.tmp
fi
if [[ $line == sync* ]] ; then 
  echo $line > .syncto.tmp
fi
if [[ $line == table* ]] ; then 
  echo $line > .table.tmp
fi
done < tmp/.temp

sed -i "s/copy=//g ; s/syncto=//g ; s/tables=//g ;  " .table.tmp .syncto.tmp .DB.tmp
sed -i "  s/,/\n -t /g ; 1s/^/ -t /   " .table.tmp 
sed -i "  s/,/\n -d /g ; 1s/^/-d / "  .syncto.tmp 
sed -i "  s/,/\n -d /g ; 1s/^/-d / "   .DB.tmp

tableindex=0
#### table to array
while read  -r line ; do
  tableindex=$(($tableindex+1))
  tables[$tableindex]=$line 
done <.table.tmp

tablecount=${#tables[@]}
#DB to array
 while read  -r line ; do
  dbindex=$(($dbindex+1))
  dbname=$line
done <.DB.tmp

###############sys_messages


index=0
while read line ; do
   index=$((index+1))
   sys_title_key_fa[$index]=$line
done < tmp/system_messages_title_key_fa.tmp
index=0
count_title_key_fa=${#sys_title_key_fa[@]}

index=0
while read line ; do
   index=$((index+1))
   sys_title_fa[$index]=$line
done < tmp/system_messages_title_fa.tmp
count_title_fa=${#sys_title_fa[@]}

index=0
while read line ; do
   index=$((index+1))
   sys_about_fa[$index]=$line
done < tmp/system_messages_about_fa.tmp

index=0
while read line ; do
   index=$((index+1))
   sys_about_key_fa[$index]=$line
done < tmp/system_messages_about_key_fa.tmp
count_about_key_fa=${#sys_about_key_fa[@]}

### array_title_en
index=0
while read line ; do
   index=$((index+1))
   sys_title_en[$index]=$line
#  echo ${sys_title_en[$index]} ; sleep 3 
done < tmp/system_messages_title_en.tmp 
count_title_en=${#sys_title_en[@]}

index=0
while read line ; do
   index=$((index+1))
   sys_title_key_en[$index]=$line
#  echo  ${sys_title_key_en[$index]}; sleep 3
done < tmp/system_messages_title_key_en.tmp

index=0
while read line ; do
   index=$((index+1))
   sys_about_key_en[$index]=$line
#echo "${sys_about_key_en[$index]}"; sleep 45
done < tmp/system_messages_about_en.tmp


################################################################################
###########subscriptions
#index=0
#while read line ; do
#   index=$((index+1))
#   langid[$index]=$line
#done < tmp/subscriptions_langid.tmp 

#index1=0
#while read line ; do
 #  index1=$((index1+1))
 #  textnew[$index1]=$line
 # echo text new  ${textnew[$index1]} ; 
#done < tmp/subscriptions_text.tmp

#index1=0
#while read line ; do
#   index1=$((index1+1))
#   id[$index1]=$line
#done <  tmp/subscriptions_id.tmp


#index=0
#while read line ; do
#index=$((index+1))
#comid[$index]=$line
#done <  tmp/subscriptions_compnamid.tmp


while read line ; do
   selecttranslateid_dbname=$line
done <  tmp/.selecttranslateid.tmp

# count_subscriptions=${#comid[@]}  ##count subs

###########settings
index=0
while read line ; do
index=$((index+1))
text_com[$index]=$line
done <  tmp/.text.tmp

index=0
while read line ; do
index=$((index+1))
componnentid[$index]=$line
done <  tmp/.componnentid.tmp


index=0
while read line ; do
index=$((index+1))
settinglang[$index]=$line
done < tmp/.langid.tmp


count_settings=${#componnentid[@]}
echo ${#text_com[@]} ;
echo ${#count_settings[@]} ; 
echo ${#sys_langid[@]} 
echo ${#componnentid[@]};  
 count_system_messages=${#sys_comid[@]} ###count system_mess
#echo $count_subscriptions ........... ;    

clear ; green "stg1---backup $1  and drop sequence " ; sleep 3 
pg_dump  -v -h $ip_db_stg -d $1 -Uapp -w > /repo/prod/pgsync/stg-dump/$1                        ###### 1.backup and drop sequence 

if [ $? != 0 ] ; then  
exit 1  
else 
clear
 green "\n stg1----backup source $1 ------------- ok \n"
sleep 2 ;
##drop sequence
clear ; green "DROP SEQUENCE..." ; sleep 3 ;
for ((i=0;i<=$indexi;i++)) ; do
   green " DROP SEQUENCE ${seq[$i]} " ;
   psql -h  $ip_db_stg  -d $1  -U app -w  -c "DROP SEQUENCE  IF EXISTS  ${seq[$i]} cascade ;"
done
sleep 3; 
 fi                                                     
dbnamed=`echo $dbname | sed ' s/-d// ' `                              
sed -ie '/^$/d;/^($*/d ; /^text.*/d  ; /^translate.*/d; /^id/d' tmp/.selecttranslateid.tmp
echo  ............dump...../repo/prod/dump/$dbname..................................
pg_dump  -v -h $ip_db_prod $dbname  ${tables[@]} -Uapp -w > /repo/prod/pgsync/prod-dump/`echo $dbnamed`.`echo $time`.dump          ###### 2.backup for replace                                                                                         
if [ $? != 0 ] ; then
exit 1
else
clear
 echo -en "\n stg2---backup for replace--$dbnamed\n   " ; sleep 2
fi

if [ $? = 0 ] ; then                                                                        ###### 3. check exist backup and drop 

  for ((i=0;i<=tablecount;i++)) ; do 
  tablest=`echo ${tables[$i]} | sed 's/-t//'`
   psql -h  $ip_db_stg  -d $1  -U app -w -c "DROP TABLE IF EXISTS  $tablest  cascade; "
 green "\n stg3---Drop table $tablest \n"
 done

else 
exit 1
fi
if [ $? = 0 ] ; then
clear ; green "\n stg4--- replacebackup to $1 done \n"
echo " dbanme $dbnamed   replace to  $1 "
sleep 3
psql -h  $ip_db_stg  -d $1   -U app -w < /repo/prod/pgsync/prod-dump/`echo $dbnamed`.`echo $time`.dump           ###### 4.replace backup
else
 exit 1 ; 
fi


###sequence dump
pg_dump  -v -h $ip_db_prod -d $dbnamed  -Uapp -w  -t album_artist_id_seq -t album_cover_id_seq -t album_genre_id_seq -t album_tag_id_seq -t albums_id_seq -t android_genre_id_seq -t android_permissions_id_seq -t android_recentchanges_id_seq -t android_screenshot_id_seq -t android_tag_id_seq -t android_trailer_id_seq -t android_version_update_id_seq -t androidapps_id_seq -t bundle_content_id_seq -t bundles_id_seq -t categories_id_seq -t comments_id_seq -t companies_id_seq -t contents_id_seq -t countries_id_seq -t cps_id_seq -t deliver_files_id_seq -t family_share_id_seq -t favorites_id_seq -t filenameseq -t generic_files_id_seq -t groups_id_seq -t ios_files_id_seq -t iosapps_genre_id_seq -t iosapps_id_seq -t iosapps_permissions_id_seq -t iosapps_screenshot_id_seq -t iosapps_tag_id_seq -t iosapps_trailer_id_seq -t langs_id_seq -t music_artist_id_seq -t music_cover_id_seq -t music_downloads_id_seq -t music_genre_id_seq -t music_tag_id_seq -t musics_id_seq -t orderid -t permissions_id_seq -t persons_id_seq -t picture_files_id_seq -t playlist_items_id_seq -t playlists_id_seq -t radiochannel_epg_id_seq -t radiochannel_tag_id_seq -t radiochannels_id_seq -t recentchanges_id_seq -t renewpay_logs_id_seq -t season_cast_id_seq -t season_genre_id_seq -t season_screenshot_id_seq -t season_tag_id_seq -t season_trailer_id_seq -t seasons_id_seq -t sellableid -t series_cast_id_seq -t series_genre_id_seq -t series_id_seq -t series_tag_id_seq -t similar_video_id_seq -t stars_id_seq -t tags_filter_id_seq -t tags_id_seq -t translateentry -t translates_id_seq -t tvchannel_epg_id_seq -t tvchannel_tag_id_seq -t tvchannels_id_seq -t video_cast_id_seq -t video_country_id_seq -t video_director_id_seq -t video_genre_id_seq -t video_screenshot_id_seq -t  video_subtitle_id_seq -t video_tag_id_seq -t video_trailer_id_seq -t video_writer_id_seq -t videos_id_seq -t subscriptions_id_seq > /repo/prod/pgsync/sequence.$time.dump ;



######################after dump

psql -h  $ip_db_stg  -d $1 -U app -w -c " update settings set translateentryid=$selecttranslateid_dbname "
echo check ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, ;sleep 3 
for (( j=1;j<=$count_title_key_fa;j++ )) ; do
    ##updata title key fa  & title
  psql -h  $ip_db_stg  -d $1 -U app -w -c "update translates set text='${sys_title_fa[$j]}' where entryid = (select translateentryid from system_messages where key = '${sys_title_key_fa[$j]}') and componentid = 1 and languageid = 1 " 
done

for (( k=1;k<=$count_about_key_fa;k++ )) ; do
    ##update about key and about fa
  psql -h  $ip_db_stg  -d $1 -U app -w -c "update translates set text='${sys_about_fa[$k]}' where entryid = (select translateentryid from system_messages where key = '${sys_about_key_fa[$k]}') and componentid = 2 and languageid = 1 "
done


for ((l=1;l<=$count_title_en;l++)) ; do
    ##update title  key and title en
    psql -h  $ip_db_stg  -d $1 -U app -w -c "update translates set text='${sys_title_en[$l]}' where entryid = (select translateentryid from system_messages where key = '${sys_title_key_en[$l]}') and componentid = 1 and languageid = 2 "
echo ${sys_title_en[$l]} .     ..........               .      .
done

for ((m=1;m<=$count_title_en;m++)) ; do
    ##update title  key and title en
    psql -h  $ip_db_stg  -d $1 -U app -w -c "update translates set text='${sys_about_en[$m]}' where entryid = (select translateentryid from system_messages where key = '${sys_about_key_en[$m]}') and componentid = 2 and languageid = 2 "
done




#  for (( i=1;i<=$count_subscriptions;i++ )) ; do
 #        psql -h  $ip_db_stg  -d $1 -U app -w -c  "insert into translates (entryid, namecompid, languageid, text)
  #       values
   #       ((select max(entryid)+1 from translates),${comid[$i]},${langid[$i]},'${textnew[$i]}'); 
    #       update subscriptions set translateentryid = (select max(entryid) from translates) where id = ${id[$i]} "
 #echo componentid ${comid[$i]} --------- langid--------------- ${langid[$i]}  text------------- ${textnew[$i]} id-------------  ${id[$i]}   ///////////////////////////////// 
#done


    for (( c=1;c<=$count_settings;c++ )) ;  do
            psql -h $ip_db_stg -d $1 -U app -w -c " update translates set text= '${text_com[$c]}' where entryid= $selecttranslateid_dbname and  componentid= ${componnentid[$c]} and languageid = ${settinglang[$c]} "
done




#####update apkrul
psql -h $ip_db_stg -d $1 -U app -w -c " update settings set apkurl = '$apkurl' "

###sequence replace
clear ; 
green " replace sequence to $1 \n" ; sleep 2 
psql -h $ip_db_stg -d $1 -U app -w < /repo/prod/pgsync/sequence.$time.dump 

#############package subscription update

}
checkenv $1
selectpg $1
befordump $1
dump $1 
rm tmp/seq* 
end=`date +%S`
runtime=$((end-stime))
green "
#########################################
# $runtime Second backup and replace           #
#########################################\n\n  "
