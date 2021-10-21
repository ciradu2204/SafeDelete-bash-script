#!bin/bash

echo "Name: Cynthia Iradukunda" 
echo "Id: S10103"
echo "Monitoring started...."

# A constant variable to store the trash Can directory path. 
FOLDER=~/.trashCan

# A variable to store the last time the monitoring happened.
lastDate=$(date "+%T")

# A variable to store the number of files the trashCan directory had, the last time the monitoring happened.  
numberOfFiles=$(ls | wc -l)

# A function to track the deletions in the trash Can. 
trackFolderDeletions (){

numberOfFilesNow=$(ls | wc -l ) 

# Check to see if the number of files now are less than the numberOFfiles obtained when the last monitoring happened. If true, calculate the number of files deleted. Otherwise print the number as 0. 
if [ $numberOfFilesNow -lt $numberOfFiles ]
then
	echo "The files deleted in the last 15 s: $(($numberOfFiles - $numberOfFilesNow))"
	numberOfFiles=$numberOfFilesNow
else
	echo "The files deleted in the last 15 s: 0" 
fi  
}

# A frunction to track the addition of files in the trash Can. 

trackFolderAddition (){

# Store the number of files created in the last 15 min.  
numberOfFiles=$(find $FOLDER -type f -cmin 0.4 | wc -l) 

echo "The Files that were added in the last 15s: $numberOfFiles"

# Print the path of the files created in the last 15 min. 
find $FOLDER -type f -cmin 0.4

}

trackFolderModified (){

#Store the number files created modified in the last 15 min. 
numberOfFiles=$(find $FOLDER -type f -mmin 0.4 | wc -l)

echo "The Files that were modified in the last 15s: $numberOfFiles"

#Print the path to the number of files modified in the last 15 min. 
find $FOLDER -type f -mmin 0.4

}

# Run a loop to continously run all those functions.  
while [ true ]
do

#Sleep for 15 min to only give the report after 15 min. 	
sleep 15

#Reset the window terminal incase it still displays the last report. 
reset 

dateNow=$(date "+%T")

echo "==================================================="
echo "Trash Can directory report from $lastDate of $dateNow"
echo "==================================================="
trackFolderDeletions
trackFolderAddition
trackFolderModified 
done

