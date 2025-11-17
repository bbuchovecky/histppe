#!/bin/bash

MEM="coupPPE-hist.014"
CASEROOTBASE="/glade/u/home/bbuchovecky/cesm_runs/cases/coupPPE-hist/test_simulations/"
CESMROOT="/glade/work/djk2120/cesm2.1.5/"
PROJECT=UWAS0155
CLONENAME="f.e21.FHIST_BGC.f09_f09.ersstv5.cplhist.ext"
CASENAME="f.e21.FHIST_BGC.f09_f09.ersstv5."$MEM".1950init"
# NAMELISTS="/glade/u/home/djk2120/vp/scripts/namelists/FHIST_EXT/"
# SCRATCHBASE=/glade/derecho/scratch/djk2120


cloneroot=/glade/u/home/djk2120/vp/sims/$CLONENAME
caseroot=$CASEROOTBASE$CASENAME
echo $caseroot


# create case from clone
cd $CESMROOT/cime/scripts
./create_clone --case $caseroot --clone $cloneroot --cime-output-root /glade/derecho/scratch/bbuchovecky
cd $caseroot

#adjust pelayout
# ./xmlchange NTASKS_CPL=256
# ./xmlchange NTASKS_ATM=256
# ./xmlchange NTASKS_LND=256
# ./xmlchange NTASKS_ICE=256
# ./xmlchange NTASKS_OCN=256
# ./xmlchange NTASKS_ROF=256
# ./xmlchange NTASKS_GLC=256
# ./xmlchange NTASKS_WAV=256

./case.setup --reset


# exclude cplhist
echo "! clearing cpl namelist" > user_nl_cpl


#apply sourcemods for parameter change
if [ $MEM == 'default' ]; then
    echo $MEM": No extra SourceMods"
else
    SOURCEMODS="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5/srcmods/perturbed/"
    cp $SOURCEMODS$MEM"/"* ./SourceMods/src.clm/
fi


#point to refdir
./xmlchange RUN_TYPE=hybrid
./xmlchange PROJECT=$PROJECT
./xmlchange RUN_REFCASE=f.e21.FHIST_BGC.f09_f09.ersstv5.cplhist
./xmlchange RUN_REFDIR=/glade/derecho/scratch/djk2120/archive/f.e21.FHIST_BGC.f09_f09.ersstv5.cplhist/rest/1950-01-01-00000
./xmlchange RUN_REFDATE="1950-01-01"
./xmlchange RUN_STARTDATE="1950-01-01"
./xmlchange GET_REFCASE=True

#run for 5 years
./xmlchange CONTINUE_RUN=False
./xmlchange STOP_N=3
./xmlchange STOP_OPTION=nyears
./xmlchange RESUBMIT=0
./xmlchange JOB_WALLCLOCK_TIME="9:00:00" --subgroup case.run
# ./xmlchange JOB_PRIORITY="premium" #just for first five years


# add land initial conditions
HDIR=/glade/derecho/scratch/djk2120/archive/IHistClm50Bgc.CPLHIST.coupPPE-hist.014.HIST2/rest/1950-01-01-00000
LINIT=IHistClm50Bgc.CPLHIST.coupPPE-hist.014.HIST2.clm2.r.1950-01-01-00000.nc
finidat=$HDIR"/"$LINIT
echo -e "finidat='"$finidat"'" >> user_nl_clm

#build case
./case.build

./case.submit
