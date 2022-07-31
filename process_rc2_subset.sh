# On RSP
source /opt/lsst/software/stack/loadLSST.bash
# From terminal
# Suggest to run processing on rubin-devl machines

# Update weekly version as needed in the line below
source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_30/loadLSST.bash
setup lsst_distrib
eups list -s | grep lsst_distrib

# Users might need to create directory /project/sandbox/$USER
cd /project/sandbox/$USER
git clone https://github.com/lsst-dm/rc2_subset
setup -j -r rc2_subset
echo $RC2_SUBSET_DIR
cd $RC2_SUBSET_DIR

# Run processing steps from nightly CI pipeline through the creation and consolidation of objectTables

export NUMPROC=4

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep1' -i HSC/RC2/defaults --register-dataset-types -o u/$USER/step1

echo "Running step2a on all visits"
pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2a' -i u/$USER/step1 --register-dataset-types -o u/$USER/step2

echo "Running step2b on tract 9813"
pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2b'  -d "tract = 9813 and skymap = 'hsc_rings_v1'" --register-dataset-types -o u/$USER/step2

echo "Running step2c without multiprocessing"
pipetask --long-log run -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2c' --register-dataset-types -o u/$USER/step2

echo "Running step2d on all visits"
pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2d' --register-dataset-types -o u/$USER/step2

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep3' -d "tract = 9813 and skymap = 'hsc_rings_v1' AND patch in (38, 39, 40, 41)" -i u/$USER/step2 --register-dataset-types -o u/$USER/step3