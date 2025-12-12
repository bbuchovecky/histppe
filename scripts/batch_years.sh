#!/bin/bash

for yr in {1850..1949}; do
    job="process_"$yr".job"
    sed 's/ystr/'$yr'/g' process_cpl_hist_template.csh > $job
    qsub $job
done
