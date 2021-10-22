#!bin/bash

echo "Name: Cynthia Iradukunda" 
echo "Id: S1906581"
echo "Monitoring started...."
#A constant variable  with the path name
FOLDER=~/.trashCan

#A variable to store the last date the monitoring happened.
lastDate=$(date "+%T")

#A variable to store the last number of files that were in the trash can directory to help with tracking deletion"
numberOfFiles=$(ls $FOLDER| wc -l)

#The seconds to be used when tracking file changes. 
time=0,4

#A function to track folder deletions by first changing if the last identified number of files has changed. If the number reduced then, it prints the number of files that were deleted. 
trackFolderDeletions (){

numberOfFilesNow=$(ls $FOLDER| wc -l)
if [ $numberOfFilesNow -lt $numberOfFiles ]
then

	echo "The files deleted in the last 15 s: $(($numberOfFiles - $numberOfFilesNow))"
else
	echo "The files deleted in the last 15 s: 0" 
fi

numberOfFiles=$numberOfFilesNow
}

#A function to track the addition of files.By using the -cmin option on the find command, it shows the files that were create
#in the last 15s. 
trackFolderAddition (){

numberOfFilesAdded=$(find $FOLDER -type f -cmin $time | wc -l)

echo "The Files that were added in the last 15s: $numberOfFilesAdded"

find $FOLDER -type f -cmin $time

}

#A function to track the modification of files. By using the -mmin option on the find command, it shows the files that were modified in the last 15s.
trackFolderModified (){

numberOfFileModified=$(find $FOLDER -type f -mmin $time | wc -l)

echo "The Files that were modified in the last 15s: $numberOfFileModified "

find $FOLDER -type f -mmin $time

}

#A function to list the number of files in the trash can every 15 s. 
listFilesInTrashCan (){

	if [ ! $(ls $FOLDER |wc -l) -eq 0 ]
	then 
	      echo "The files in the trash can directory"	
	      ls  $FOLDER
        else
	      echo "The trash can is empty"
	fi

}

#A while loop to run which runs the functions bellow continously unless the script is killed. 
while [ true ]
do
sleep 15
dateNow=$(date "+%T")
echo "==================================================="
echo "Trash Can directory report from $lastDate to $dateNow"
echo "==================================================="
listFilesInTrashCan
echo " "
trackFolderDeletions
echo " "
trackFolderAddition
echo " "
trackFolderModified
echo "==================================================="
echo "             End of Report                         "
echo "==================================================="
echo " "
lastDate=$dateNow
done

