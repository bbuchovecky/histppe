#!/bin/bash

# fixed handling of REFCASE in setupIHIST.sh

MEM="coupPPE.test.005"

# remove build and run
rm -rf "/glade/derecho/scratch/bbuchovecky/IHistClm50Bgc.CPLHIST.historical.${MEM}.IHIST"

# remove case
cd "/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims/${MEM}"
rm -rf "IHistClm50Bgc.CPLHIST.historical.${MEM}.IHIST"

echo -e "./setupIHIST.sh ${MEM}" > commands.txt

# resubmit segment which depends on a finished job, so it should immediately get queued
qsub segment003.job
