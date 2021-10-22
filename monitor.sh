#!bin/bash

echo "Name: Cynthia Iradukunda" 
echo "Id: S10103"
echo "Monitoring started...."

FOLDER=~/.trashCan
lastDate=$(date "+%T")
numberOfFiles=$(ls $FOLDER| wc -l)
time=0,4

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

trackFolderAddition (){

numberOfFilesAdded=$(find $FOLDER -type f -cmin $time | wc -l)

echo "The Files that were added in the last 15s: $numberOfFilesAdded"

find $FOLDER -type f -cmin $time

}

trackFolderModified (){

numberOfFileModified=$(find $FOLDER -type f -mmin $time | wc -l)

echo "The Files that were modified in the last 15s: $numberOfFileModified "

find $FOLDER -type f -mmin $time

}

listFilesInTrashCan (){

	if [ ! $(ls $FOLDER |wc -l) -eq 0 ]
	then 
	      echo "The files in the trash can directory"	
	      ls  $FOLDER
        else
	      echo "The trash can is empty"
	fi

}

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

