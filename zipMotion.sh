#!/bin/bash

shopt -s nullglob
dt=$(date --date yesterday "+%Y%m%d")
#dt=20161021
srcDir=/var/lib/motion
destDir=~/motionBkup/
tarFile=${dt}MotionFiles.tar
tempFile=/tmp/tempList.txt
arr=(${srcDir}/*${dt}*)


echo "GENERATING LIST OF FILES TO TAR..."
for ((i=0; i<${#arr[@]}; i++)); 
do
    echo "${arr[$i]}"
done

echo "TARING UP MOTION FILES FROM ${dt}...."
tar -cf /tmp/${tarFile} --files-from /dev/null

for f in "${arr[@]}"
do
  echo $f
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

exit






echo $dt
#ls ${dir}/*${dt}*

echo "GENERATING LIST OF FILES TO TAR..."
ls -lart ${srcDir}/*${dt}* | awk '{print $9}' >> ${tempFile}

echo "TARING UP MOTION FILES FROM ${dt}...."
#echo sudo tar czvf "${tarFile}" -T "${srcDir}/*${dt}*"
tar -czvf ${tarFile} -T ${tempFile}

echo "MOVING TARED FILE TO ${destDir}..."
sudo mv ${tarFile} ${destDir}

echo "DELETING TARED FILES..."
for i in `grep ^ ${tempFile}`
do
  echo "Removing file $i..."
  sudo rm -rf $i
done

echo "CLEANING UP TEMP INFO..."
sudo rm -f ${tempFile}
