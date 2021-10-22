#!/bin/bash

echo "Cynthia Iradukunda" 
echo "S1906581"

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
 	
   if [ ! $(ls $FOLDER| wc -l) -eq 0 ];
   then	   
      echo " "
      echo "Different file types: 1.-:regular files, 2. d:directory, 3. c:character device file 4. b:block device file 5. s:local socket file 6.p:named piple 7.l:symbolic link"
      echo " "    
      ls -l $FOLDER | awk 'BEGIN{
      print "File-Name " "File-Type " "File-Size(Bytes)"
      }NR!=1{print $9" "substr($1,0,1)" "$5}'| column -t
   else 
        echo "The Trash Can is empty"
   fi	
}

findFileType(){
 echo "$9"

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
	echo "The total usage of the Trash Can directory is: $totalUsage bytes."
}

startMonitor()
{	
    if [[ $( dpkg-query -W -f='${status}' mate-terminal 2>/dev/null | grep -c "install ok installed" ) -eq 0 ]]
    then
    echo "==============================================================================="	    
    echo "Installing mate terminal emulator to open the monitor report in a new window..."
    echo "==============================================================================="   
    sudo apt-get -qy install  mate-terminal
    mate-terminal -e "bash monitor.sh" &
    else
    mate-terminal -e "bash monitor.sh" &    
    fi

}

killMonitorProcesses()
{
    pidof=$(pidof mate-terminal)

    if [[ $? -eq 0 ]]
    then 
	 echo "Killing the monitor script process...."
         killall mate-terminal
    else
	 echo "The monitor script process has not yet started. Please start it using the -m option" 
    fi
}

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
 if [[ "$#" == 0 ]]; then
	 displayMenu;
 
 fi 	 

 if [ "$OPTIND" == 1 ]
 then 
	 safeDelete "$@"
 fi	 
}

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

checkIfTotalUsageExceed(){
    
    TotalUsage=$(du -cba  ~/.trashCan | awk '{print $1; exit}')
    if [[ "$TotalUsage" -gt 1000 ]]
    then
         echo "Warning: the trash can directory exceeds 1Kbytes"
     fi


}


startApp()
{

doesTrashCanExist
optionDrivenMenu "$@"
}
startApp "$@"
