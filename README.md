# Thai_et_al_2025

## A) General Information about this Repository

This repository contains some used files in Thai et al.
(2025).
In this README you can find detailed descriptions regarding:
- Instructions for reproducing this study from data input to final output of the nnU-Net;
- Setting up a container for the cluster BwUniCluster3.0;
- Some data analysis scripts regarding metrics.

Some of my steps were done locally on the PC and some on the cluster.
First, the folder and file structure on the local PC and the cluster will be explained, before the workflow is described.

## B) Folder and File Structure on the Local PC

If you are running the nnU-Net V2 locally on you PC, an already functioning setup is required.
It includes for instance, a virtual environment (venv), the installed nnU-Net V2, the "data" folder, VS code, etc.
On my local PC, all those folders were located on the same level, as shown here: 
```text 
├── venv/...
├── nnUNet/...
└── data/
    ├── nnUNet_raw/...
    ├── nnUNet_preprocessed/...
    └── nnUNet_results/...
```
The instructions on how to set up the nnU-Net and the "data" folder is described in the Git repository of [Isensee et al. (2021)](https://github.com/MIC-DKFZ/nnUNet).

## C) Folder and File Structure on the Cluster

Follow the instructions on the homepage of [BwUniCluster3.0](https://wiki.bwhpc.de/e/BwUniCluster3.0)
to get access first.

Then connect an arbitrary folder on your local PC with the folder "Transfer_PC" on the cluster, which you can create.
This allows you to transfer data between the cluster and your local PC.

You will need a container for this cluster. This can be done locally on your PC.
First, install Singularity and check the version with:
```
sudo apt-get install singularity-container
singularity --version
```
Download the file "nnunetv2.def" from this repository. With this file the container
"nnunetv2.sif" can be built:
```
sudo singularity build nnunetv2.sif nnunetv2.def

```
Download all slurm scripts (file ending ".sh", mentioned below) from this repository.
Transfer them, together with container "nnunetv2.sif", to the cluster into the folder "Transfer_PC". 
Create all missing folders.
It should look like this:
```text
Transfer_PC/
├── data/
│   ├── nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/...
│   ├── nnUNet_preprocessed/Dataset010_PTB_all_energies_1mm_no_background_alldata/...
│   └── nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/...
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
└── slurm_logs_training
```

## D) Step by step instructions for the nnU-Net workflow 

Here, the whole pipeline from raw data input to final output and evaluation is described.
In the section "E) Detailed Folder and File Structure" below, the whole data structure can be seen in full depth.
Every created file or folder is linked by "(#)" to the corresponding step(s) in the workflow.
There, you can have a better overview in which step(s), which files or folders where created or required.

### I) Data Preparation and Pre-Processing

#### Steps (1)-(2): manually on the local PC and cluster.

##### (1) Get the raw images and reference label masks for training

Raw images and binary reference label masks follow a nnU-Net V2
specific format and naming convention. The files, after the readout
by the FNTD reader, did not fulfill these requirements. In order to
match these requirements, the MATLAB script from [Schmidt et al.
(2025)](https://doi.org/10.1002/mp.17799) was used. The prepared
datasets were uploaded to [Mendeley Data](10.17632/pwh8tph424.1).
You can download them and use them as your starting point.

Download the training dataset.
Copy "imagesTr" and "labelsTr" into the folder "data/nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/"
on your local PC.

##### (2) Create the "dataset.json" file

Download "0_custom_generate_dataset_json_010.py" from this repository.
Copy it to the directory "nnUNet/nnunetv2/dataset_conversion/" on your local PC.
Adapt the Python file if needed.
Run this Python script to create the "dataset.json" file. 

Copy all the folders and files from steps (1) and the "dataset.json" file from step (2) to the cluster, so you can continue working with the cluster.

#### Steps (3)-(6): on the cluster with a slurm script.

##### (3) Create the "dataset_fingerprint.json" file

##### (4) Generate the plan

##### (5) Customize the plan

##### (6) Apply pre-processing

The slurm script "nnunetv2_cpu_preparation_and_preprocessing.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_preparation_and_preprocessing.sh
```

### II) Training
#### Step (7): on the cluster with a slurm script.

##### (7) Training the five individual folds

The five different slurm scripts "nnunetv2_gpu_training_fold#.sh", with # = 0;1;2;3;4,
needed to be run on the cluster for each fold, e.g. with the command:
```
sbatch nnunetv2_gpu_training_fold#.sh
```

### III) Finding the Best Model
#### Step (8): on the cluster with a slurm script.

##### (8) Finding the best model

The slurm script "nnunetv2_cpu_find_best_configuration.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_cpu_find_best_configuration.sh
```

### IV) Test/Inference

#### Step (9): manually on the cluster.

##### (9) Get the raw images and reference label masks for testing

Download the test dataset from [Mendeley Data](10.17632/pwh8tph424.1), copy "imagesTs" and "labelsTs"
into the folder "data/nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/test_best_configuration/" on the cluster
and create the same (sub)folders for "labelsPredict/ss####\_##\_##/" and "labelsPredict_PP/ss####\_##\_##/" (see "E) Detailed Folder and File Sturcture").

#### Steps (10)-(12): on the cluster with a slurm script.

##### (10) Perform inference

##### (11) Apply post-processing

##### (12) Evaluation/Creating a summary.json file

The slurm script "nnunetv2_gpu_testing_multiple.sh"
needs to be run on the cluster, e.g. with the command:
```
sbatch nnunetv2_gpu_testing_multiple.sh
```

### V) Data Transfer

#### Step (13): manually on the cluster and PC.

##### (13) Transfer

Move the slurm scripts to their corresponding "slurm_logs_..." folders.
Move all "slurm_logs_..." folders to "data/results/Dataset010_PTB_all_energies_1mm_no_background_alldata/".
Transfer everything from the cluster folder "data" to the local PC folder "data".
Now you have everything on the local PC and can do further analysis.


## E) Detailed Folder and File Structure
The "(#)" indicates which folders or files were generated or used in which step (#). 
```text
nnUNet/
├── ...
└── nnunetv2/dataset_conversion/0_custom_generate_dataset_json_010.py (2)

data/
├── nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/
│   ├── imagesTr/PTB_all_energies_1mm_no_background_####_0000.png (1)
│   ├── labelsTr/PTB_all_energies_1mm_no_background_####.png (1)
│   └── dataset.json (2)
├── nnUNet_preprocessed/Dataset010_PTB_all_energies_1mm_no_background_alldata/
│   ├── dataset_fingerprint.json (3)
│   ├── dataset.json (4)
│   ├── nnUNetResEncUNetPlans_24G.json (4)+(5)
│   ├── gt_segmentations/PTB_all_energies_1mm_no_background_####.png (6)
│   ├── nnUNetPlans_2d/ (6)
│   │   ├── PTB_all_energies_1mm_no_background_####.b2nd
│   │   ├── PTB_all_energies_1mm_no_background_####.pkl
│   │   └── PTB_all_energies_1mm_no_background_####_seg.b2nd
│   └── splits_final.json (7)
└── nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/
    ├── nnUNetTrainer__nnUNetResEncUNetPlans_24G__2d/
    │   ├── dataset_fingerprint.json (7)
    │   ├── dataset.json (7)
    │   ├── plans.json (7)
    │   ├── fold_0/ 
    │   │   ├── validation/
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.npz (7)
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.pkl (7)
    │   │   │   ├── PTB_all_energies_1mm_no_background_####.png (7)
    │   │   │   ├── summary.json (7)
    │   │   │   └── summary_validation.xlsx (14)
    │   │   ├── checkpoint_best.pth
    │   │   ├── checkpoint_final.pth
    │   │   ├── debug.json     
    │   │   ├── progress.png                  
    │   │   └── training_log_####_#_##_##_##_##.txt (16)      
    │   ├── fold_1/... (7)
    │   ├── fold_2/... (7)
    │   ├── fold_3/... (7)
    │   ├── fold_4/... (7)
    │   └── crossval_results_folds_0_1_2_3_4/ (8)
    │       ├── postprocessed/
    │       │   ├── dataset.json
    │       │   ├── plans.json
    │       │   └── PTB_all_energies_1mm_no_background_####.png
    │       ├── dataset.json
    │       ├── plans.json
    │       ├── postprocessing.json     
    │       ├── postprocessing.pkl                
    │       └── PTB_all_energies_1mm_no_background_####.png 
    ├── inference_information.json (8)      
    ├── inference_instructions.txt (8)
    ├── test_best_configuration/
    │   ├── imagesTs/ss####_##_##/ss####_##_##_###_0000.png (9)+(15)
    │   ├── labelsTs/ss####_##_##/ss####_##_##_###.png (9)
    │   ├── labelsPredict/ss####_##_##/ (10)
    │   │   ├── ss####_##_##_###.png
    │   │   ├── dataset.json    
    │   │   ├── plans.json
    │   │   └── predict_from_raw_data_args.json
    │   └── labelsPredict_PP/ss####_##_##/ 
    │       ├── ss####_##_##_###.png (11)+(15)
    │       ├── summary_test.json (12)
    │       └── summary_test_ss####_##_##.xlsx (14)    
    ├── slurm_logs_preparation_and_preprocessing/ (3)-(6)
    │   ├── nnunetv2_cpu_preparation_and_preprocessing.sh
    │   ├── slurm_preparation_Dataset010_dev_cpu_il_######.err
    │   └── slurm_preparation_Dataset010_dev_cpu_il_######.out                                   
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
    ├── slurm_logs_find_best_configuration/ (8)
    │   ├── nnunetv2_cpu_find_best_configuration.sh
    │   ├── slurm_find_best_configuration_Dataset010_cpu_il_######.err
    │   └── slurm_find_best_configuration_Dataset010_cpu_il_######.out                                   
    └── slurm_logs_testing/ (10)-(12)
        ├── nnunetv2_gpu_testing_multiple.sh
        ├── slurm_test_Dataset010_gpu_a100_il_######_ss####_##_##.err
        ├── slurm_test_Dataset010_gpu_a100_il_######_ss####_##_##.out    
        ├── slurm_test_Dataset010_gpu_a100_il_######_all.err 
        └── slurm_test_Dataset010_gpu_a100_il_######_all.out                                  
```
## F) Further Data Analysis
The performance of binary segmentation and dosimetry was evaluated by different metrics.
These two Python scripts can be downloaded from this repository. It is recommended to follow the same file sturcture as shown here:
```text
scripts/
├── advanced_metrics/advanced_metrics.py (14)
├── number_of_tracks_extended/ (15)
│   ├── data/Dataset010_PTB_all_energies_1mm_no_background_alldata
│   │   └── test
│   │       ├── imagesTs/ss####_##_##_###_0000.png
│   │       ├── imagesTs_extended/ss####_##_##_###_0000.png
│   │       ├── labelsPredict_PP/ss####_##_##_###.png
│   │       ├── labelsPredict_PP_extended/ss####_##_##_###.png
│   │       └── number_of_tracks_testset_extended.xlsx
│   └── number_of_tracks_extended.py
└── plots_paper/ (16)
    ├── plots_paper.ipnyb 
    ├── fold1_training_log_####_##_##_##_##_##.txt
    ├── fold2_training_log_####_##_##_##_##_##.txt
    ├── fold3_training_log_####_##_##_##_##_##.txt
    ├── fold4_training_log_####_##_##_##_##_##.txt
    ├── fold5_training_log_####_##_##_##_##_##.txt
    ├── AmBe_spec_high_activity.txt
    └── 09_ML_experiment_overview_250905.xlsx

```
#### Steps (14)-(16): manually on the local PC.

##### (14) Binary segmentation performance with: advanced_metrics.py

This script is used for the calculation of the adapted metrics regarding the performance of binary segmentation. 

Input:
- summary.json (7)
- summary_test.json (12) 

Output:
- summary_validation.xlsx (14)
- summary_test_ss####\_##\_##.xlsx (14) 

It has to be applied for the validation dataset and for each test sub-dataset.
You can copy the summary.json (7) or summary_test.json (12) into "scripts/advanced_metrics/",
run the script, get summary_validation.xlsx (14) or summary_test_ss####_##_##.xlsx (14) as output and copy them 
back to the original path as shown in "E) Detailed Folder and File Structure".

##### (15) Dosimetry performance with: number_of_tracks_extended.py

This script is used for creating the instance masks and overlay images from the binary label masks for the test dataset.
It also counts the number of tracks.

Input:
- imagesTs/ss####\_##\_##/ss####\_##\_##\_###\_0000.png (15)
- labelsPredict_PP/ss####\_##\_##/ss####\_##\_##\_###.png (15)  

Output:
- imagesTs_tracks_extended (15)
- labelsPredict_PP_extended (15)
- number_of_tracks_extended.xlsx (15)

It has to be applied for each test sub-dataset.
You can copy the mentioned input into "scripts/number_of_tracks_testset_extended/",
run the script, get an excel "number_of_tracks_extended.xlsx" (15), one by one for each subset, and copy the results into the summary excel sheet "number_of_tracks_testset_extended.xlsx" that contains all subsets.

##### (16) Creating the plots/results with: plots_paper.ipnyb

The results from the data analysis in (14)-(15) were summarized in the overall excel sheet "09_ML_experiment_overview_250905.xlsx".
This sheet is stored in the folder "plots_paper/" together with the five different log files from "nnUNet_results/Dataset010_PTB_all_energies_1mm_no_background_alldata/nnUNetTrainer__nnUNetResEncUNetPlans_24G__2d/fold#", which were renamed to "fold#\_training\_log\_####\_##\_##\_##\_##\_##.txt".
Also the file "AmBe_spec_high_activity.txt" (241Am-Be spectrum) is stored in the same folder.

The notebook "plots_paper.ipnyb" uses all these files as input. Running the notebook will create plots and results from "Thai et al. (2025)".