Simple MATLAB scripts written a long time ago before my doctorate. 

The scripts should work with many formats of structural and functional MRI files. The presence of these files should be stated in the settings.mat file, as well as the path to the local file repository. 

Overall, the scripts will move the DICOM files into the desired BIDS project folder, convert them to Nifti format using dcm2niix, relabel them, and moves into specific folders according to BIDS specification (1.8.0)