 clc;
% close all;
 clear all;

model = 'C:\Users\sbadreta\Desktop\Phantom_5555\Test\x4.mat';

folder_in = uigetdir('C:\Users\sbadreta\Desktop\Phantom_5555', 'select dir');
filepath_in = dir(fullfile(folder_in,'*.ima'));
folder_out = uigetdir('C:\Users\sbadreta\Desktop\Phantom_5555', 'select dir');
filepath_out = dir(fullfile(folder_out,'*.ima'));

load('C:\Users\sbadreta\Desktop\Phantom_5555\Test\x4.mat');
load ('C:\Users\sbadreta\Desktop\Phantom_5555\Train\indxes.mat');

% psnr_gnd=zeros(1,length(filepath_in));
% psnr_SRCNN=zeros(1,length(filepath_in));
% psnr_BM3D=zeros(1,length(filepath_in));
% ssim_gnd=zeros(1,length(filepath_in));
% ssim_SRCNN=zeros(1,length(filepath_in));
% ssim_BM3D=zeros(1,length(filepath_in));

i = 1:length(testIndxs)

for i = 153
im_labell = dicomread(fullfile(folder_out,filepath_out(trainIndxs(i)).name));

    im_label = double(im_labell-min(min(im_labell)))/double(max(max(im_labell)-min(min(im_labell)))); % im_gnd=im_label

    im_inputt = dicomread(fullfile(folder_in,filepath_in(trainIndxs(i)).name));
%    info=dicominfo(fullfile(folder_in,filepath_in(testIndxs(i)).name));

        im_input = double(im_inputt-min(min(im_inputt)))/double(max(max(im_inputt))-min(min(im_inputt))); % Noisy image

        im_h = DLDCNN(model, im_input);       
        im_hh=imsharpen(im_h); 
fprintf('image %d is done !!\n',i);


% dicomwrite(, strcat('reconstrucedSRCNNima', num2str(i),'.ima'));

  [psnr_gnd(i),rmse_gnd(i)] = compute_psnr(im_label,im_input);
 [psnr_SRCNN(i),rmse_SRCNN(i)] = compute_psnr(im_label,im_h);
  ssim_gnd(i) = ssim(im_label,im_input);
 ssim_SRCNN(i) = ssim(double(im_h),im_label);


  [PSNR,y_est] = BM3D(im_label, im_input, 'high',0);
  close all
  [psnr_BM3D(i),rmse_BM3D(i)] = compute_psnr(im_label,y_est);
   ssim_BM3D(i) = ssim(y_est,im_label);
   
% SSC_GSM
  
       randn('seed',0);
        dict             =    2; 
        L                =    [5, 10, 15, 20, 50, 100];
        for idx=1:6
            par              =    Parameters_setting( L(idx), idx );
            par.I=im_label;
            par.nim=im_input;
            [im, PSNR, SSIM, rmse]   =    SSC_GSM_Denoising( par );    

            disp( sprintf('%s: PSNR = %3.2f  SSIM = %f rmse = %f\n', 'House', PSNR, SSIM, rmse) );
            psnr_SSC_GSM_temp(idx)=PSNR;
            rmse_SSC_GSM_temp(idx)=rmse;
            ssim_SSC_GSM_temp(idx)=SSIM;
        %   figure;imshow((imadjust(im,stretchlim(im))),[]);
            X(:,:,1,idx) = im;
        end
        
        ssim_TV_MCA=sort(ssim_SSC_GSM_temp,'descend');
        ssim_TV_MCA=ssim_TV_MCA(2);
        ssim_TV_MCA=find(ssim_SSC_GSM_temp==ssim_TV_MCA);
        psnr_TV_MCA=psnr_SSC_GSM_temp(ssim_TV_MCA);
        rmse_TV_MCA=rmse_SSC_GSM_temp(ssim_TV_MCA);
        im_TV_MCA=X(:,:,:,ssim_TV_MCA);
        
        [ssim_SSC_GSM(i),idx_max_ssim]=max(ssim_SSC_GSM_temp);
        psnr_SSC_GSM(i)=psnr_SSC_GSM_temp(idx_max_ssim);
        rmse_SSC_GSM(i)=rmse_SSC_GSM_temp(idx_max_ssim);
        im_SSC_GSM=X(:,:,:,idx_max_ssim);
end

%% Show

% im_hh=imsharpen(im_h); 
figure;
subplot(1,3,1);
imshow(im_input,[]);
subplot(1,3,2);
imshow(im_label,[]);
subplot(1,3,3);
imshow(im_hh,[]);
tightfig

figure;
subplot(1,2,1);
imshow(im_input,[]);
subplot(1,2,2);
imshow(im_label,[]);
tightfig

figure;
imshow(im_hh,[]);
tightfig

figure;
subplot(1,2,1);
imshow(y_est,[]);
subplot(1,2,2);
imshow(im_SSC_GSM,[]);
tightfig

figure;
subplot(1,2,1);
imshow(im_h,[]);
subplot(1,2,2);
imshow(im_h,[]);
tightfig

figure;
subplot(1,3,1);
imshow(y_est,[]);
subplot(1,3,2);
imshow(im_TV_MCA,[]);
subplot(1,3,3);
imshow(im_SSC_GSM,[]);
tightfig



%% Metrics 
% Proposed
im_hh=imsharpen(im_h);

mssim_Proposed=mssim_omid(im_label,im_hh,4);
uqi_proposed=metrix_mux(im_label,im_hh, 8);
wsnr_Proposed=metrix_mux(im_label,im_hh, 11);
vif_proposed= metrix_mux(im_label,im_hh, 6);
nqm_proposed= metrix_mux(im_label,im_hh, 10);
ifc_proposed= metrix_mux(im_label,im_hh, 9);
% Previous

%BM3D

mssim_BM3D=mssim_omid(im_label,y_est,4);
uqi_BM3D=metrix_mux(im_label,y_est, 8);
wsnr_BM3D=metrix_mux(im_label,y_est, 11);
vif_BM3D=metrix_mux(im_label,y_est, 6);
nqm_BM3D= metrix_mux(im_label,y_est, 10);
ifc_BM3D= metrix_mux(im_label,y_est, 9);

% TV

mssim_TV=mssim_omid(im_label, im_SSC_GSM,4);
uqi_TV=metrix_mux(im_label,im_SSC_GSM, 8);
wsnr_TV=metrix_mux(im_label,im_SSC_GSM, 11);
vif_TV=metrix_mux(im_label,im_SSC_GSM, 6);
nqm_TV= metrix_mux(im_label,im_SSC_GSM, 10);
ifc_TV= metrix_mux(im_label,im_SSC_GSM, 9);

%SSC

mssim_SSC=mssim_omid(im_label,im_TV_MCA,4);
uqi_SSC=metrix_mux(im_label,im_TV_MCA, 8);
wsnr_SSC=metrix_mux(im_label,im_TV_MCA, 11);
vif_SSC=metrix_mux(im_label,im_TV_MCA, 6);
nqm_SSC= metrix_mux(im_label,im_TV_MCA, 10);
ifc_SSC= metrix_mux(im_label,im_TV_MCA, 9);


%% best

im_hh=im2int16(im_h);
maxe=max(max(im_inputt));
mine=min(min(im_inputt));
m=(2^15)/double((maxe-mine));
y=(im_hh-mine)/m;
%imshow(y,[889,1239]);
imshow(y,[714,1414]);
% imcontrast
dicomwrite(y,strcat('NewMethod', num2str(i),'.dcm'),info);
    

% im_hh=im2uint16(im_h);
% m=double(max(max(im_inputt)))/2^16;
% im_hhh=m*im_hh;
% figure;imshow(y,[]);

im_hh=imsharpen(im_h);       
im_hh=im2uint16(im_hh);
adjusted=imadjust(im_hh,stretchlim(im_hh));
figure;imshow(adjusted,[]);

% adjusted=imadjust(im_h,stretchlim(im_h));
% figure;imshow(adjusted,[]);
        
%%
psnr_mean_gnd=mean(psnr_gnd(psnr_gnd>0));
rmse_mean_gnd=mean(rmse_gnd(rmse_gnd>0));
ssim_mean_gnd=mean(ssim_gnd(ssim_gnd>0));

psnr_mean_SRCNN=mean(psnr_SRCNN(psnr_SRCNN>0));
rmse_mean_SRCNN=mean(rmse_SRCNN(rmse_SRCNN>0));
ssim_mean_SRCNN=mean(ssim_SRCNN(ssim_SRCNN>0));

psnr_mean_BM3D=mean(psnr_BM3D(psnr_BM3D>0));
rmse_mean_BM3D=mean(rmse_BM3D(rmse_BM3D>0));
ssim_mean_BM3D=mean(ssim_BM3D(ssim_BM3D>0));

psnr_mean_SSC_GSM=mean(psnr_SSC_GSM(psnr_SSC_GSM>0));
rmse_mean_SSC_GSM=mean(rmse_SSC_GSM(rmse_SSC_GSM>0));
ssim_mean_SSC_GSM=mean(ssim_SSC_GSM(ssim_SSC_GSM>0));

 fprintf('Mean PSNR for Gnd: %f dB\n', psnr_mean_gnd);
 fprintf('Mean PSNR for SRCNN: %f dB\n', psnr_mean_SRCNN);
 fprintf('Mean PSNR for BM3D: %f dB\n', psnr_mean_BM3D);

 fprintf('Mean SSIM for Gnd: %f dB\n', ssim_mean_gnd);
 fprintf('Mean SSIM for SRCNN: %f dB\n', ssim_mean_SRCNN);
 fprintf('Mean SSIM for BM3D: %f dB\n', ssim_mean_BM3D);
 
 %% 
mm=1:10;

figure;
plot(mm,psnr_gnd(mm),'r',mm,psnr_SRCNN(mm),'b--o',mm,psnr_BM3D(mm),'k');title('PSNR');
legend('gnd','SRCNN','BM3D')
 saveas(gcf,'PSNR_piglet_design9woaug.tif')

figure;
plot(mm,rmse_gnd(mm),'r',mm,rmse_SRCNN(mm),'b--o',mm,rmse_BM3D(mm),'k');title('RMSE');
legend('gnd','SRCNN','BM3D')
 saveas(gcf,'RMSE_piglet_design9woaug.tif')

figure;
plot(mm,ssim_gnd(mm),'r',mm,ssim_SRCNN(mm),'b--o',mm,ssim_BM3D(mm),'k');title('SSIM');
legend('gnd','SRCNN','BM3D')
 saveas(gcf,'SSIM_piglet_design9woaug.tif')

%%

% tmp1=imresize(im_label,0.5,'bicubic');
% min1=min(min(tmp1));
% max1=max(max(tmp1));
% tmp2=imresize(im_input,0.5,'bicubic');
% min2=min(min(tmp2));
% max2=max(max(tmp2));
% tmp3=imresize(im_hh,0.5,'bicubic');
% min3=min(min(tmp3));
% max3=max(max(tmp3));
% tmp4=imresize(y_est,0.5,'bicubic');
% min4=min(min(tmp4));
% max4=max(max(tmp4));
% mint=min([min1,min2,min3,min4]);
% maxt=max([max1,max2,max3,max4]);
% montage(tmp1, tmp2,tmp3,tmp4,'DisplayRange',[mint,maxt],'size',[2,2]);
% tightfig;