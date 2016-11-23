#!/bin/bash

set -m #hopefully enables job control within shell script
shopt -s nullglob
srcDir=/var/lib/motion
destDir=~/motionBkup/
tempFile=/tmp/tempList.txt
prevDay=$(date --date yesterday "+%Y%m%d")
RED='\033[0;41;30m'
STD='\033[0;0;39m'
PID=$$

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
    show_menus
    read_options
}

processCheck(){
    if [ -f ./.${dt}motion ]
    then
        echo ""
        echo "It appears a process for this date ${dt} is already running..."
        echo "If you think this is an error, it is possible the process file was not cleaned up..."
        read -p "To clear the error, manually delete file ./.${dt}motion and rerun..." fackEnterKey
        show_menus
        read_options
    fi
}

createProcessFile(){
    touch ./.${dt}motion
}

deleteProcessFile(){
    rm -f ./.${dt}motion
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
        (tar -rf /tmp/${tarFile} -P $f 2>&1 >> /dev/null)
        (sudo rm -rf $f 2>&1 >> /home/pi/worker.log)
        if [ ${fileNum} -ge ${#arr[@]} ]
        then
            cleanup
        fi
    done &
    echo ""
    read -p "Job is running in background.  Press [Enter] to continue..." fackEnterKey
    show_menus
    read_options
}

cleanup() {
    echo "Starting cleanup function at `date`" 2>&1 >> /home/pi/worker.log
    tarFile=${dt}MotionFiles.tar
    echo "TARING UP FILE..." 2>&1 >> /home/pi/worker.log
    gzip /tmp/${tarFile}
    echo "MOVING TAR FILE..." 2>&1 >> /home/pi/worker.log
    
    if [ -f ${destDir}/${tarFile}.gz ]
    then
        echo "Multiple TAR files for this ${dt} exit.  Renaming with process id..." 2>&1 >> /home/pi/worker.log
        mv /tmp/${tarFile}.gz /tmp/${tarFile}.$$.gz
        mv /tmp/${tarFile}.$$.gz ${destDir}
    else
        sudo mv /tmp/${tarFile}.gz ${destDir}
    fi
   
    deleteProcessFile
    echo "Work completed at `date`." 2>&1 >> /home/pi/worker.log
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
        echo "Nothing to delete.  Script completed at `date`." 2>&1 >> /home/pi/worker.log
        pause
    else
        echo "${#arr[@]} total files to be dealt with..."
        echo "${#arr[@]} FILES TO BE DEALT WITH..." 2>&1 >> /home/pi/worker.log
        sleep 5
        processCheck
        createProcessFile
        worker
        #wait #Wait for worker function to complete before cleanup moves tar file
        #cleanup
        #pause
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
        processCheck
        createProcessFile
        worker
        #wait #Wait for worker function to complete before cleanup moves tar file
        #cleanup
        #pause
    fi      
}

three() {
    echo ""
    ps -ef|grep zipMotion |grep -v grep
    pause
    show_menus
    read_options
}

four() {
    tail -n100 /home/pi/worker.log
    echo ""
    read -p "Tail of the last 100 lines of the log file complete.  Press [Enter] to continue..." fackEnterKey
    show_menus
    read_options
}

# function to display menu
show_menus() {
    clear
    echo "~~~~~~~~~~~~~~~~~"
    echo "   MAIN - MENU   "
    echo "~~~~~~~~~~~~~~~~~"
    echo "1. Run for previous day ${prevDay}"
    echo "2. Enter date for run"
    echo "3. See Running Job Processes"
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
