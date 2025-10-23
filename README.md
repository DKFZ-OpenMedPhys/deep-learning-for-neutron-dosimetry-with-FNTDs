# Thai_et_al_2025

## General Information 

This repository contains all the used files in Thai et al.
(2025), including the container, the cluster-relevant codes,
the Python scripts to get from the raw data input to the
final output, and the evaluation scripts.

This README gives detailed instructions for reproducing the
study and requires an already functioning setup, e.g. virtual
enviroment, the installed nnU-Net V2, VS code, and more.
Some steps were done locally on the PC and some on the cluster.

## A) Data Preparation and Pre-Processing
- Steps (1) and (2) were done manually on the local PC.

(1) Getting the raw images and reference label masks

Raw images and binary reference label masks follow a nnU-Net V2
specific format and naming convention. The files after the readout
by the FNTD reader did not fulfill these requirements. In order to
match these requirements, the MATLAB script from [Schmidt et al.
(2025)](https://doi.org/10.1002/mp.17799) was used. The prepared
datasets were uploaded to Mendeley Data. The link can be found in
Thai et al. (2025). The uploaded data can be used as the starting
point.

(2) Creating the "dataset.json" file

Copy the file "0_custom_generate_dataset_json_010.py"
to go the directory ".../nnUNet/nnunetv2/dataset_conversion/".
Adapt the Python file if needed.
Run this Python script in order to create the "dataset.json" file 

- Steps (3)-(6) were done on the cluster.

(3) Create the "dataset_fingerprint.json" file

(4) Generate the plan

(5) Customize the plan

(6) Apply the pre-processing

The slurm script "nnunetv2_cpu_preparation_and_preprocessing.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_preparation_and_preprocessing.sh
```

## Training
- Step (7) was done on the cluster.

(7) Training the five individual folds

The slurm scripts "nnunetv2_gpu_training_fold#.sh", with # = 0;1;2;3;4,
needed to be run on the cluster for each fold, e.g. with the command:
```
sbatch nnunetv2_gpu_training_fold#.sh
```

## Finding the Best Model
- Step (8) was done on the cluster.

(8) Finding the best model (only done for the sake of completeness)

The slurm script "nnunetv2_cpu_find_best_configuration.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_find_best_configuration.sh
```

...

