#!/bin/bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + Default cplhist simulation for coupPPE-hist
# + Ben Buchovecky, October 10th 2025
# + Adapted from Daniel Kennedy
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# CASENAME="f.e21.FHIST_BGC.f19_f19_mg17.coupPPE-hist.cplhist"
CASENAME="f.e21.FHIST_BGC.f19_f19_mg17.coupPPE-hist.cplhist.v2"
CASEROOTBASE="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims"
CESMROOT="/glade/u/home/bbuchovecky/cesm_source/cesm2.1.5"
RUNROOTBASE="/glade/derecho/scratch/bbuchovecky"
PROJECT="UWAS0155"

COMPSET="FHIST_BGC"
CASERES="f19_f19_mg17"
NAMELISTS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts/namelists"
PARAMFILES="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/paramfiles"

BASECASE="b.e21.B1850.f19_g17.CMIP6-piControl-2deg.001"
INITROOT="/glade/campaign/cesm/cesmdata/inputdata/cesm2_init/b.e21.B1850.f19_g17.CMIP6-piControl-2deg.001/0321-01-01"

FILENAME="$(pwd)/coupPPE-hist.cplhist"

caseroot="${CASEROOTBASE}/${CASENAME}"

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Redirect all output from this run script to a log file
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
exec > >(tee -a "${FILENAME}.log") 2>&1
echo "${0}"
echo "${USER}"
date +%y-%m-%dT%H:%M:%S

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Make case
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Change to directory to make case
cd "${CESMROOT}/cime/scripts" || exit

# Create new case
echo ; echo "!! Creating new case in the directory: $(pwd)" ; echo
./create_newcase --case "${caseroot}" --res "${CASERES}" --compset "${COMPSET}" --project "${PROJECT}" --machine derecho --run-unsupported

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Configure case
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Change to case directory
cd $caseroot || exit
echo ; echo "!! Configuring case in the directory: $(pwd)" ; echo

# Update namelists
cp "${NAMELISTS}/FHIST_CPL"* ./

# Apply parameter file for parameter change
echo -e "paramfile = \"${PARAMFILES}/coupPPE-hist.000.nc\"" >> user_nl_clm

# Apply sourcemods, extra history fields
cp /glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/all/cam/cam_diagnostics.F90 ./SourceMods/src.cam/
cp /glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/all/clm/CanopyStateType.F90 ./SourceMods/src.clm/
cp /glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/all/clm/PhotosynthesisMod.F90 ./SourceMods/src.clm/

# Point to refdir
./xmlchange RUN_TYPE=hybrid
./xmlchange RUN_REFCASE="${BASECASE}"
./xmlchange RUN_REFDATE=0321-01-01
./xmlchange RUN_STARTDATE=1850-01-01

# Run for 100 years
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N=5
./xmlchange REST_OPTION="nyears"
./xmlchange REST_N=5
./xmlchange RESUBMIT=19
./xmlchange JOB_WALLCLOCK_TIME=09:30:00 --subgroup case.run

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set up case
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo ; echo "!! Setting up case" ; echo
./case.setup

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Stage restart files and build case
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Copy resubmit files (from case we're branching from) into this case's run folder
cd "${RUNROOTBASE}/${CASENAME}/run" || exit
echo ; echo "!! Copying restart files into the directory: $(pwd)" ; echo
cp $INITROOT/* .

# Build the case
cd "${caseroot}" || exit
echo ; echo "!! Building case in the directory: $(pwd)" ; echo
qcmd -A "${PROJECT}" -- ./case.build

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Submit case
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ; echo "!! Submitting case in the directory: $(pwd)" ; echo
./case.submit

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Do some cleanup, copy this run script into the run directory 
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ; echo "!! Copying run scripts into the directory: $(pwd)" ; echo
mv "${FILENAME}.log" .