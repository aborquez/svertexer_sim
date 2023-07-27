#!/bin/bash
echo "Set CCDB"
export IGNORE_VALIDITYCHECK_OF_CCDB_LOCALCACHE=1
export ALICEO2_CCDB_LOCALCACHE=/storage1/daviddc/xigun/ccdb

mkdir ${1}
cp run_simulation.sh ${1}/.
cd ${1}
source run_simulation.sh 
#Remove hits (reduce requirement of disk space) 
rm -rf tf*/*_Hits???.root
cd ..
