#!/bin/bash

dt=$(date --date yesterday "+%Y%m%d")
#dt=20161017
srcDir=/var/lib/motion
destDir=~/motionBkup/
tarFile=${dt}MotionFiles.tar.gz
tempFile=/tmp/tempList.txt

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
