
% Get list of subdirectories matching "subtomo/L*" change to match your
% data. Subtomo here because that is what Warp writes out when generating
% subtomograms. L because it is the name of the individual subtomogram.
% Change to match your data. 
ts_list = dir('subtomo/L*');

% Define output directory
output_folder = 'threshold_3,3std';

for i = 1:numel(ts_list)
    % Get list of .mrc files inside the current subdirectory that end with
    % "8.00A.mrc" Change the pixel size to match your data.  
    subtomolist = dir(fullfile('subtomo', ts_list(i).name, '*8.00A.mrc'));

    for ii = 1:numel(subtomolist)
        % Construct full file path
        file_path = fullfile('subtomo', ts_list(i).name, subtomolist(ii).name);

        % Check file size before processing to ignore small or corrupt files).
        % Check your file size in bytes and change that value. 
        if subtomolist(ii).bytes > 900000  
            % Read volume data
            v = dread(file_path);

            % Compute mean and standard deviation of the volume
            mu_v = mean(v(:)); % Mean intensity
            sigma_v = std(v(:)); % Standard deviation

            % Set minValue and maxValue to be within ±1 standard deviations of the mean
            minValue = mu_v - 1 * sigma_v;
            maxValue = mu_v + 1 * sigma_v;

            % Define threshold as 3.3 standard deviations above the mean
            threshold = mu_v + 3.3 * sigma_v;

            % Identify high-intensity pixels
            highIntensityPixels = v > threshold;

            % Randomize only the high-intensity pixel values
            randomizedValues = minValue + (maxValue - minValue) * rand(nnz(highIntensityPixels), 1);
            randomizedVolume = v;
            randomizedVolume(highIntensityPixels) = randomizedValues;

            % Ensure output directory exists
            output_path = fullfile(output_folder, ts_list(i).name);
            if ~exist(output_path, 'dir')
                mkdir(output_path);
            end

            % Write modified volume
            dwrite(randomizedVolume, fullfile(output_path, subtomolist(ii).name));
        end
    end
end

fprintf('Processing complete. Randomized volumes saved in "%s"\n', output_folder);