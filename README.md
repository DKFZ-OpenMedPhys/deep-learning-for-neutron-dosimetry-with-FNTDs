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
### Step (0) was done locally on the local PC and on the cluster.

(0) Create the container for the cluster

Install Singularity and check the version:
```
sudo apt-get install singularity-container
singularity --version
```
Download the file "nnunetv2.def". With this file the container
"nnunetv2.sif" can be built:
```
sudo singularity build nnunetv2.sif nnunetv2.def

```

Follow the instructions on the homepage of the [BwUniCluster3.0](https://wiki.bwhpc.de/e/BwUniCluster3.0)
in order to get access and afterward, to connect an arbitrary folder on the local PC with the folder "Transfer_PC" on the cluster.
This folder needs to be created. Copy all relevant slurm scripts and the .sif-container to that folder and create all missing folders.
It should look like this:  

### Folder and File Structure on the cluster

```text
Transfer_PC/
├── data/
│   ├── nnUNet_raw/...
│   ├── nnUNet_preprocessed/...
│   └── nnUNet_results/...
├── nnunetv2.sif
├── nnunetv2_cpu_preparation_and_preprocessing.sh
├── nnunetv2_cpu_find_best_configuration.sh
├── nnunetv2_gpu_training_fold0.sh
├── nnunetv2_gpu_training_fold1.sh
├── nnunetv2_gpu_training_fold2.sh
├── nnunetv2_gpu_training_fold3.sh
├── nnunetv2_gpu_training_fold4.sh
├── nnunetv2_gpu_testing_multiple.sh
├── slurm_logs_find_best_configuration
├── slurm_logs_preparation_and_preprocessing
├── slurm_logs_testing
├── slurm_logs_training

```

### Steps (1) and (2) were done manually on the local PC and the resulting files were copied to the corresponding folders on the cluster.

(1) Get the raw images and reference label masks for training

Raw images and binary reference label masks follow a nnU-Net V2
specific format and naming convention. The files after the readout
by the FNTD reader did not fulfill these requirements. In order to
match these requirements, the MATLAB script from [Schmidt et al.
(2025)](https://doi.org/10.1002/mp.17799) was used. The prepared
datasets were uploaded to Mendeley Data. The link can be found in
Thai et al. (2025). The uploaded data can be used as the starting
point. Download the training dataset, copy "imagesTr" and "labelsTr"
into the folder data/nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/
(see "Folder and File Structure" below).

(2) Create the "dataset.json" file

Copy the file "0_custom_generate_dataset_json_010.py"
to the directory ".../nnUNet/nnunetv2/dataset_conversion/".
Adapt the Python file if needed.
Run this Python script in order to create the "dataset.json" file. 

Copy all the files from (1)-(2) to the cluster.

### Steps (3)-(6) were done on the cluster with a slurm script.

(3) Create the "dataset_fingerprint.json" file

(4) Generate the plan

(5) Customize the plan

(6) Apply pre-processing

The slurm script "nnunetv2_cpu_preparation_and_preprocessing.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_preparation_and_preprocessing.sh
```

## B) Training
### Step (7) was done on the cluster with a slurm script.

(7) Training the five individual folds

The slurm scripts "nnunetv2_gpu_training_fold#.sh", with # = 0;1;2;3;4,
needed to be run on the cluster for each fold, e.g. with the command:
```
sbatch nnunetv2_gpu_training_fold#.sh
```

## C) Finding the Best Model
### Step (8) was done on the cluster with a slurm script.

(8) Finding the best model (only done for the sake of completeness)

The slurm script "nnunetv2_cpu_find_best_configuration.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_find_best_configuration.sh
```

## D) Test/Inference

### Step (9) was done manually on the cluster.

(9) Get the raw images and reference label masks for testing

Download the test dataset, copy "imagesTs" and "labelsTs"
into the folder data/nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/test_best_configuration/
and create the same (sub)folders for "labelsPredict/ss####\_##\_##/" and "labelsPredict_PP/ss####\_##\_##/" (see Folder and File Sturcture).

### Steps (10)-(12) were done on the cluster with a slurm script.

(10) Perform inference

(11) Apply post-processing

(12) Evaluation

The slurm script "nnunetv2_cpu_find_best_configuration.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_find_best_configuration.sh
```

## E) Data Analysis

### Step (13) was done on the PC.

(13) Transfer and further analysis

Move all "slurm_logs_..." folder and files into data/results/Dataset010_PTB_all_energies_1mm_no_background_alldata/.
Then transfer everything from the folder "data" to the local PC.


### Folder and File Structure in Detail

```text
Overview of the "data" folder after the whole processing pipeline.
The "(#)" indicates which folders or files were generated in which step (#). 
------------------------------------------------------------------

data/
├── nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/
│   ├── imagesTr/PTB_all_energies_1mm_no_background_####_0000.png (1)
│   ├── labelsTr/PTB_all_energies_1mm_no_background_####.png (1)
│   └── dataset.json (2)
├── nnUNet_preprocessed/Dataset010_PTB_all_energies_1mm_no_background_alldata/
│   ├── gt_segmentations/PTB_all_energies_1mm_no_background_####.png (6)
│   ├── nnUNetPlans_2d/ (6)
│   │   ├── PTB_all_energies_1mm_no_background_####.b2nd
│   │   ├── PTB_all_energies_1mm_no_background_####.pkl
│   │   └── PTB_all_energies_1mm_no_background_####_seg.b2nd
│   ├── dataset.json (4)
│   ├── dataset_fingerprint.json (3)
│   ├── nnUNetResEncUNetPlans_24G.json (4)+(5)
│   └── splits_final.json (7)
└── nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/
    ├── nnUNetTrainer__nnUNetResEncUNetPlans_24G__2d/ (7)
    │   ├── crossval_results_folds_0_1_2_3_4/ (8)
    │   │   ├── postprocessed/
    │   │   │   ├── dataset.json
    │   │   │   ├── plans.json
    │   │   │   └── PTB_all_energies_1mm_no_background_####.png
    │   │   ├── dataset.json
    │   │   ├── plans.json
    │   │   ├── postprocessing.json     
    │   │   ├── postprocessing.pkl                
    │   │   └── PTB_all_energies_1mm_no_background_####.png 
    │   ├── fold_0/ (7)
    │   │   ├── validation/
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.npz
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.pkl
    │   │   │   └── PTB_all_energies_1mm_no_background_####.png
    │   │   ├── checkpoint_best.pth
    │   │   ├── checkpoint_final.pth
    │   │   ├── debug.json     
    │   │   ├── progress.png                  
    │   │   └── training_log_####_#_##_##_##_##.txt      
    │   ├── fold_1/... (7)
    │   ├── fold_2/... (7)
    │   ├── fold_3/... (7)
    │   ├── fold_4/... (7)
    │   ├── dataset.json (7)
    │   ├── dataset_fingerprint.json (7)
    │   └── plans.json (7)
    ├── slurm_logs_find_best_configuration/ (8)
    │   ├── nnunetv2_cpu_find_best_configuration.sh
    │   ├── slurm_find_best_configuration_Dataset010_cpu_il_######.err
    │   └── slurm_find_best_configuration_Dataset010_cpu_il_######.out                                   
    ├── slurm_logs_preparation_and_preprocessing/ (3)-(6)
    │   ├── nnunetv2_cpu_preparation_and_preprocessing.sh
    │   ├── slurm_preparation_Dataset010_dev_cpu_il_######.err
    │   └── slurm_preparation_Dataset010_dev_cpu_il_######.out                                   
    ├── slurm_logs_testing/ (10)-(12)
    │   ├── nnunetv2_gpu_testing_multiple.sh
    │   ├── slurm_test_Dataset010_gpu_a100_il_######_ss####_##_##.err
    │   ├── slurm_test_Dataset010_gpu_a100_il_######_ss####_##_##.out    
    │   ├── slurm_test_Dataset010_gpu_a100_il_######_all.err 
    │   └── slurm_test_Dataset010_gpu_a100_il_######_all.out                                  
    ├── slurm_logs_training/ (7)
    │   ├── nnunetv2_gpu_training_fold0.sh
    │   ├── nnunetv2_gpu_training_fold1.sh
    │   ├── nnunetv2_gpu_training_fold2.sh
    │   ├── nnunetv2_gpu_training_fold3.sh
    │   ├── nnunetv2_gpu_training_fold4.sh
    │   ├── slurm_train_fold0_Dataset010_gpu_h100_il_######.err
    │   ├── slurm_train_fold0_Dataset010_gpu_h100_il_######.out                    
    │   ├── slurm_train_fold1_Dataset010_gpu_h100_il_######.err
    │   ├── slurm_train_fold1_Dataset010_gpu_h100_il_######.out 
    │   ├── slurm_train_fold2_Dataset010_gpu_h100_il_######.err
    │   ├── slurm_train_fold2_Dataset010_gpu_h100_il_######.out 
    │   ├── slurm_train_fold3_Dataset010_gpu_h100_######.err
    │   ├── slurm_train_fold3_Dataset010_gpu_h100_######.out
    │   ├── slurm_train_fold4_Dataset010_gpu_h100_il_######.err     
    │   └── slurm_train_fold4_Dataset010_gpu_h100_il_######.out                                    
    ├── test_best_configuration/
    │   ├── imagesTs/ss####_##_##/ss####_##_##_###_0000.png (9)
    │   ├── labelsTs/ss####_##_##/ss####_##_##_###.png (9)
    │   ├── labelsPredict/ss####_##_##/ (10)
    │   │   ├── ss####_##_##_###.png
    │   │   ├── dataset.json    
    │   │   ├── plans.json
    │   │   └── predict_from_raw_data_args.json
    │   └── labelsPredict_PP/ss####_##_##/ 
    │       ├── ss####_##_##_###.png (11)
    │       ├── summary_test.json (12)
    │       └── summary_test_ss####_##_##.xlsx (13)
    ├── inference_information.json (8)      
    └── inference_instructions.txt (8)

Further scripts for the processing pipeline and evaluation:
-----------------------------------------------------------

scripts/
├── advanced_metrics/advanced_metrics.py
├── extract_number_of_tracks_validationset_template/
│   ├── convert_postprocessed_file_names.py
│   ├── extract_number_of_tracks_validationset_template.py
│   └── number_of_tracks_extended_testset_template.xlsx
├── extract_raw_from_validation/extract_raw_from_validation.py
└── number_of_tracks_extended/
    ├── comparison_MATLAB/
    │   ├── images/ss####_##_##_###_0000.png
    │   ├── images_tracks_counted_extended/ss####_##_##_###_0000.png
    │   ├── labels/ss####_##_##_###.png
    │   ├── labels_tracks_counted_extended/ss####_##_##_###.png
    │   ├── number_of_tracks_comparison_extended.xlsx
    │   └── number_of_tracks_MATLAB_Stefan.ods
    ├── data/Dataset010_PTB_all_energies_1mm_no_background_alldata
    │   ├── test
    │   │   ├── imagesTs/ss####_##_##_###_0000.png
    │   │   ├── imagesTs_extended/ss####_##_##_###_0000.png
    │   │   ├── labelsPredict_PP/ss####_##_##_###.png
    │   │   ├── labelsPredict_PP_extended/ss####_##_##_###.png
    │   │   └── number_of_tracks_testset_extended.xlsx
    │   └── validation
    │       ├── crossval_results_folds_0_1_2_3_4/
    │       │   ├── imagesVal/PTB_all_energies_1mm_no_background_####_0000.png
    │       │   ├── imagesVal_renamed/ss####_##_##_###_0000.png
    │       │   ├── imagesVal_renamed_tracks_extended/ss####_##_##_###_0000.png
    │       │   ├── postprocessed/PTB_all_energies_1mm_no_background_####.png
    │       │   ├── postprocessed_renamed/ss####_##_##_###.png
    │       │   ├── postprocessed_renamed_tracks_extended/ss####_##_##_###.png
    │       │   └── number_of_tracks_extended_validation.xlsx
    │       ├── fold_0/...
    │       ├── fold_1/...
    │       ├── fold_2/...
    │       ├── fold_3/...
    │       └── fold_4/...
    ├── number_of_tracks_extended.py
    └── number_of_tracks_extended_testset_template.xlsx

Files for the cluster:
----------------------
BW_Cluster/nnUNet_files
├── nnunetv2.def
└── nnunetv2.sif

All the nnU-Net-"stuff" installed on local PC:
----------------------------------------------------- 
nnUNet/
├── ...
└── nnunetv2/dataset_conversion/0_custom_generate_dataset_json_010.py (2)


Virtual enviroment on local PC:
-------------------------------------------
venv/...
```
