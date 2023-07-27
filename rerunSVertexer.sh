# script to run multiple itstpc matcher tests
export O2DPG_ROOT=/storage1/daviddc/alice/O2DPG

nprocesses=`cat NumberOfProcessesAnalysis`

# ----------- LOAD UTILITY FUNCTIONS --------------------------
. ${O2_ROOT}/share/scripts/jobutils.sh

# ----------- START ACTUAL JOB  -----------------------------
# Just set the stage (won't really do everything again)
NWORKERS=${NWORKERS:-4}
MODULES="--skipModules ZDC"
SIMENGINE=${SIMENGINE:-TGeant3}
NSIGEVENTS=${NSIGEVENTS:-200}
NTIMEFRAMES=${NTIMEFRAMES:-100}
INTRATE=${INTRATE:-500000}
SYSTEM=${SYSTEM:-pp}
ENERGY=${ENERGY:-13500}
[[ ${SPLITID} != "" ]] && SEED="-seed ${SPLITID}" || SEED=""

for i in {000..009}
do
  for j in {1..100}
  do
    echo "Preparing groundwork of masterjob ${i}, TF ${j}..."
    echo "Deleting superfluous files..."
    # now editing the content of the actual simulations accordingly
    rm /storage1/daviddc/xigun/${i}/tf${j}/o2secondary-vertexing-workflow_configuration.ini
    rm /storage1/daviddc/xigun/${i}/tf${j}/o2_secondary_vertex.root
    rm /storage1/daviddc/xigun/${i}/tf${j}/svfinder_${j}.log_time
    rm /storage1/daviddc/xigun/${i}/tf${j}/svfinder_${j}.log
    rm /storage1/daviddc/xigun/${i}/tf${j}/svfinder_${j}.log_done
    rm /storage1/daviddc/xigun/${i}/tf${j}/AO2D.root
    rm /storage1/daviddc/xigun/${i}/tf${j}/dpl-config.json
    rm /storage1/daviddc/xigun/${i}/tf${j}/aod_${j}.log_time
    rm /storage1/daviddc/xigun/${i}/tf${j}/aod_${j}.log
    rm /storage1/daviddc/xigun/${i}/tf${j}/aod_${j}.log_done
  done

  echo "Finished cleanup of files"
  CURRENTPATH=$(pwd)
  echo "Will re-execute some steps of simulation inside this shell"  
  cd /storage1/daviddc/xigun/${i}
  echo "Now in active directory: $(pwd)"

  echo "Create workflow..."
  echo "Current directory: ${CURRENTDIR}"
  # create workflow
  ${O2DPG_ROOT}/MC/bin/o2dpg_sim_workflow.py -eCM ${ENERGY} -col ${SYSTEM} -gen external -j ${NWORKERS} -ns ${NSIGEVENTS} -tf ${NTIMEFRAMES} -confKey "Diamond.width[2]=6." -e ${SIMENGINE} ${SEED} -mod "--skipModules ZDC" -ini /storage1/daviddc/xigun/configPythia.ini -field -5

  echo "Applying your favorite cuts to the workflow"
  python3 apply_cuts_to_json.py 
  echo "Actually run"
  ${O2DPG_ROOT}/MC/bin/o2_dpg_workflow_runner.py -f workflow_mod.json -tt aod --cpu-limit 64
  echo "Merging into final AO2D file now"
  ls tf*/AO2D.root > aodmergelist.txt
  ${O2PHYSICS_ROOT}/bin/o2-aod-merger --input aodmergelist.txt --output AO2D_sel${sel}.root
  echo "Storing AO2D in side file: "
  ls -ltr AO2D_sel${sel}.root

  echo "Returning to directory: ${CURRENTPATH}"
  cd ${CURRENTPATH} 
  echo "Now in active directory: $(pwd)"
done
echo "Enjoy! I should be done!"
