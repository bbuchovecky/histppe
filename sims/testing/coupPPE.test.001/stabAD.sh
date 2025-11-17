
MEM=$1
# MEM="coupPPE.000"
SDIR="/glade/work/djk2120/ctsm_tether/tools/tether/old_spinup"
WDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims/${MEM}"
case=$(<case.txt)

python "${SDIR}/spinup_stability.py" AD.yml
status=$?
echo "status: ${status}"

if [[ "${status}" == "11" ]]; then
    echo "AD needs more spinup"
    cd $case
    ./xmlchange CONTINUE_RUN=True
    ./xmlchange STOP_N=20
    ./xmlchange JOB_WALLCLOCK_TIME="4:00:00" --subgroup case.run
    cd $WDIR
    echo $case>case.txt
    # echo "./stabAD.sh">commands.txt
    echo "./stabAD.sh ${MEM}">commands.txt
elif [[ "$status" == "0" ]]; then
    echo "AD spinup appears sufficient"
    # ./setupPAD.sh
    ./setupPAD.sh $MEM
else
    echo "something looks wrong, halting tether"
    rm commands.txt
fi
