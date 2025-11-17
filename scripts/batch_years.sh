#!/bin/bash

for yr in {1871..1950}; do
    job="process_"$yr".job"
    sed 's/ystr/'$yr'/g' process_cpl_hist_template.csh > $job
    qsub $job
done
