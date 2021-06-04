#!/bin/bash
getUserDir(){
	dscl . -read /Users/$usr | grep NFSHomeDirectory | awk '{print $2}'
}

arg1=("$1")
usr=$arg1
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'


if [ -n "$usr" ]; then
    if dscl . list /Users | grep $usr > /dev/null; then
        usrdir="$(getUserDir)"
	
        if [ -d "$usrdir" ]; then
            printf " 
    Proceeding will do the following:
      Hide user $usr
      Move home directory for $usr from $usrdir to /var/$usr
      Delete $usr's Shared/Public Folder
    "
read -p "Proceed (y/n): " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo 
                #echo $usrdir
                #dscl . create /Users/$usr IsHidden 1
		defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add $usr
                if dscl . -list "/SharePoints" | grep "$usr\’s\ Public\ Folder" > /dev/null; then
			dscl . -delete "/SharePoints/$usr\’s\ Public\ Folder"
		fi
		if [[ "$usrDir" != *"private/var"* ]]; then
			mv $usrdir /var/$usr
                	dscl . -create /Users/$usr NFSHomeDirectory /var/$usr
		fi
            fi
        else
            printf " ${RED}ERROR: User $usr directory not found ${NC}\n"
        fi
    else
        printf " ${RED}ERROR: User $usr not found ${NC}\n"
    fi
else
    printf " ${YELLOW} SYNTAX: $0 username ${NC}\n"
fi
echo
