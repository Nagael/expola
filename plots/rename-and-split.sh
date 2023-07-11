#!/bin/bash

rm result-*.txt
rm metadata-*.txt

for i in expola-*.err; do
    echo $i
    if [ ! -f $i ]; then exit; fi
    echo $i
    base=$(basename $i .err)
    node=$(grep "Node" $i | cut -d: -f2|sed 's/ //g')
    node=${node%%[0-9]*}
    echo $i $base $node
    ## if [ -f metadata-${node}.txt ]; then continue; fi
    cat $i >> metadata-${node}.txt
    grep "MGS" ${base}.out >> result-MGS-${node}.txt
    grep "HH_A2V" ${base}.out >> result-A2V-${node}.txt
    grep "GEQR" ${base}.out >> result-A2V-${node}.txt
    grep "HH_V2Q" ${base}.out >> result-V2Q-${node}.txt
    grep "ORG" ${base}.out >> result-V2Q-${node}.txt
done
