from nnunetv2.dataset_conversion.generate_dataset_json import generate_dataset_json

generate_dataset_json(
    output_folder='/Data/Machine_Learning/data/nnUNet_raw/Dataset010_PTB_all_energies_1mm_no_background_alldata/',
    channel_names={0: 'FNTD_Reader'},
    labels={'background':0, 'protons': 1},
    num_training_cases=1800,
    file_ending=".png",
    dataset_name="PTB_all_energies_1mm_no_background_alldata",
    description="full training dataset instead of subset",
    converted_by="Long-Yang Jan Thai"             
)