#!/bin/bash
# USAGE: This script performs the steps (10)-(12) of my instructions on one GPU!
# In general GPUs are faster. Only if GPUs are not available,
# one should consider using GPUs where all test dataset are run one after another.
# Note: For each indiviual test dataset an output and error slurm file is created.
# Additionally, an output and error slurm file is created for the whole (multiple test
# datasets) run, which is also sorted by dataset and sample number.
# For 16 test datasets à 300 images, this should take around max. 1 hour.

# #####################TO BE ADAPTED######################################
#SBATCH --time=06:00:00
#SBATCH --mem=16G
#SBATCH --partition=gpu_a100_il
#SBATCH --job-name=test_Dataset010_gpu_a100_il
#SBATCH --output=slurm_logs_testing/slurm_%x_%A_all.out
#SBATCH --error=slurm_logs_testing/slurm_%x_%A_all.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1					

# Train dataset name
TRAIN_DATASET="Dataset010_PTB_all_energies_1mm_no_background_alldata"
# Test dataset names, enable the required ones and disable all not used ones
TEST_DATASETS=(
"2D_Source_FNTD2_100Bilder_2um_many"
"2D_Source_FNTD2_100Bilder_2um_more"
"ss0501_02_03"
"ss0531_32_33"
"ss0601_02_03"
"ss0604_05_06"
"ss0610_11_12"
"ss0613_14_15"
"ss0616_17_18"
"ss0637_38_39"
"ss0643_44_45"
"ss0707_08_09"
"ss0719_20_21"
"ss0731_32_33"
"ss0743_44_45"
"ss0755_56_57"
)

# Train dataset id
DATASET_ID=10
# Dataset name, short
DATASET_NAME="Dataset010"
# Plan
PLAN="nnUNetResEncUNetPlans_24G"
# special Trainer (Epochs, ...)
TRAINER="nnUNetTrainer"
# Configuration
CONFIG="2d"

# #####################DON'T CHANGE#######################################
# Bind-Mount and Container-Mount
DATA_DIR="/home/hd/hd_hd/hd_vd227/Transfer_PC/data"
CONTAINER="/home/hd/hd_hd/hd_vd227/Transfer_PC/nnunetv2.sif"

# If not exist: create folder for slurm logs
mkdir -p slurm_logs_testing

# ################################################################
# TO DO before: steps (1) and (2)
# TO DO before: previous slurm script: preparation and preprocessing (3)-(6)
# TO DO before: previous slurm script: training (7)
# TO DO before: previous slurm script: find best configuration (8)
# TO DO before: step (9), this can be done already in the beginning
# ################################################################

for TEST_DATASET in "${TEST_DATASETS[@]}"; do

    # Log files
    OUT_LOG="slurm_logs_testing/slurm_${SLURM_JOB_NAME}_${SLURM_JOB_ID}_${TEST_DATASET}.out"
    ERR_LOG="slurm_logs_testing/slurm_${SLURM_JOB_NAME}_${SLURM_JOB_ID}_${TEST_DATASET}.err"

    # bind the data directory into the container and run (10) "nnUNetv2_predict"
    singularity exec --nv --bind ${DATA_DIR}:/data ${CONTAINER} \
        nnUNetv2_predict \
        -i /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/imagesTs/${TEST_DATASET} \
        -o /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict/${TEST_DATASET} \
        -d ${DATASET_ID} -p ${PLAN} -tr ${TRAINER} -c ${CONFIG} -device cuda \
        > >(tee -a "${OUT_LOG}") 2> >(tee -a "${ERR_LOG}" >&2)

    # bind the data directory into the container and run (11) nnUNetv2_apply_postprocessing"
    singularity exec --bind ${DATA_DIR}:/data ${CONTAINER} \
        nnUNetv2_apply_postprocessing \
        -i /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict/${TEST_DATASET} \
        -o /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict_PP/${TEST_DATASET} \
        -pp_pkl_file /data/nnUNet_results/${TRAIN_DATASET}/${TRAINER}__${PLAN}__${CONFIG}/crossval_results_folds_0_1_2_3_4/postprocessing.pkl \
        -np 8 \
        -plans_json /data/nnUNet_results/${TRAIN_DATASET}/${TRAINER}__${PLAN}__${CONFIG}/crossval_results_folds_0_1_2_3_4/plans.json \
        -dataset_json /data/nnUNet_results/${TRAIN_DATASET}/${TRAINER}__${PLAN}__${CONFIG}/crossval_results_folds_0_1_2_3_4/dataset.json \
        > >(tee -a "${OUT_LOG}") 2> >(tee -a "${ERR_LOG}" >&2)

    # bind the data directory into the container and run (12) nnUNetv2_evaluate_folder"
    singularity exec --bind ${DATA_DIR}:/data ${CONTAINER} \
        nnUNetv2_evaluate_folder \
        -djfile /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict/${TEST_DATASET}/dataset.json \
        -pfile /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict/${TEST_DATASET}/plans.json \
        -o /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict_PP/${TEST_DATASET}/summary_test.json \
        /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsTs/${TEST_DATASET} \
        /data/nnUNet_results/${TRAIN_DATASET}/test_best_configuration/labelsPredict_PP/${TEST_DATASET} \
        > >(tee -a "${OUT_LOG}") 2> >(tee -a "${ERR_LOG}" >&2)

done

# ###########################
# TO DO afterwards: step (13)
# ###########################
