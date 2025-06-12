%1.4 nanometer nanogold is very small. 

%Tomographic reconstruction must be of extremely high quality (mean residuals for alignment must be <1 nm) 
%meaning that it is extremely well aligned tilt series.

%Denoising, deconvolution will flatten the tomgoram. Generate weighted-back projections and these tomograms 
%must be reconstructed at a lower binning, i.e. 3-5 A/pixel depending on the quality of the data so
%that there are enough pixels to cover the nanogold signal. 

%There are "boundary effects" to consider, so the 1.4 nm nanogold will not be
%perfectly covered due the inherent errors associated with sampling a
%sphere over a grid. This can somewhat be overcome by accounting for this
%effect by filtering the results to account for the undersampled signal.

%It is also strongly recommended to generate the tomogram reconstructions without the
%gallium deposits using slicer (IMOD program), or generating the reconstruction with a Z-height smaller than
%the actual tomogram. 

%This script calls a dynamo function to read-in the tomogram, so you need
%ot have dynamo installed. 

% Define the range of file numbers to process
file_numbers = 3:3;  % Adjust the range as needed
file_prefix = 'L11_ts_';  % Prefix for the file names, this is how data acquired with PACEtomo is usually labeled
file_suffix = '.mrc_3.00Apx.mrc';  % Suffix for the file names, adjust to your data


%define pixel size in nanometers (pixel size of the input reconstruction)
pixelsize = 0.3;
%define nanogold radius in nanometers
ng = 0.7;
%nanogold raidus in pixels
ng_px = ng/pixelsize; 
%define voxel volume assuming perfect sampling
volumeNG = (4/3)*pi*(ng_px)^3;

%Tomographic reconstructions are not perfect representations
%define undersampling error (sampling a sphere over a grid)
ng_undersampled = ng*0.7;
%under sampled nanogold in pixels
ng_px_undersampled = ng_undersampled/pixelsize;
%define voxel volume of the undersampled volume
volumeNG_undersampled = (4/3)*pi*(ng_px_undersampled)^3; 

num_slices_to_avg = 10; % Number of slices to average

for n = file_numbers
    % Construct the file name dynamically
    file_name = [file_prefix, sprintf('%03d', n), file_suffix];
    
    % Read the current .mrc file
    tomo = dread(file_name);
    image_double = double(tomo);
    
    % Average over 10 slices along the third dimension
    smoothed_image = movmean(image_double, num_slices_to_avg, 3);
    
    % Normalize the averaged image
    min_intensity = min(smoothed_image(:));
    max_intensity = max(smoothed_image(:));
    normalized_image = (smoothed_image - min_intensity) / (max_intensity - min_intensity);
    disp(['File: ', file_name, ' - Standard deviation: ', num2str(std(normalized_image(:)))]);
    
    % Compute threshold dynamically based on mean and standard deviation
    mean_intensity = mean(normalized_image(:));
    std_intensity = std(normalized_image(:));
    threshold_value = mean_intensity + 3.5 * std_intensity;
    
    % Create the mask using the dynamic threshold
    mask = normalized_image >= threshold_value;
    
    % Save the thresholded mask to a new .mrc file. Writing this file out
    % takes a lot of time, comment it out after you have a good threshold
    % set.
    output_file = [file_prefix, sprintf('%03d', n), '_threshold_dynamic3,3std.mrc'];
    dwrite(mask, output_file);
    disp(['Thresholded mask saved to: ', output_file]);
    
    % Find coordinates of high-intensity voxels
    [rows, cols, slices] = ind2sub(size(mask), find(mask == 1));
    coordinates = [rows, cols, slices];
    voxels = coordinates;
    
    % Initialize binary image
    binaryImage = zeros(size(mask));
    for i = 1:size(voxels, 1)
        binaryImage(voxels(i, 1), voxels(i, 2), voxels(i, 3)) = 1;
    end
    
    % Connected component labeling
    cc = bwconncomp(binaryImage, 26);  % 26-connectivity
    groupedCoordinates = [];
    
    % Process each connected component
    for i = 1:cc.NumObjects
        [x, y, z] = ind2sub(size(binaryImage), cc.PixelIdxList{i});
        center = round([mean(x), mean(y), mean(z)]);
        groupedCoordinates = [groupedCoordinates; center, numel(x)];
    end
    
    % Filter out single-voxel groups (background)
    rowstoremove = groupedCoordinates(:, 4) == 1;
    filteredList = groupedCoordinates(~rowstoremove, :);
    
    % Filtering to select for high intensity voxels consistent with the size of your nanogold
    % and remove coordinstes that are smaller than the undersampled size of the NG
    background_signal = filteredList(:, 4) < volumeNG_undersampled;
    filteredList2 = filteredList(~background_signal, :);
    %remove anything larger than the perfect sampling of the nanogold
    larger_background_signal = filteredList2(:, 4) > volumeNG;
    filteredList3 = filteredList2(~larger_background_signal, :);   
    
    %remove any high intensity pixels near the top/bottom of the tomogram, this will depend on the
    %volume of your tomogram
    %top_30nm = filteredList3(:, 3) < 60;
    %filteredList4 = filteredList(~top_30nm, :);
    %bottom_30nm = filteredList4(:, 3) > 320;
    %filteredList5 = filteredList4(~bottom_30nm, :);

    
    % Save results to CSV files
    writematrix(filteredList3(:, 4), [file_prefix, sprintf('%03d', n), '_NG_sizes_3apix_3,3std.csv']); %just the number of voxels for each coordinate
    writematrix(filteredList3(:, 1:4), [file_prefix, sprintf('%03d', n), '_NG_coords_3apix_3,3std.csv']); %coordinates and number of voxels
    
    % Optional: Display boxplot of the filtered signal sizes
    %figure;
    %boxplot(filteredList5(:, 4));
    %saveas(gcf, [file_prefix, sprintf('%03d', n), '_boxplot_dynamic_threshold.png']);
    %close(gcf);
    
    % Display progress
    disp(['File: ', file_name, ' - Processing completed.']);
end