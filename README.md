# exoslonano

These are MATLAB scripts related to "ExoSloNano," a method for deliverying nanogold particles to identify protein targets within intact cells by cryo-Electron Tomography. 

These scripts require Dynamo installation and activation in order to read-in mrc volumes. 

Scripts:

(1) HIP.m to identify Nanogold particles directly within the tomogram.
For targets in which there is limited structural information, the goal is to be able to identify the nanogold signal from the whole tomogram level by isolating the high intensity signal within tomograms.

(2) randomize_subtomos.m to remove nanogold signal for subtomogram analysis
For targets in which subtomograms have been generated and subtomogram analysis leads to convergence on the nanogold particle (instead of the target macromolecule), "randomize_subtomos.m" is a MATLAB script that randomizes the nanogold signal on a per-particle basis and generates new output subtomograms. 
