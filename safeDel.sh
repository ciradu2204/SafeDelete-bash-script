#!/bin/bash

echo "Cynthia Iradukunda" 
echo "S3458858"

FOLDER=~/.trashCan
TotalUsage=0

trap trapFunction SIGINT

doesTrashCanExist()
{
	
   if [ ! -d $FOLDER ]; then	  

          mkdir $FOLDER	    
    fi
}

listContent()
{
   if [ "$(ls -a $FOLDER)" ];
   then	   
        ls -als $FOLDER
   else 
        echo "The Trash Can is empty"
   fi	
}

deleteTrashCanContent()
{
  echo "Are you sure you want to delete all the content in the Trash Can?(Y/N)"
  read userResponse 

  if [ ${userResponse^} == "Y" -o ${userResponse^} == "Yes" ]; then
	  rm -i $FOLDER/*
	  echo "Content deleted"
  else
	  echo "Content is not delete" 
 
  fi
}

displayTotalUsage()
{
	totalUsage=$(du -cba  ~/.trashCan | awk '{print $1; exit}')
        TotalUsage=$totalUsage  
	echo "The total usage of the Trash Can directory is: $totalUsage bytes."
}

startMonitor()
{	
    if [[ $( dpkg-query -W -f='${status}' mate-terminal 2>/dev/null | grep -c "install ok installed" ) -eq 0 ]]
    then
    echo "======================================================================="	    
    echo "Installing mate terminal to open the monitor report in a new window..."
    echo "======================================================================="   
    sudo apt-get -qy install  mate-terminal
    mate-terminal -e  "bash monitor.sh" &
    else
    mate-terminal -e "bash monitor.sh " &    
    fi

}

killMonitorProcesses()
{
    pidof=$(pidof mate-terminal)
    kill $pidof
}

recoverFile()
{

	workingDirectory=$(pwd)
	
	if [ ! -f "$FOLDER/$OPTARG" ]; then 
	 echo "$OPTARG file is not recognised. Check if it exists in the trash Can directory."
         else
		 mv "$FOLDER/$OPTARG" $workingDirectory
		 echo "$OPTARG file recovered"
         fi		 
}

safeDelete()
{
      File="$@"
      
       mv -t $FOLDER $File
       
      if [ $? -eq 0 ]
      then 
         echo "$File deleted successfully"
      else
         echo "Try again,$File not deleted. Check to see if you have provided the correct  absolute path." 
      fi	 

}

trapFunction()
{	
 numberOfFiles=$(find $FOLDER -type f | wc -l)
 echo ""
 echo "The number of files in the TrashCan folder are: $numberOfFiles"
 exit
}

optionDrivenMenu()
{
 
  while getopts "ldtmkr:" opt; do

   case "${opt}" in 
   l) listContent;;
   d) deleteTrashCanContent;;
   t) displayTotalUsage;;
   m) startMonitor;;
   k) killMonitorProcesses;;
   r) recoverFile "$OPTARG";;
    esac
 done 
 if [[ "$#" == "0" ]]; then
	 displayMenu;
	 return;
 
 fi 	 

 if [ "$OPTIND" == "1" ]
 then 
	 safeDelete "$@"
 fi	 
}

displayMenu()
{
  echo "============================================================================"
  echo " Safe Delete Menu (Please enter a number assosiated with an option you want)"
  echo "============================================================================"
  options=(-l -r -d -t -m -k Quit )
  
  select opt in "${options[@]}"
   do 
       case $opt in
	"-l") listContent;;
	"-r") recoverFile;;
	"-d") deleteTrashCanContent;;
	"-t") displayTotalUsage;;
	"-m") startMonitor;;
	"-k") killMonitorProcesses;;
        "Quit") break;;	 
        *)
		echo "invalid option"
	esac
done	
}

checkIfTotalUsageExceed(){
    if [[ "$TotalUsage" -gt 1000 ]]
    then
         echo "Warning: the trash can directory exceeds 1Kbytes"
     fi


}


startApp()
{

doesTrashCanExist
optionDrivenMenu "$@"
checkIfTotalUsageExceed
}
startApp "$@"
