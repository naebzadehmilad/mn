#!/bin/bash

red='\e[0;31m';
gre='\e[0;32m';
whi='\e[0;37m';
yel='\e[0;33m';

#changetime=3


internet(){
     
    rcurl=`curl -o /dev/null -s -w %{http_code} -m2 http://google.com/`
    echo -e $whi "result status code proxy=/$rcurl/ "
    if [[ $rcurl = 000  ]] ; then 
          echo -e $red " check the connection to internet " 
          unset http_proxy 
          sed -i '$d' ~/.bash_profile
          continue  ;
    else
          echo ${readproxy[$i]} >> proxy-status-ok.txt  
          echo -e $gre "  this is  ${readproxy[$i]} ok .....  " 
          unset http_proxy
          sed -i '$d' ~/.bash_profile
    fi
}

proxy() {
 	
   while read line ; do
      readproxy[i++]=$line
   done < proxy.txt
   
count=${#readproxy[*]} 

}


brout() {
   while read line ; do
      readbrout[i++]=$line
   done < brout.txt

countbrout=${#readbrout[*]}

}


change(){
  for ((i=0;i<=$count;i++)) ; do 

    if [[ -z ${readproxy[$i] } ]] ; then
        i=-1 
     else

        echo "export http_proxy=http://${readproxy[$i]} " >> ~/.bash_profile  &&  source ~/.bash_profile ; result=`internet $rcurl $readproxy ` ; ipinfo=`curl --silent ipinfo.io | grep -n3  country   `
        if [[ $? = 0 ]] ; then 
          echo -e $gre $ipinfo 
        fi   
        echo -e $yel ${readproxy[$i]} 
        echo $BASHPID > /var/run/proxy.pid
        #sleep $changetime ;  
         
     fi
  done
}

hammer() {

 for ((i=0;i<=$countbrout;i++)) ; do 
    
    ssh -oStrictHostKeyChecking=no root@${readbrout[$i]} 
    
  


proxy 
change $readproxy  $changetime 
