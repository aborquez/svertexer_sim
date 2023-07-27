#!/bin/bash

#
# A example workflow MC->RECO->AOD for a simple pp min bias
# production, targetting test beam conditions.

# make sure O2DPG + O2 is loaded
export O2DPG_ROOT=/storage1/daviddc/alice/O2DPG
export CURRENTDIR=`pwd`

[ ! "${O2DPG_ROOT}" ] && echo "Error: This needs O2DPG loaded" && exit 1
[ ! "${O2_ROOT}" ] && echo "Error: This needs O2 loaded" && exit 1

# ----------- LOAD UTILITY FUNCTIONS --------------------------
. ${O2_ROOT}/share/scripts/jobutils.sh

# ----------- START ACTUAL JOB  -----------------------------

NWORKERS=${NWORKERS:-2}
MODULES="--skipModules ZDC"
SIMENGINE=${SIMENGINE:-TGeant3}
NSIGEVENTS=${NSIGEVENTS:-100}
NTIMEFRAMES=${NTIMEFRAMES:-100}
INTRATE=${INTRATE:-500000}
SYSTEM=${SYSTEM:-pp}
ENERGY=${ENERGY:-13500}
[[ ${SPLITID} != "" ]] && SEED="-seed ${SPLITID}" || SEED=""

echo "Create workflow"
echo "Current directory: ${CURRENTDIR}"
# create workflow
${O2DPG_ROOT}/MC/bin/o2dpg_sim_workflow.py -eCM ${ENERGY} -col ${SYSTEM} -gen pythia8pp -j ${NWORKERS} -ns ${NSIGEVENTS} -tf ${NTIMEFRAMES} -confKey "Diamond.width[2]=6." -e ${SIMENGINE} ${SEED} -mod "--skipModules ZDC" -field -5

echo "Applying your favorite cuts to the workflow"
python3 apply_cuts_to_json.py 

# run workflow
echo "Actually run up to AO2D level"
${O2DPG_ROOT}/MC/bin/o2_dpg_workflow_runner.py -f workflow_mod.json -tt aod --cpu-limit 32 --mem-limit 64000
