#!/bin/bash

START=3469596
END=3469713

for job in $(seq $START $END); do
    echo "$job".desched1
    qdel "$job".desched1
done
