%% This file create tiny image patches from large images and combine them into a large correspoding matrix.
% This folder takes an image folder at the beginning, create image patches for each image in the folder with smaller
% size, normalize the images, and create a single matrix for that folder. 

clear; close all;

load 'indxes.mat'

% input and output size, output size must be calculated based on the network parameters(kernel size, padding, and stride)
savepath = 'test.h5';
receptivefield_size = 33;  
output_size = 17;   % size of each tiny output patch
stride = 7;  % Number of pixels to pass to create another output patch

% initialization
data = zeros(receptivefield_size, receptivefield_size, 1, 1);
label = zeros(output_size, output_size, 1, 1);
padding = abs(receptivefield_size - output_size)/2;
count = 0;

% looking for image locations -> upload the image folders 

folder_input = uigetdir('C:\Users\', 'select dir');  % location of input images 
filepath_input = dir(fullfile(folder_input,'*.dcm'));
folder_output = uigetdir('C:\Users\', 'select dir');   % location of output images 
filepath_output = dir(fullfile(folder_output,'*.dcm'));


for i = 1:length(trainIndxs)
    
    image_input = dicomread(fullfile(folder_input,filepath_input (trainIndxs(i)).name));
    %image_input=((double(image_input)-mean2(image_input))/std2(image_input));
	% Normalizing between 0 and 1
    image_input = double(image_input-min(min(image_in)))/double(max(max(image_in))-min(min(image_input)));
	
    image_output = dicomread(fullfile(folder_output,filepath_output (trainIndxs(i)).name));
    % image_output=((double(image_output)-mean2(image_output))/std2(image_output));
    image_output = double(image_output-min(min(image_output)))/double(max(max(image_output))-min(min(image_output)));
    [height,width] = size(image_input);
    
    for x = 1 : stride : height - receptivefield_size + 1
        for y = 1 : stride : width - receptivefield_size + 1

            subim_input = image_input(x : x+receptivefield_size-1, y : y+receptivefield_size-1);
            subim_label = image_output(x+padding : x+padding+output_size-1, y+padding : y+padding+output_size-1);
            
            count = count + 1;
            data(:, :, 1, count) = subim_input;
            label(:, :, 1, count) = subim_label;
        end
    end
	fprintf('%d\n',i);
end
order = randperm(count);

%Creating data, means the input and label which is the ground truth corresponding output
data = data(:, :, 1, order);
label = label(:, :, 1, order); 

% HDF5 writing which is 4D matrix comprising of concatination of 3D data and 3D label 
chunksz = 128;
created_flag = false;
totalct = 0;

for batchno = 1:floor(count/chunksz)
    last_read = (batchno-1)*chunksz;
    batchdata = data(:,:,1,last_read+1:last_read+chunksz); 
    batchlabs = label(:,:,1,last_read+1:last_read+chunksz);

    startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,1,1,totalct+1]);
    curr_dat_sz = store2hdf5(savepath, batchdata, batchlabs, ~created_flag, startloc, chunksz); 
    created_flag = true;
    totalct = curr_dat_sz(end);
end
h5disp(savepath);