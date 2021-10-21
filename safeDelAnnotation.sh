#!/bin/bash

echo "Cynthia Iradukunda" 
echo "S3458858"

#Create a constant variable to store the trash Can directory path. 
FOLDER=~/.trashCan

#run the trapFunction when it receives a SIGINT signal.
trap trapFunction SIGINT

#a function to check if the trash can folder exists. And create one if it does not exist  
doesTrashCanExist()
{
	
   if [ ! -d $FOLDER ]; then	  

          mkdir $FOLDER	    
    fi
}

# A function to list the content of the trash can directory. It checks to see the number of files in the trashcan. If the number is different from 0, it prints the file size, file type, and file name of each file. Otherwise, it notifies the user. 
listContent()
{
   if [ ! $(ls -a $FOLDER| wc -l) -eq 0 ];
   then	   echo " "
	   ls -l $FOLDER | awk  'BEGIN{print "File-Name " "File-Type " "File-Size(Bytes)"} NR!=1{print $9 " " substr($1, 0, 1) " " $5}' | column -t
   else 
        echo "The Trash Can is empty"
   fi	
}

# A function to delete all the content in the trash can content. It first ask the user to ensure they want to delete all files.If they do, then it deletes them interactively. Otherwise, it does not delete. 
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

#A function to display the disk usage of a the trashCan directory. It firsts get the total usage in bytes and then awk command helps to only print the number only without the Total.
displayTotalUsage()
{
	totalUsage=$(du -cba  ~/.trashCan | awk '{print $1; exit}') 
	echo "The total usage of the Trash Can directory is: $totalUsage bytes."
}


# A function to start the monitoring process. It first install the mate terminal incase the user does not have it installed. Then use the mate terminal to start a new window where the monitoring will start. 
startMonitor()
{	
    if [[ $( dpkg-query -W -f='${status}' mate-terminal 2>/dev/null | grep -c "install ok installed" ) -eq 0 ]]
    then
    echo "==============================================================================="	    
    echo "Installing mate terminal emulator to open the monitor report in a new window..."
    echo "==============================================================================="   
    sudo apt-get -qy install  mate-terminal
    mate-terminal -e  "bash monitor.sh" &
    else
    mate-terminal -e "bash monitor.sh " &    
    fi

}

# A function to stop the monitoring process. It first get the pid of the mate terminal. If the exit status is 0 or successful, it kills the terminal. Otherwise it alerts the user that the monitoring process has not started yet.
killMonitorProcesses()
{
    pidof=$(pidof mate-terminal)

    if [[ $? -eq 0 ]]
    then 
	 echo "Killing the monitor script process...."
         kill $pidof
    else
	 echo "The monitor script process has not yet started. Please start it using the -m option" 
    fi
}

#A functions run everytime the user chooses a -r option. It first checks if the user has provides the filename and then ask for it if they did not. Then it checks to see if the file exists in the trash can. If true, recover it to the working directory otherwise it alerts the user that the file is not there. 
recoverFile()
{
      File_name=

        if [[ ! -v OPTARG ]]
	then
           echo "Enter the name of the file from the trash can you want to recover"
	   read file_name
	   File_name=$file_name
	 else
	    File_name=$OPTARG	 
	fi

	 workingDirectory=$(pwd)
	 if [ ! -f "$FOLDER/$File_name" ]; then 
	     echo "$File_name file is not recognised. Check if it exists in the trash Can directory."
         else
              mv "$FOLDER/$File_name" $workingDirectory
	      echo "$File_name file recovered"
         fi
       	  
}
# A funtion to safeDelete the different files. If first get the users arguments and check that each of them exist and it is a file. If exist, it adds it to the trashcan otherwise it alerts the user to input the right path 
safeDelete()
{
      
      for var in $@
      do      
	if [ ! -f "$var" ]; then	       	
	echo "$var is not a file."	
        return; 
	fi     
	
      done

      mv -t "$FOLDER" "$@"
       
      if [ $? -eq 0 ]
      then 
         echo "$@ deleted successfully"
	 checkIfTotalUsageExceed
      else
         echo "Try again,$@ not deleted. Check to see if you have provided the correct  absolute path." 
      fi	 

}

#The function runs everytime there is a trap. It display the number of files in the trash can directory by first listing them and counting each line. 
trapFunction()
{	
 numberOfFiles=$(find $FOLDER -type f | wc -l)
 echo ""
 echo "The number of files in the TrashCan folder are: $numberOfFiles"
 exit
}

# A function to be run everytime the user start the safeDel.sh. It first get the different options the user is allowed to input. Based on the arguments or options, the user provides, it runs a specific function.
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

# A function to be run in case the user does not provide an option. It first takes different options and based on the user option, it run a specific functions.  
displayMenu()
{
  echo "============================================================================"
  echo " Safe Delete Menu (Please enter a number assosiated with an option you want)"
  echo "============================================================================"
  options=("List files" "Recover file(s)" "Delete files" "Display disk usage" "Start monitoring" "Kill monitoring process" Quit )
  
  select opt in "${options[@]}"
   do 
       case $opt in
	"List files") listContent;;
	"Recover file(s)") recoverFile;;
	"Delete files") deleteTrashCanContent;;
	"Display disk usage") displayTotalUsage;;
	"Start monitoring") startMonitor;;
	"Kill monitoring process") killMonitorProcesses;;
        "Quit") break;;	 
        *)
		echo "invalid option"
	esac
done	
}


# A function to run everytime the user adds a file to the trashcan and  the total usage exceeds 1000 bytes. 
checkIfTotalUsageExceed(){
    
    TotalUsage=$(du -cba  ~/.trashCan | awk '{print $1; exit}')
    if [[ "$TotalUsage" -gt 1000 ]]
    then
         echo "Warning: the trash can directory exceeds 1Kbytes"
     fi


}

#A function to start the app by running different functions such as optionDriveMenu and doesTrashCan exit. 
startApp()
{

doesTrashCanExist
optionDrivenMenu "$@"
}

startApp "$@"
