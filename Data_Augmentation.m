%% data augmentation to increase the size of dataset if necessary
% This folder create artificial images by rotating and scaling the original
% image in order to increase the number of instances in a dataset

clear; 

folder_input = uigetdir('C:\Users\', 'select dir');  % location of input images 
filepath_input = dir(fullfile(folder_input,'*.dcm'));

folder_output = uigetdir('C:\Users\', 'select dir');    % location of output images 
filepath_output = dir(fullfile(folder_output,'*.dcm'));

for i = 1 : length(filepath_input)

    image_label = dicomread(fullfile(folder_output,filepath_output(i).name)); 
    info_label = dicominfo(fullfile(folder_output,filepath_output(i).name)); 
    image_input = dicomread(fullfile(folder_input,filepath_input(i).name)); 
    info_input = dicominfo(fullfile(folder_input,filepath_input(i).name)); 
	
% Rotate the image dimension  
    for angle = 0: 45 :180
         im_rotation_output = rot90(image_label, angle);
         dicomwrite(im_rotation_output,strcat('output_rot', num2str(i), num2str(scale),'.dcm'),info_label);
		 
		 im_rotation_input = rot90(image_input, angle);
         dicomwrite(im_rotation_input,strcat('input_rot', num2str(i), num2str(scale),'.dcm'),info_label);

% Change the image dimension         
    for scale = 0.8 
            im_scale_output = imresize(image_label, scale, 'bicubic');
            dicomwrite(im_scale_output,strcat('output_dim', num2str(i), num2str(scale),'.dcm'),info_label);
            
            im_scale_input = imresize(image_input, scale, 'bicubic');
            dicomwrite(im_scale_input,strcat('input_dim', num2str(i), num2str(scale),'.dcm'),info_input);
    end
      
     
        
    end
end

