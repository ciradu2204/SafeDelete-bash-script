---
title: safeDel
section: 1
header: User Manual
footer: safeDel 1.0.0
date: October 22, 2021
---

# NAME
safeDel - safeDel allows users to safely delete their files.

# SYNOPSIS
**safeDel** [File [File ..]]\
**safeDel** [-lmdt]\
**safeDel** [-r File [File ..]]

# DESCRIPTION
**safeDel** Linux does not allow deleting files temporary files. The safeDel script allows the user to safely delete their file(s) by storing the file(s) in a ~/.trashCan directory. Furthermore, a user can make use of the different options to delete, recover, monitor, and list those files.

# OPTIONS
**-l** 
: output a list on screen of the contents of the trashCandirectory. The list is properly formated as “file name” (without path), “size” (in bytes) and “type” foreach file.

**-r** 
: recover a specified file, from the trashCandirectory and place it in the current directory.

**-d** 
: delete interactively the contents of the trashCandirectory

**-t**
: display total usage in bytes of the trashCan directoryfor the user of the trashcan.

**-m**
: start monitor script process.

**-k**
: kill current monitor script processes.

# EXAMPLES

**safeDel**
: Opens a menu for a user to choose an option they want. 

**safeDel result1.txt result2.txt**
: Safely deletes result1 and result2 files by adding them to the trashCan directory.

**safeDel -l**
: Lists all the content in the trashCan directory.

**safeDel -r result1.txt**
: Recover the result1.txt file that has been added in the trash can directory.

**safeDel -d**
: Deletes interactively all the content in the trash can directory. 

**safeDel -t**
: Display the total disk usage in bytes. 

**safeDel -m**
: Starts the monitoring process by opening a new window terminal and displaying any deletion, addition, and modification that happens in the trashCan directory every 15 sec. 

**safeDel -k**
: Kill the monitoring process by closing the monitoring  window terminal.

# AUTHORS
Written by Cynthia Iradukunda.

# BUGS
Submit bug reports online at: <https://github.com/ciradu2204/SafeDelete-bash-script/issues>

# SEE ALSO
Full documentation and sources at: <https://github.com/ciradu2204/SafeDelete-bash-script> 
