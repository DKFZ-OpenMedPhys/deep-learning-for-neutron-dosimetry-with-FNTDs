#!/bin/bash
# USAGE: This script performs the steps (3),(4),(6) of my instructions on the CPU!
# This takes doesn't take much time (~ 1min), therefore performing on the GPU with
# the other script is also possible. So just look which partition is free with
# "sinfo_t_idle" on the cluster.
# This script usually takes max. 2 min.

# #####################TO BE ADAPTED######################################
#SBATCH --time=00:10:00
#SBATCH --mem=8G
#SBATCH --partition=dev_cpu_il
#SBATCH --cpus-per-task=1
#SBATCH --job-name=preparation_Dataset010_dev_cpu_il
#SBATCH --output=slurm_logs_preparation_and_preprocessing/slurm_%x_%A.out
#SBATCH --error=slurm_logs_preparation_and_preprocessing/slurm_%x_%A.err
#SBATCH --nodes=1
#SBATCH --ntasks=1			

# Train dataset id
DATASET_ID=10
# select (ResEnc)Plan
SELECTPLAN="nnUNetPlannerResEncL"
# corresponding GPU limit
GPU_LIMIT=24
# overwrite plan name
PLAN="nnUNetResEncUNetPlans_24G"
# Configuration
CONFIG="2d"

# #####################DON'T CHANGE#######################################
# Bind-Mount and Container-Mount
DATA_DIR="/home/hd/hd_hd/hd_vd227/Transfer_PC/data"
CONTAINER="/home/hd/hd_hd/hd_vd227/Transfer_PC/nnunetv2.sif"

# If not exist: create folder for slurm logs
mkdir -p slurm_logs_preparation_and_preprocessing

# ###############################
# TO DO before: steps (1) and (2) 
# ###############################

# bind the data directory into the container and run (3) "nnUNetv2_extract_fingerprint"
singularity exec --bind ${DATA_DIR}:/data ${CONTAINER} nnUNetv2_extract_fingerprint -d ${DATASET_ID} --verify_dataset_integrity

# bind the data directory into the container and run (4) "nnUNetv2_plan_experiment"
singularity exec --bind ${DATA_DIR}:/data ${CONTAINER} nnUNetv2_plan_experiment -d ${DATASET_ID} -pl ${SELECTPLAN} -gpu_memory_target ${GPU_LIMIT} -overwrite_plans_name ${PLAN}

# ###########################################################################
# skip step (5), because we take the recommended plan, so no customized plan
# ###########################################################################

# bind the data directory into the container and run (6) "nnUNetv2_preprocess"
singularity exec --bind ${DATA_DIR}:/data ${CONTAINER} nnUNetv2_preprocess -d ${DATASET_ID} -plans_name ${PLAN} -c ${CONFIG}

# #####################################################################
# TO DO afterwards: next slurm script: training (7)
# TO DO afterwards: next slurm script: find best configuration (8)
# TO DO afterwards: step (9), this can be done already in the beginning
# TO DO afterwards: next slurm script: testing (10)-(12)
# TO DO afterwards: step (13)
# #####################################################################
