#!/bin/bash

echo "Cynthia Iradukunda" 
echo "S3458858"

#A constant variable to store The trash Can Directory path

FOLDER=~/.trashCan

# A variable to store the trash Can directory disk usage

TotalUsage=0


# Trap the SIGINT and run the trapFunction 

trap trapFunction SIGINT

# A function to check if the trash Can directory does not exit and create one

doesTrashCanExist()
{
	
   if [ ! -d $FOLDER ]; then	  

          mkdir $FOLDER	    
    fi
}

# A function to list the content of the trash can directory when a user enters -l option

listContent()
{
   # Check if the trashCan is not empty	
   if [ "$(ls -a $FOLDER)" ];
   then	   
	   echo " "
           
	   #List the trash can directory content by adding a header at the beginning to indicate the columns name. Also, for each line, it prints the filename, filetype using substring, and file size only. 
	   ls -l $FOLDER | awk  'BEGIN{print "File-Name " "File-Type " "File-Size(Bytes)"} NR!=1{print $9 " " substr($1, 0, 1) " " $5}' | column -t
   else 
	   #If, it is empty, it will notify the user.
        echo "The Trash Can is empty"
   fi	
}

# A function to delete all the content in the trash can directory when a user enters -d option
deleteTrashCanContent()
{
  #First ask the user if they want to delete all the content. 	
  echo "Are you sure you want to delete all the content in the Trash Can?(Y/N)"

  #Read user response
  read userResponse 

  #First capitalize the userResponse and then check if it is YES or Y then remove all the content in the folder. Otherwise, we notify the user that the content is not deleted. 
  if [ ${userResponse^} == "Y" -o ${userResponse^} == "Yes" ]; then
	  rm -i $FOLDER/*
	  echo "Content deleted"
  else
	  echo "Content is not delete" 
 
  fi
}

# A function to display totalUsage when a user enters a -t option 

displayTotalUsage()
{
	# The du command only prints the total usage of all files not directories. Using the awk command, it stores  only the number in bytes without the word "total"
	totalUsage=$(du -cba  ~/.trashCan | awk '{print $1; exit}')
        TotalUsage=$totalUsage  
	echo "The total usage of the Trash Can directory is: $totalUsage bytes."
}

# Start the trash Can monitoring process
startMonitor()
{	
     #Use the dpkg-query to see if the mate-terminal emulator is instaled. If mate terminal is installed, it will start the monitoring process by opening the script in a new window terminal. Otherwise it will first install it. 
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


# A function to kill the monitoring process when a user enters -k option

killMonitorProcesses()
{
    # It will first find the pidof the mate-terminal
    pidof=$(pidof mate-terminal)

    #It will kill the mate-terminal
    kill $pidof
}


# A function to recover a file from the trash Can directory when a user enters -r option with file

recoverFile()
{
        # First get the user's working directory
	workingDirectory=$(pwd)
	
	# First check if the file provides by the user, exists. If it does not, notify the user. Otherwise, it moves the file to the user working directory.
	if [ ! -f "$FOLDER/$OPTARG" ]; then 
	 echo "$OPTARG file is not recognised. Check if it exists in the trash Can directory."
         else
		 mv -t $workingDirectory "$FOLDER/$OPTARG"
		 echo "$OPTARG file recovered"
         fi		 
}


# A function to delete a file or multiple files by moving them to the trash can directory when a user enters arguments only. 
safeDelete()
{
      # First check if the given arguments the user wants to delete are files.
      for var in $@
      do      
	if [ ! -f "$var" ]; then	       	
	echo "$var is not a file."	
        return; 
	fi     
	
      done
      
      # If they are all files and the user has inputed a correct path to those files, it will move them.
      mv -t "$FOLDER" "$File"
       
      #If the move comand returned an exit status of 0. It will notify the user that the file(s) were deleted and run the checkIfTotalUsageExceed function. Otherwise, it notify the user to enter the correct path. 
      if [ $? -eq 0 ]
      then 
         echo "$File deleted successfully"
	 checkIfTotalUsageExceed
      else
         echo "Try again,$File not deleted. Check to see if you have provided the correct  absolute path." 
      fi	 

}

# A function to be executed every time a user enters ctrl + c or SIGINT signal.
trapFunction()
{	

 # Get the number of all files in the trash can directory and print them. 	
 numberOfFiles=$(find $FOLDER -type f | wc -l)
 echo ""
 echo "The number of files in the TrashCan folder are: $numberOfFiles"
 exit
}

# A function to be executed every time a user runs the safeDel.sh 
optionDrivenMenu()
{
 
  # Provide getopts the options we want to capture and run different functions based on those option provided. 	
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
   
 # incase the user did not input any positional argument or option it will display the menu.
 if [[ "$#" == "0" ]]; then
	 displayMenu;
	 return;
 
 fi 	 

 # Incase the user inputed arguments with no options, it will run the safeDelete function.
 if [ "$OPTIND" == "1" ]
 then 
	 safeDelete "$@"
 fi	 
}

# A function to display the menu. 

displayMenu()
{
  echo "============================================================================"
  echo " Safe Delete Menu (Please enter a number assosiated with an option you want)"
  echo "============================================================================"

  #First get the allowed options and store them in an array variable.
  options=(-l -r -d -t -m -k Quit )
  
  # Run a specific function based on the user's option choice.
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

# A function be run everytime files are moved to the trash Can

checkIfTotalUsageExceed(){

    #Use the variable defined at the top to check if the total usage is greater then 1000 bytes.	
    if [[ "$TotalUsage" -gt 1000 ]]
    then
         echo "Warning: the trash can directory exceeds 1Kbytes"
     fi


}

# A function to start the app by first calling the doesTrashCanExist function and then the optionDriveMenu function.
startApp()
{

doesTrashCanExist
optionDrivenMenu "$@"
}

# Start the safeDel process.
startApp "$@"
