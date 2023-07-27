#!/bin/bash
#script for multiple sim runs
echo "Bash version ${BASH_VERSION}..."
for i in {000..009}
do
  echo "Batch run: $i"
  ./micro.sh $i  
done
