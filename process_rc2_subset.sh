# Suggest to run processing on rubin-devl machines on S3DF machines at USDF

### Set up LSST Science Pipelines ###

# Example commands below verified using w_2023_15
source /sdf/group/rubin/sw/tag/w_2023_15/loadLSST.bash
# Alternatively, use the latest weekly version
# source /sdf/group/rubin/sw/w_latest/loadLSST.bash
setup lsst_distrib
eups list -s | grep lsst_distrib

### Clone and set up rc2_subset ###

# Suggest to create a working directory for bootcamp exercises such as 
# /sdf/group/rubin/user/$USER/bootcamp_2023
# See https://developer.lsst.io/usdf/storage.html#storage-locations
cd /sdf/group/rubin/user/$USER/bootcamp_2023

git clone https://github.com/lsst-dm/rc2_subset
setup -j -r rc2_subset
echo $RC2_SUBSET_DIR
cd $RC2_SUBSET_DIR

### Run processing steps from nightly CI pipeline through the creation and consolidation of objectTables ###

export NUMPROC=4

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${DRP_PIPE_DIR}'/pipelines/HSC/DRP-RC2_subset.yaml#nightlyStep1' -i HSC/RC2/defaults --register-dataset-types -o u/$USER

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${DRP_PIPE_DIR}'/pipelines/HSC/DRP-RC2_subset.yaml#nightlyStep2a' --register-dataset-types -o u/$USER

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${DRP_PIPE_DIR}'/pipelines/HSC/DRP-RC2_subset.yaml#nightlyStep2b' -d "tract = 9813 and skymap = 'hsc_rings_v1'" --register-dataset-types -o u/$USER

pipetask --long-log run -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${DRP_PIPE_DIR}'/pipelines/HSC/DRP-RC2_subset.yaml#nightlyStep2c' --register-dataset-types -o u/$USER

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${DRP_PIPE_DIR}'/pipelines/HSC/DRP-RC2_subset.yaml#nightlyStep2d' --register-dataset-types -o u/$USER

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${DRP_PIPE_DIR}'/pipelines/HSC/DRP-RC2_subset.yaml#nightlyStep3' -d "tract = 9813 and skymap = 'hsc_rings_v1' AND patch in (38, 39, 40, 41)" --register-dataset-types -o u/$USER
