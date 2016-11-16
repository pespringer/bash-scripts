#!/bin/bash

shopt -s nullglob
srcDir=/var/lib/motion
destDir=~/motionBkup/
tempFile=/tmp/tempList.txt
prevDay=$(date --date yesterday "+%Y%m%d")
RED='\033[0;41;30m'
STD='\033[0;0;39m'

echo "Starting menu script at `date`" 2>&1 >> /home/pi/worker.log

# user defined functions
meh(){
    while true
    do
        echo "running..." 2>&1 >> /home/pi/worker.log
        sleep 1
    done &
    echo ""
    read -p "Job is running in background.  Press [Enter] to continue..." fackEnterKey
}

worker() {
    echo "Starting worker function at `date`" 2>&1 >> /home/pi/worker.log
    tarFile=${dt}MotionFiles.tar
    tar -cf /tmp/${tarFile} --files-from /dev/null
    for ((i=0; i<${#arr[@]}; i++)); 
    do
        fileNum=$((i + 1))
        echo "Dealing with file number $fileNum of ${#arr[@]} ..." 2>&1 >> /home/pi/worker.log
        f=${arr[$i]}
        tar -rf /tmp/${tarFile} -P $f 2>&1 >> /dev/null
        sudo rm -rf $f 2>&1 >> /home/pi/worker.log
    done &
    echo ""
    read -p "Job is running in background.  Press [Enter] to continue..." fackEnterKey
    #exit 1
}

cleanup() {
    echo "Starting cleanup function at `date`" 2>&1 >> /home/pi/worker.log
    tarFile=${dt}MotionFiles.tar
    echo "TARING UP FILE..."
    gzip /tmp/${tarFile}
    echo "MOVING TAR FILE..."
    sudo mv /tmp/${tarFile}.gz ${destDir}
}

pause(){
    echo ""
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
        echo "${#arr[@]} FILES TO BE DEALT WITH..." 2>&1 >> /home/pi/worker.log
        sleep 5
        worker
        wait #Wait for worker function to complete before cleanup moves tar file
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
        echo "${#arr[@]} FILES TO BE DEALT WITH..." 2>&1 >> /home/pi/worker.log
        sleep 5
        worker
        cleanup
        pause
    fi      
}

three() {
    jobs
    if ((`jobs |wc -l` == 0))
    then
        echo "No jobs are running"
    fi
    pause
}

four() {
    tail -n100 /home/pi/worker.log
    echo ""
    read -p "Job is running in background.  Press [Enter] to continue..." fackEnterKey
}

# function to display menu
show_menus() {
    clear
    echo "~~~~~~~~~~~~~~~~~"
    echo "   MAIN - MENU   "
    echo "~~~~~~~~~~~~~~~~~"
    echo "1. Run for previous day ${prevDay}"
    echo "2. Enter date for run"
    echo "3. See Running Job"
    echo "4. View Log File"
    echo "q  EXIT"
}

read_options(){
    local choice
    read -p "Enter choice [ 1 - 4 / q ] " choice
    case ${choice} in
        1) one ;;
        2) two ;;
        3) three ;;
        4) four ;;
        q) exit 0;;
        *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
}

trap '' SIGINT SIGQUIT SIGTSTP

while true
do
    show_menus
    read_options
done
