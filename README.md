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

## B) Training
- Step (7) was done on the cluster.

(7) Training the five individual folds

The slurm scripts "nnunetv2_gpu_training_fold#.sh", with # = 0;1;2;3;4,
needed to be run on the cluster for each fold, e.g. with the command:
```
sbatch nnunetv2_gpu_training_fold#.sh
```

## C) Finding the Best Model
- Step (8) was done on the cluster.

(8) Finding the best model (only done for the sake of completeness)

The slurm script "nnunetv2_cpu_find_best_configuration.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_find_best_configuration.sh
```

## D) Test/Inference




## Folder and File Structure

```text
Overview of the "data" folder after the whole processing pipeline: 
------------------------------------------------------------------

data/
├── nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/
│   ├── imagesTr/PTB_all_energies_1mm_no_background_####_0000.png
│   ├── labelsTr/PTB_all_energies_1mm_no_background_####.png
│   └── dataset.json
├── nnUNet_preprocessed/Dataset010_PTB_all_energies_1mm_no_background_alldata/
│   ├── gt_segmentations/PTB_all_energies_1mm_no_background_####.png
│   ├── nnUNetPlans_2d/
│   │   ├── PTB_all_energies_1mm_no_background_####.b2nd
│   │   ├── PTB_all_energies_1mm_no_background_####.pkl
│   │   └── PTB_all_energies_1mm_no_background_####_seg.b2nd
│   ├── dataset.json
│   ├── dataset_fingerprint.json
│   ├── nnUNetResEncUNetPlans_24G.json
│   └── splits_final.json
└── nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/
    ├── nnUNetTrainer__nnUNetResEncUNetPlans_24G__2d/
    │   ├── crossval_results_folds_0_1_2_3_4/
    │   │   ├── postprocessed/
    │   │   │   ├── dataset.json
    │   │   │   ├── plans.json
    │   │   │   └── PTB_all_energies_1mm_no_background_####.png
    │   │   ├── dataset.json
    │   │   ├── plans.json
    │   │   ├── postprocessing.json     
    │   │   ├── postprocessing.pkl                
    │   │   └── PTB_all_energies_1mm_no_background_####.png 
    │   ├── fold_0/
    │   │   ├── validation/
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.npz
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.pkl
    │   │   │   └── PTB_all_energies_1mm_no_background_####.png
    │   │   ├── checkpoint_best.pth
    │   │   ├── checkpoint_final.pth
    │   │   ├── debug.json     
    │   │   ├── progress.png                  
    │   │   └── training_log_####_#_##_##_##_##.txt      
    │   ├── fold_1/...
    │   ├── fold_2/...
    │   ├── fold_3/...
    │   ├── fold_4/...
    │   ├── dataset.json
    │   ├── dataset_fingerprint.json
    │   └── plans.json
    ├── slurm_logs_find_best_configuration/
    │   ├── nnunetv2_cpu_find_best_configuration.sh
    │   ├── slurm_find_best_configuration_Dataset010_cpu_il_######.err
    │   └── slurm_find_best_configuration_Dataset010_cpu_il_######.out                                   
    ├── slurm_logs_preparation_and_preprocessing/
    │   ├── nnunetv2_cpu_preparation_and_preprocessing.sh
    │   ├── slurm_preparation_Dataset010_dev_cpu_il_######.err
    │   └── slurm_preparation_Dataset010_dev_cpu_il_######.out                                   
    ├── slurm_logs_testing/
    │   ├── nnunetv2_gpu_testing_multiple.sh
    │   ├── slurm_test_Dataset010_gpu_a100_il_######_ss####_##_##.err
    │   ├── slurm_test_Dataset010_gpu_a100_il_######_ss####_##_##.out    
    │   ├── slurm_test_Dataset010_gpu_a100_il_######_all.err 
    │   └── slurm_test_Dataset010_gpu_a100_il_######_all.out                                  
    ├── slurm_logs_training/
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
    │   ├── imagesTs/ss####_##_##/ss####_##_##_###_0000.png
    │   ├── labelsTs/ss####_##_##/ss####_##_##_###.png
    │   ├── labelsPredict/ss####_##_##/
    │   │   ├── ss####_##_##_###.png
    │   │   ├── dataset.json    
    │   │   ├── plans.json
    │   │   └── predict_from_raw_data_args.json
    │   └── labelsPredict_PP/ss####_##_##/
    │       ├── ss####_##_##_###.png
    │       ├── summary_test.json     
    │       └── summary_test_ss####_##_##.xlsx
    ├── inference_information.json        
    └── inference_instructions.txt

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

All the nnU-Net-"stuff" if installed locally is here:
----------------------------------------------------- 
nnUNet/...

If a virtual environment is needed locally:
-------------------------------------------
venv/...
```
