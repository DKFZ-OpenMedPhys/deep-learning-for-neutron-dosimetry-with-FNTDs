##########################################################################################################
# USAGE:
# This script uses the binary segmented images (from the input_labels_folder)
# and the raw images (from the input_image_folder)
# to count the spots/tracks/regions of the binary segmented images and creates
# the colored segmented images (stored in the output_labels_folder)
# and the raw images overlayed with the colored segmented images (stored in the output_image_folder).
# Additionally, an excel file is created with the number of counted spots.

# DIFFERENCE TO ORIGINAL NUMBER OF TRACKS SCRIPT:
# It does consider a minimum connected pixel criterion of 30 connected pixels per spot
# Spots smaller than "min_size" pixels are ignored.

# FOLDER STRUCTURE:
# Copy the required folders, e.g. for the testsets: "labelsPredict_PP" and "imagesTs"
# to the folder "number_of_tracks", run this script, and get the two folders
# "labelsPredict_PP_tracks", "imagesTs_tracks" and the excel "number_of_tracks.xlsx".
# use the excel "number_of_tracks.xlsx" and copy the values into the template excel
# "number_of_tracks_testset.xlsx" (for evaluation of all testsets), then delete "number_of_tracks.xlsx".
# Copy all the folders and files to the desired destination folder.
##########################################################################################################

##### MODULES ############################################################################################
# file operations and sorting
import os 
import re
# matrix operations
import numpy as np
import pandas as pd
# load and saving images
from skimage.io import imread, imsave
# count labels
from skimage.measure import label, regionprops
# label into rgb color
from skimage import color 
from skimage.color import rgb2gray
# supress low contrast warnings (which occurs always for image with a lot of background)
import warnings
warnings.filterwarnings("ignore", message=".*is a low contrast image.*")
# progress bar
from tqdm import tqdm
###########################################################################################################

##### PARAMETERS TO ADAPT #################################################################################
input_labels_folder = 'labelsPredict_PP'      # folder of binary segmented labels (INPUT)
input_image_folder = 'imagesTs'               # folder of raw images (INPUT)
modality_channel = '0000'                     # channel of the raw images
output_labels_folder = 'labelsPredict_PP_tracks_extended'  # folder of binary segmented labels, colored spots (OUTPUT)
output_image_folder = 'imagesTs_tracks_extended'           # folder of raw images overlayed with colored spots (OUTPUT)
excel_output = 'number_of_tracks_extended.xlsx'        # excel sheet with number of spots (OUTPUT)
min_size = 30                                 # minimum number of connected pixels per spot
############################################################################################################

##### CODE, NOT TO ADAPT ###################################################################################
# separates strings and integers and is responsible for sorting the files correctly,
# to avoid e.g. image1, image 10, image 11, ..., image2, image 20, image 21, ...
# and have instead image 1, 2, ..., 10, 11, ..., 20, 21 
def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r'(\d+)', s)]

# main postprocessing function 
def process_segmented_images(input_labels_dir, input_images_dir, output_labels_color_dir, output_images_color_dir, output_excel_dir):
    # creating the output folders if not existient
    os.makedirs(output_labels_color_dir, exist_ok=True)
    os.makedirs(output_images_color_dir, exist_ok=True)
    
    # List to store the number of spots/track for each image
    spot_data = []

    # gets the list of files from the input binary folder and sorts it correctly with the natural_sort_key function
    file_list = sorted(
        [f for f in os.listdir(input_labels_dir) if f.lower().endswith(('.png', '.tif', '.tiff', '.jpg', '.jpeg'))],
        key=natural_sort_key
    )

    # iterate over all files, while showing progress bar
    for filename in tqdm(file_list, desc="Progress"):
        
        ##### BINARY IMAGE ###################################################################
        # load binary image
        binary_path = os.path.join(input_labels_dir, filename)
        binary_image = imread(binary_path)
        # convert binary image [0,1] to boolean image [False, True]
        binary_image = binary_image > 0

        # Regionen labeln
        # using the built-in-function "label()" to count the connected regions/spots
        # see: https://scikit-image.org/docs/0.25.x/api/skimage.measure.html#skimage.measure.label
        # connectivity = 1 -> 4 neighboring pixels, connectivity = 2 -> 8 neighboring pixels 
        labeled_image = label(binary_image, connectivity=2)
        #num_spots = labeled_image.max()

        # keep only regions with at least min_size-connected pixels
        filtered_image = np.zeros_like(labeled_image)
        new_label = 1
        for region in regionprops(labeled_image):
            if region.area >= min_size:
                filtered_image[labeled_image == region.label] = new_label
                new_label += 1

        num_spots = new_label - 1

        # transform the labels into a rgb-colored image and scales it to 0-255
        colored_spots = color.label2rgb(filtered_image, bg_label=0, kind='overlay')
        colored_spots_uint8 = (colored_spots * 255).astype(np.uint8)

        # Save the segmented colored labels images
        output_path = os.path.join(output_labels_color_dir, filename)
        imsave(output_path, colored_spots_uint8)
        ######################################################################################

        ##### RAW IMAGE ######################################################################
        # get the raw image file names based on the segmented image file names
        # this should be smt like this: name + "_0000" + .png)
        name, ext = os.path.splitext(filename) # e.g. ss0601_02_03.png -> ss0601_02_03 and .png
        raw_filename = f"{name}_{modality_channel}{ext}" # insert the modality in between
        
        # path for the new image, where raw image should be overlayed with the colored segmentation
        raw_path = os.path.join(input_images_dir, raw_filename)
        # if raw image does not exist, skip and give warning
        if not os.path.exists(raw_path):
            print(f"Warnung: Raw-Image für {raw_filename} nicht gefunden. Überspringe Overlay.")
            continue
        # if raw image exists, load the image
        raw_image = imread(raw_path)

        # if RGB image, then convert it into grey value image
        if raw_image.ndim == 3 and raw_image.shape[2] == 3:
            raw_image = rgb2gray(raw_image)

        # Normalize to 0–255 for overlay -> converts 16-bit greyscale into 8-bit [0,255]
        raw_min, raw_max = raw_image.min(), raw_image.max()
        if raw_max > raw_min:
            raw_scaled = ((raw_image - raw_min) / (raw_max - raw_min) * 255).astype(np.uint8)
        else:
            raw_scaled = np.zeros_like(raw_image, dtype=np.uint8)

        # convert grey scale image to rgb, to be able to overlay with the colored spots
        raw_rgb = np.stack([raw_scaled] * 3, axis=-1)

        # Mix overlay with raw image, alpha = 0.2 -> 20% Transparency 
        alpha = 0.2
        overlay_img = (alpha * colored_spots_uint8 + (1 - alpha) * raw_rgb).astype(np.uint8)
        
        # save overlay image
        overlay_path = os.path.join(output_images_color_dir, raw_filename)
        imsave(overlay_path, overlay_img)
        ######################################################################################
        
        # Save/append the number of spots for each image
        spot_data.append({'Image': filename, 'Number_of_Spots': num_spots})

    # save number of spots data to excel file
    df = pd.DataFrame(spot_data)
    df.to_excel(output_excel_dir, index=False)

    # Notify user, where the images and excel are saved
    print(f"Excel file saved in: {output_excel_dir}")
    print(f"Colored spots saved in: {output_labels_color_dir}")
    print(f"Overlay images saved in: {output_images_color_dir}")

# call the main postprocessing function
process_segmented_images(
    input_labels_folder,
    input_image_folder,
    output_labels_folder,
    output_image_folder,
    excel_output
)
