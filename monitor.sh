#!bin/bash

echo "Name: Cynthia Iradukunda" 
echo "Id: S10103"

folder="~/.TrashCan"


trackFolderDeletions (){
echo "file deleted"

}

trackFolderAddition (){

numberOfFiles= find $folder -type f -cmin 15s | wc -l 
echo "The Files that were added in the last 15s: $numberOfFiles"
find $folder -type f -cmin 15s

}

trackFolterModified (){

numberOfFiles= find $folder -type f -mmin 15s | wc -l
echo "The Files that were modified in the last 15s: $numberOfFiles"
find $folder -type f -mmin 15s


}

osascript -e 'tell app "Terminal"
echo "Last thing"
end tell'
while(true){
trackFolderAddition()
trackFolderModified() 
sleep 15s

}

