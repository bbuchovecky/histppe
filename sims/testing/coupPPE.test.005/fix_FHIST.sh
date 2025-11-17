#!/bin/bash

# fixed handling of REFCASE in setupIHIST.sh

MEM="coupPPE.test.005"

# remove build and run
rm -rf "/glade/derecho/scratch/bbuchovecky/f.e21.FHIST_BGC.f19_f19_mg17.historical.${MEM}"

# remove case
cd "/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims/${MEM}"
rm -rf "f.e21.FHIST_BGC.f19_f19_mg17.historical.${MEM}"

echo -e "./setupFHIST.sh ${MEM}" > commands.txt

# resubmit segment which depends on a finished job, so it should immediately get queued
qsub segment004.job
