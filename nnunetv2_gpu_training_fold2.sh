#!/bin/bash
# USAGE: This script performs the step (7) of my instructions on the GPU!
# For this step never use CPUs, since this is one big task (no parallel computation).
# Regarding training time, e.g. training on 1st fold with 100 epochs takes max. 30 min.
# Linearly upscaling, to run on all 5 folds and 1000 epochs default, should take
# around max. 10 x 5 x 30 min = 1500 min = 25 h = 1 d,
# maybe using higher batchsize, will result in higher runtime of max. 2 d?
# REPAET THIS SCRIPT FOR ALL 5 FOLDS INDIVIDUALLY, using the --dependency slurm 
# command, such that fold 1,2,3,4 only run after fold 0 was succesful.

# #####################TO BE ADAPTED######################################
#SBATCH --time=40:00:00
#SBATCH --mem=32G
#SBATCH --partition=gpu_h100_il
#SBATCH --job-name=train_fold2_Dataset010_gpu_h100_il
#SBATCH --output=slurm_logs_training/slurm_%x_%A.out
#SBATCH --error=slurm_logs_training/slurm_%x_%A.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1						

# Plan
PLAN="nnUNetResEncUNetPlans_24G"
# Train dataset id
DATASET_ID=10
# Configuration
CONFIG="2d"
# Folds
FOLD=2

# #####################DON'T CHANGE#######################################
# Bind-Mount and Container-Mount
DATA_DIR="/home/hd/hd_hd/hd_vd227/Transfer_PC/data"
CONTAINER="/home/hd/hd_hd/hd_vd227/Transfer_PC/nnunetv2.sif"

# If not exist: create folder for slurm logs
mkdir -p slurm_logs_training

# ##########################################################################
# TO DO before: steps (1) and (2)
# TO DO before: previous slurm script: preparation and preprocessing (3)-(6)
# ##########################################################################

# bind the data directory into the container and run (7) "nnUNetv2_train"
singularity exec --nv --bind ${DATA_DIR}:/data ${CONTAINER} nnUNetv2_train -p ${PLAN} --npz ${DATASET_ID} ${CONFIG} ${FOLD}

# #####################################################################
# TO DO afterwards: next slurm script: find_best_configuration (8)
# TO DO afterwards: step (9), this can be done already in the beginning
# TO DO afterwards: next slurm script: testing (10)-(12)
# TO DO afterwards: step (13)
# #####################################################################
