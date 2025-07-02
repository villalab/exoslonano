
This is a sample demo on randomizing the high intensity signal coming from a 5nm nanogold particle within a subtomogram volume. 


This script reads in mrc volumes using Dynamo. The histogram of the mrc is plotted and the high intensity signal at a specific threshold (3 standard deviations above the mean) is replaced with random values 1 standard deviation from the mean. 

An output folder is created, consisting of the newly generated subtomographic volume. 

The directory structure here matches that of Warp (frames/subtomo/tomogram_name/subtomogram.mrc).

In order to perform subtomogram analysis, the original star file must be copied and modified so that the star file points to the randomized subtomogram (frames/threshold_3std/tomogram_name/subtomogram.mrc).

This script will skip ctf files, the ctf files will need to be soft-linked or copied into the new nanogold randomized subtomogram folder.

The star file which points to the nanogold randomized subtomograms can then be read-in by RELION-3.1 and subtomogram analysis can proceed.

After there is an alignment towards the macromolecule (and not the nanogold particle), the star file that comes from that refinement can be modified to point towards the original subtomograms. 
