#!bin/bash

echo "Name: Cynthia Iradukunda" 
echo "Id: S10103"
echo "Monitoring started...."

FOLDER=~/.trashCan
lastDate=$(date "+%T")
numberOfFiles=$(ls | wc -l)

trackFolderDeletions (){

numberOfFilesNow=$(ls | wc -l ) 

if [ $numberOfFilesNow -lt $numberOfFiles ]
then
	echo "The files deleted in the last 15 s: $(($numberOfFiles - $numberOfFilesNow))"
	numberOfFiles=$numberOfFilesNow
else
	echo "The files deleted in the last 15 s: 0" 
fi  
}

trackFolderAddition (){
numberOfFiles=$(find $FOLDER -type f -cmin 0.4 | wc -l) 
echo "The Files that were added in the last 15s: $numberOfFiles"
find $FOLDER -type f -cmin 0.4
}

trackFolderModified (){
numberOfFiles=$(find $FOLDER -type f -mmin 0.4 | wc -l)
echo "The Files that were modified in the last 15s: $numberOfFiles"
find $FOLDER -type f -mmin 0.4
}


while [ true ]
do
sleep 15
reset 
dateNow=$(date "+%T")
echo "==================================================="
echo "Trash Can directory report from $lastDate of $dateNow"
echo "==================================================="
trackFolderDeletions
trackFolderAddition
trackFolderModified 
done

