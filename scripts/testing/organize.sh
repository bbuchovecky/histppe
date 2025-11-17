#!/bin/bash

MEM="coupPPE.014"
TEST_MEM="coupPPE.test.005"

PERTDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/pert"
TEST_PERTDIR="${PERTDIR}/testing/${TEST_MEM}"

SCRIPTDIR="/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/scripts"
TEST_SCRIPTDIR="${SCRIPTDIR}/testing/${TEST_MEM}"
SCRIPTS=(production.sh setupAD.sh setupFHIST.sh setupIHIST.sh setupPAD.sh stabAD.sh stabPAD.sh)

CPLHISTDIR="f.e21.FHIST_BGC.f19_f19_mg17.historical.coupPPE.cplhist"
TEST_CPLHISTDIR="f.e21.FHIST_BGC.f19_f19_mg17.coupPPE-hist.cplhist"


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


if [ ! -d "$TEST_PERTDIR" ]; then
    mkdir -p "$TEST_PERTDIR"
else
    echo "${TEST_PERTDIR} already exists, remove before running this script."
    exit 1
fi


# create necessary subdirectories
mkdir -p "${TEST_PERTDIR}/nlmods"
mkdir -p "${TEST_PERTDIR}/paramfiles"
mkdir -p "${TEST_PERTDIR}/srcmods/perturbed"


# copy over the perturbation files
cp -r "${PERTDIR}/nlmods/${MEM}.txt" "${TEST_PERTDIR}/nlmods/${TEST_MEM}.txt"
cp -r "${PERTDIR}/paramfiles/${MEM}.nc" "${TEST_PERTDIR}/paramfiles/${TEST_MEM}.nc"
cp -r "${PERTDIR}/srcmods/perturbed/all" "${TEST_PERTDIR}/srcmods/perturbed/all"
cp -r "${PERTDIR}/srcmods/perturbed/${MEM}" "${TEST_PERTDIR}/srcmods/perturbed/${TEST_MEM}"


if [ ! -d "$TEST_SCRIPTDIR" ]; then
    mkdir -p "$TEST_SCRIPTDIR"
else
    echo "${TEST_SCRIPTDIR} already exists, remove before running this script."
    exit 1
fi


# copy over the tether scripts and edit paths
for script in "${SCRIPTS[@]}"; do

    iscript="${SCRIPTDIR}/${script}"
    oscript="${TEST_SCRIPTDIR}/${script}"
    cp "$iscript" "$oscript"

    sed -i "s:${PERTDIR}:${TEST_PERTDIR}:g" "$oscript"
    sed -i "s:${CPLHISTDIR}:${TEST_CPLHISTDIR}:g" "$oscript"

    sed -i "s:^MEMBERS=\(.*\):MEMBERS=(${TEST_MEM#*.}):g" "$oscript"

done


cp -r "${SCRIPTDIR}/tether_things/" "${TEST_SCRIPTDIR}/tether_things/"


sed -i "s/THIS_CASE/${TEST_MEM}/g" "${TEST_SCRIPTDIR}/tether_things/AD.yml"
sed -i "s/THIS_CASE/${TEST_MEM}/g" "${TEST_SCRIPTDIR}/tether_things/PAD.yml"

echo "$MEM" > "${TEST_SCRIPTDIR}/README.txt"
echo "$MEM" > "${TEST_PERTDIR}/README.txt"
