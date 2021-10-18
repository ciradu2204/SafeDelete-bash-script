#!/bin/bash

echo "Cynthia Iradukunda" 
echo "S3458858"

FOLDER=~/.trashCan

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
	totalUsage=$(du -cb --exclude=*/\.* ~/.trashCan| awk '{print $1}')

	echo "The total usage of the Trash Can directory is: $totalUsage bytes."
}

startMonitor()
{
    		
    bash monitor.sh &

}

killMonitorProcesses()
{
    pidof=$(pidof inotifywait)
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
      if [ ! -f "$File" ]; then

       echo "File not recognised.Check if you have given the full absolute path to the file if it is not in the current directory."

       else
	  mv $File $FOLDER
	  echo "$File file has been deleted"
       fi	

}

trapFunction()
{	
 numberOfFiles=$(find $FOLDER -type f | wc -l)
 echo "The number of files in the TrashCan folder are: $numberOfFiles"
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
  echo "============Safe Delete Menu=================="
  userOption="Please Enter your choice: "
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



startApp()
{

doesTrashCanExist
optionDrivenMenu "$@"
}
startApp "$@"
