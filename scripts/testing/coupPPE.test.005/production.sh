#!/bin/bash

CASEROOTDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/sims"
MEMBERS=(test.005)

for m in "${MEMBERS[@]}"; do

    mem="coupPPE.${m}"
    echo "MEMBER = ${mem}"

    wdir="${CASEROOTDIR}/${mem}"
    mkdir -p "$wdir"

    cp setupAD.sh "${wdir}/"
    cp stabAD.sh "${wdir}/"
    cp setupPAD.sh "${wdir}/"
    cp setupIHIST.sh "${wdir}/"
    cp setupFHIST.sh "${wdir}/"

    cp tether_things/* "${wdir}/"

    sed -i "s/THIS_CASE/${mem}/g" "${wdir}/AD.yml"
    sed -i "s/THIS_CASE/${mem}/g" "${wdir}/PAD.yml"

    echo "./setupAD.sh ${mem}" > "${wdir}/commands.txt"

    cd "$wdir" || exit 1
    qsub -v MEM="$mem" -N "$mem" segment001.job

done
