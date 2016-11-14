#!/bin/bash

shopt -s nullglob
srcDir=/var/lib/motion
destDir=~/motionBkup/
tempFile=/tmp/tempList.txt
prevDay=$(date --date yesterday "+%Y%m%d")
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# user defined functions
worker() {
    tarFile=${dt}MotionFiles.tar
    tar -cf /tmp/${tarFile} --files-from /dev/null
    for ((i=0; i<${#arr[@]}; i++)); 
    do
        fileNum=$((i + 1))
        echo "Dealing with file number $fileNum of ${#arr[@]} ..."
        f=${arr[$i]}
        tar -rf /tmp/${tarFile} -P $f 2>&1 >> /dev/null
        sudo rm -rf $f
    done
}

cleanup() {
    tarFile=${dt}MotionFiles.tar
    echo "TARING UP FILE..."
    gzip /tmp/${tarFile}
    echo "MOVING TAR FILE..."
    sudo mv /tmp/${tarFile}.gz ${destDir}
}

pause(){
    read -p "Job complete, press [Enter] key to continue..." fackEnterKey
}

one(){
    dt=$(date --date yesterday "+%Y%m%d")
    echo "GENERATING LIST OF FILES FOR ${dt}..."
    arr=(${srcDir}/*${dt}*)
    
    if [ ${#arr[@]} -le 1 ]
    then
        echo "Nothing to delete..."
        pause
    else
        echo "${#arr[@]} total files to be dealt with..."
        sleep 5
        worker
        cleanup
        pause
    fi      
}

two(){
    read -p "Enter your date YYYYMMDD: " dt
    echo "Your date entered is: ${dt}"
    echo "GENERATING LIST OF FILES TO TAR..."
    arr=(${srcDir}/*${dt}*)

    if [ ${#arr[@]} -le 1 ]
    then
        echo "Nothing to delete..."
        pause
    else
        echo "${#arr[@]} total files to be dealt with..."
        sleep 5
        worker
        cleanup
        pause
    fi      
}


# function to display menu
show_menus() {
    clear
    echo "~~~~~~~~~~~~~~~~~"
    echo "   MAIN - MENU   "
    echo "~~~~~~~~~~~~~~~~~"
    echo "1. Run for previous day ${prevDay}"
    echo "2. Enter date for run"
    echo "3. EXIT"
}

read_options(){
    local choice
    read -p "Enter choice [ 1 - 3 ] " choice
    case ${choice} in
        1) one ;;
        2) two ;;
        3) exit 0;;
        *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
}

trap '' SIGINT SIGQUIT SIGTSTP

while true
do
    show_menus
    read_options
done
