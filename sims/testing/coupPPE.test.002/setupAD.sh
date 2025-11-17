#!/bin/bash

MEM=$1
# MEM="coupPPE.000"
CASENAME="I1850Clm50Bgc.CPLHIST.historical.${MEM}.AD"
PROJECT=UWAS0155


WDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims/${MEM}"
NAMELISTS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts/namelists"
NAMELISTMODS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert/testing/coupPPE.test.002/nlmods"
PARAMFILES="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert/testing/coupPPE.test.002/paramfiles"
SOURCEMODS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert/testing/coupPPE.test.002/srcmods/perturbed"

COMPSET=1850_DATM%CPLHIST_CLM50%BGC-CROP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV
GRID=f19_f19_mg17
CESMROOT="/glade/u/home/bbuchovecky/cesm_source/cesm2.1.5"

REFCASE="b.e21.B1850.f19_g17.CMIP6-piControl-2deg.001"
REFDIR="/glade/campaign/cesm/cesmdata/inputdata/cesm2_init/b.e21.B1850.f19_g17.CMIP6-piControl-2deg.001/0321-01-01"
REFDATE="0321-01-01"

CPLHIST_CASE="f.e21.FHIST_BGC.f19_f19_mg17.coupPPE-hist.cplhist"
CPLHIST_DIR="/glade/derecho/scratch/bbuchovecky/archive/${CPLHIST_CASE}/cpl/proc/"
CPLHIST_YR_ALIGN="1850"
CPLHIST_YR_START="1850"
CPLHIST_YR_END="1869"


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
cp "${SOURCEMODS}/all/"* ./SourceMods/src.clm/


# apply sourcemods for parameter change
cp "${SOURCEMODS}/${MEM}/"* ./SourceMods/src.clm/


# apply namelist mods for history fields
cp "${NAMELISTS}/AD/"* ./


# apply namelist mods for parameter change
cat "${NAMELISTMODS}/${MEM}.txt" >> user_nl_clm


# apply parameter file for parameter change
echo -e "paramfile = \"${PARAMFILES}/${MEM}.nc\"" >> user_nl_clm


./xmlchange RUN_TYPE=hybrid
./xmlchange PROJECT=$PROJECT
./xmlchange JOB_PRIORITY="regular"
./xmlchange RUN_STARTDATE="0001-01-01"
./xmlchange RUN_REFCASE=$REFCASE
./xmlchange RUN_REFDIR=$REFDIR
./xmlchange RUN_REFDATE=$REFDATE
./xmlchange GET_REFCASE="True"


./xmlchange DATM_MODE="CPLHIST"
./xmlchange DATM_PRESAERO="cplhist"
./xmlchange DATM_TOPO="cplhist"
./xmlchange DATM_CPLHIST_CASE=$CPLHIST_CASE
./xmlchange DATM_CPLHIST_DIR=$CPLHIST_DIR
./xmlchange DATM_CPLHIST_YR_ALIGN=$CPLHIST_YR_ALIGN
./xmlchange DATM_CPLHIST_YR_START=$CPLHIST_YR_START
./xmlchange DATM_CPLHIST_YR_END=$CPLHIST_YR_END
./xmlchange STOP_N=100,STOP_OPTION=nyears
./xmlchange CLM_ACCELERATED_SPINUP=on


./case.build
mv "${FILENAME}.log" .


cd $WDIR
echo $CASENAME>case.txt
echo "./stabAD.sh ${MEM}">commands.txt
# echo "./stabAD.sh">commands.txt
