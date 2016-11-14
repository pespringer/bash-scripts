#!/bin/bash

shopt -s nullglob
#dt=$(date --date yesterday "+%Y%m%d")
dt=20161110
srcDir=/var/lib/motion
destDir=~/motionBkup/
tarFile=${dt}MotionFiles.tar
tempFile=/tmp/tempList.txt

echo "GENERATING LIST OF FILES TO TAR..."
arr=(${srcDir}/*${dt}*)

echo "${#arr[@]} total files to be dealt with..."
tar -cf /tmp/${tarFile} --files-from /dev/null
sleep 5

for ((i=0; i<${#arr[@]}; i++)); 
do
    echo "Dealing with file number $i of ${#arr[@]} ..."
    f=${arr[$i]}
    tar -rf /tmp/${tarFile} -P $f 2>&1 >> /dev/null
    sudo rm -rf $f
done

echo "TARING UP FILE..."
gzip /tmp/${tarFile}
echo "MOVING TAR FILE..."
echo "sudo mv /tmp/${tarFile}.gz ${destDir}"

exit







echo "TARING UP MOTION FILES FROM ${dt}...."
tar -cf /tmp/${tarFile} --files-from /dev/null

for f in "${arr[@]}"
do
  #echo $f
  tar -rf /tmp/${tarFile} $f 
done
gzip /tmp/${tarFile}

echo "MOVING TARED FILE TO ${destDir}..."
sudo mv /tmp/${tarFile}.gz ${destDir}

echo "DELETING TARED FILES..."
for f in "${arr[@]}"
do
  echo "REMOVING FILE $f...." 
  sudo rm -rf $f 
done
