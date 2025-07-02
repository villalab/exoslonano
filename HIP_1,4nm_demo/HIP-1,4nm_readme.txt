
This script is to identify the high intensity nanogold picks from a whole tomogram level by plotting the histogram from the whole tomogram and isolating signal which is coming from a high intensity pixel.

Tomographic reconstruction must be of extremely high quality (mean residuals for alignment must be <1 nm) meaning that it is extremely well aligned tilt series as 1.4 nanometer nanogold is very small. 

Denoising, deconvolution will flatten the tomgoram, so tomograms must be generated via weighted-back projections and reconstructed at a lower binning, i.e. 3-5 A/pixel depending on the quality of the data so that there are enough pixels to cover the nanogold signal. 

There are "boundary effects" to consider, i.e. the 1.4 nm nanogold will not be perfectly covered due the inherent errors associated with sampling a sphere over a grid. This can somewhat be overcome by accounting for this effect by filtering the results to account for the undersampled signal.

It is also strongly recommended to generate the tomogram reconstructions without the gallium deposits using slicer (IMOD program), or generating the reconstruction with a Z-height smaller than the actual tomogram so that the Gallium is not in the volume. 

This script calls a dynamo function to read-in the tomogram, so you need to have dynamo installed.

Unfortunately, github cannot host whole tomograms reconstructed at 3 Apx due to the large file size so tomogram will need to be downloaded from EMPIAR. 
