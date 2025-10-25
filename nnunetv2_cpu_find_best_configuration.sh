#!/bin/bash
# USAGE: This script performs the step (8) of my instructions on the CPU.
# There is no need to specify the folds [0,1,2,3,4], because the default
# already considers these 5 folds.

# #####################TO BE ADAPTED######################################
#SBATCH --time=00:15:00
#SBATCH --mem=8G
#SBATCH --partition=cpu_il
#SBATCH --cpus-per-task=1
#SBATCH --job-name=find_best_configuration_Dataset010_cpu_il
#SBATCH --output=slurm_logs_find_best_configuration/slurm_%x_%A.out
#SBATCH --error=slurm_logs_find_best_configuration/slurm_%x_%A.err
#SBATCH --nodes=1
#SBATCH --ntasks=1			

# Train dataset id
DATASET_ID=10
# Plan
PLAN="nnUNetResEncUNetPlans_24G"
# Configuration
CONFIG="2d"

# #####################DON'T CHANGE#######################################
# Bind-Mount and Container-Mount
DATA_DIR="/home/hd/hd_hd/hd_vd227/Transfer_PC/data"
CONTAINER="/home/hd/hd_hd/hd_vd227/Transfer_PC/nnunetv2.sif"

# If not exist: create folder for slurm logs
mkdir -p slurm_logs_find_best_configuration

# #########################################################################
# TO DO before: steps (1) and (2)
# TO DO before: previous slurm script: preparation and preprocessing (3)-(6)
# TO DO before: previous slurm script: training (7)
# ##########################################################################

# bind the data directory into the container and run (8) "nnUNetv2_find_best_configuration"
singularity exec --bind ${DATA_DIR}:/data ${CONTAINER} nnUNetv2_find_best_configuration ${DATASET_ID} -p ${PLAN} -c ${CONFIG}

# #####################################################################
# TO DO afterwards: next slurm script: training (7)
# TO DO afterwards: next slurm script: find best configuration (8)
# TO DO afterwards: step (9), this can be done already in the beginning
# TO DO afterwards: next slurm script: testing (10)-(12)
# TO DO afterwards: step (13)
# #####################################################################
