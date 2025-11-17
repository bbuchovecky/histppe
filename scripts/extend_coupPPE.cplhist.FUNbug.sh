#!/bin/bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + Extend default cplhist simulation for coupPPE-hist
# + Ben Buchovecky, October 22th 2025
# + Adapted from Daniel Kennedy
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CASENAME="f.e21.FHIST_BGC.f19_f19_mg17.coupPPE-hist.cplhist.ext"
CLONENAME="f.e21.FHIST_BGC.f19_f19_mg17.coupPPE-hist.cplhist"
CASEROOTBASE="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims"
CESMROOT="/glade/u/home/bbuchovecky/cesm_source/cesm2.1.5"
PROJECT="UWAS0155"
NAMELISTS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts/namelists/FHIST_CPL_EXT"

cloneroot="${CASEROOTBASE}/${CLONENAME}"
caseroot="${CASEROOTBASE}/${CASENAME}"
echo "cloneroot: ${cloneroot}"
echo "caseroot:  ${caseroot}"

# Need to clone and hybrid for new history fields not available on the restarts
cd "${CESMROOT}/cime/scripts" || exit
./create_clone --case $caseroot --clone $cloneroot
cd $caseroot || exit

# Update namelists with additional history fields
cp "${NAMELISTS}/*" ./

# Apply sourcemods, extra history fields
cp /glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/all/cam/cam_diagnostics.F90 ./SourceMods/src.cam/
cp /glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/all/clm/CanopyStateType.F90 ./SourceMods/src.clm/
cp /glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/all/clm/PhotosynthesisMod.F90 ./SourceMods/src.clm/

# Point to refdir
./xmlchange RUN_TYPE=hybrid
./xmlchange PROJECT=$PROJECT
./xmlchange RUN_REFCASE="${CLONENAME}"
./xmlchange RUN_REFDIR="/glade/derecho/scratch/djk2120/archive/${CLONENAME}/rest/1950-01-01-00000"
./xmlchange RUN_REFDATE="1950-01-01"
./xmlchange RUN_STARTDATE="1950-01-01"

# Run for 65 years
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N=5
./xmlchange REST_OPTION="nyears"
./xmlchange REST_N=5
./xmlchange RESUBMIT=12
./xmlchange JOB_WALLCLOCK_TIME=09:30:00 --subgroup case.run

./case.build
./case.submit