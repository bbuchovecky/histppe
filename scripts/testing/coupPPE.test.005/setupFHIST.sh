#!/bin/bash

MEM=$1
# MEM="coupPPE.000"
CASENAME="f.e21.FHIST_BGC.f19_f19_mg17.historical.${MEM}"
PROJECT=UWAS0155

WDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims/${MEM}"
NAMELISTS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts/namelists"
PARAMFILES="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert/testing/coupPPE.test.005/paramfiles"
SOURCEMODS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert/testing/coupPPE.test.005/srcmods/perturbed"

COMPSET=HIST_CAM60_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV
GRID=f19_f19_mg17
CESMROOT="/glade/u/home/bbuchovecky/cesm_source/cesm2.1.5"

REFCASE="I1850Clm50Bgc.CPLHIST.${MEM}.IHIST"
REFDIR="/glade/derecho/scratch/bbuchovecky/archive/${REFCASE}/rest/1851-01-01"
REFDATE="1851-01-01"


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# redirect output from this script to a log file
FILENAME="$(pwd)/$(basename "${0%.*}")"
exec > >(tee -a "${FILENAME}.log") 2>&1
echo $FILENAME
echo $USER
date +%y-%m-%dT%H:%M:%S


CASEROOTBASE=$WDIR
caseroot="${CASEROOTBASE}/${CASENAME}"
echo "caseroot: ${caseroot}"


cd "${CESMROOT}/cime/scripts"
./create_newcase --case $caseroot --compset $COMPSET --res $GRID --project $PROJECT --mach derecho --run-unsupported
cd $caseroot
./case.setup


# apply sourcemods for history fields
cp "${SOURCEMODS}/all/clm/"* ./SourceMods/src.clm/
cp "${SOURCEMODS}/all/cam/"* ./SourceMods/src.cam/


# apply sourcemods for parameter change
cp "${SOURCEMODS}/${MEM}/"* ./SourceMods/src.clm/


# apply namelist mods for history fields
cp "${NAMELISTS}/FHIST/"* ./


# apply namelist mods for parameter change
cat "${NAMELISTMODS}/${MEM}.txt" >> user_nl_clm


# apply parameter file for parameter change
echo -e "paramfile = \"${PARAMFILES}/${MEM}.nc\"" >> user_nl_clm


./xmlchange RUN_TYPE=hybrid
./xmlchange PROJECT=$PROJECT
./xmlchange JOB_PRIORITY="regular"
./xmlchange RUN_STARTDATE=$REFDATE
./xmlchange RUN_REFCASE=$REFCASE
./xmlchange RUN_REFDIR=$REFDIR
./xmlchange RUN_REFDATE=$REFDATE
./xmlchange GET_REFCASE="True"


./xmlchange STOP_OPTION="nmonths"
./xmlchange STOP_N=1
./xmlchange REST_OPTION="nmonths"
./xmlchange REST_N=1
./xmlchange RESUBMIT=0
./xmlchange JOB_WALLCLOCK_TIME=01:00:00 --subgroup case.run


./case.build
mv "${FILENAME}.log" .


cd $WDIR
echo $CASENAME>case.txt
rm commands.txt
