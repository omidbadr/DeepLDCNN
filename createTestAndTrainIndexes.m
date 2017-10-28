% Pick random images from dataset to create train, validation, and test set
% Train_set: 1:K
% Validation_set:K+1, M
% Test_set: M+1:Number_of_images_in_dataset 

clc;clear all

folder_database = uigetdir('C:\Users\', 'select dir');

% Medical images are in DICOM format (.dcm)
filepath_database = dir(fullfile(folder_database,'*.dcm'));
numImages=length(filepath_database);
indxes=randperm(numImages);

%M,K must be lower than numImages
K=300; %size of train set
M=400; % M-K: size of validation set 
trainIndxs= indxes(1:K);
validIndxs= indxes(K+1:M);
testIndxs=indxes(M+1:numImages);

%save the indexes in a separate file named "indexes"
save('indxes','trainIndxs','validIndxs','testIndxs');