#!/bin/bash

SRT=3685416
END=3685441

echo "SRT = ${SRT}.desched1"
echo "END = ${END}.desched1"
echo $((END-SRT)) 

for job in $(seq $SRT $END); do
    echo "$job".desched1
    qdel "$job".desched1
done
