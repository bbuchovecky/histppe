#!/bin/bash

MEM=$1
CLONENAME="I1850Clm50Bgc.CPLHIST.historical.${MEM}.AD"
CASENAME="I1850Clm50Bgc.CPLHIST.historical.${MEM}.pAD"
PROJECT=UWAS0155

SDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts"
WDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims/${MEM}"
ARCHIVE="/glade/derecho/scratch/bbuchovecky/archive"
NAMELISTS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts/namelists"
PARAMFILES="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert/paramfiles"

CESMROOT="/glade/u/home/bbuchovecky/cesm_source/cesm2.1.5"


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# redirect output from this script to a log file
FILENAME="$(pwd)/$(basename "${0%.*}")"
exec > >(tee -a "${FILENAME}.log") 2>&1
echo $FILENAME
echo $USER
date +%y-%m-%dT%H:%M:%S


CASEROOTBASE=$WDIR
cloneroot="${CASEROOTBASE}/${CLONENAME}"
caseroot="${CASEROOTBASE}/${CASENAME}"
echo "cloneroot: ${cloneroot}"
echo "caseroot:  ${caseroot}"


cd "${CESMROOT}/cime/scripts"
./create_clone --case $caseroot --clone $cloneroot
cd $caseroot
./case.setup


# cloning copies over sourcemods, no need to reapply them


# apply namelist mods for history fields
cp "${NAMELISTS}/pAD/"* ./


# apply namelist mods for parameter change
cat "${NAMELISTMODS}/${MEM}.txt" >> user_nl_clm


# apply parameter file for parameter change
echo -e "\nparamfile = \"${PARAMFILES}/${MEM}.nc\"" >> user_nl_clm


./xmlchange RUN_TYPE=hybrid
./xmlchange CONTINUE_RUN=False
./xmlchange PROJECT=$PROJECT
./xmlchange JOB_PRIORITY="regular"
./xmlchange JOB_WALLCLOCK_TIME="04:30:00" --subgroup case.run
./xmlchange RUN_STARTDATE="0001-01-01"
./xmlchange STOP_N=100,STOP_OPTION=nyears
./xmlchange CLM_ACCELERATED_SPINUP=off


# finding the latest restart from AD
# this code is likely very brittle
./xmlchange RUN_REFCASE=$CLONENAME
./xmlchange GET_REFCASE="True"
REFREST="${ARCHIVE}/${CLONENAME}/rest"
last_date=$(ls $REFREST | tail -n1)
REFDIR="${REFREST}/${last_date}"
REFDATE=${last_date%-*}
./xmlchange RUN_REFDIR=$REFDIR
./xmlchange RUN_REFDATE=$REFDATE


./case.build
mv "${FILENAME}.log" .


cd $WDIR
echo $CASENAME>case.txt
echo "${SDIR}/stabPAD.sh ${MEM}">commands.txt
