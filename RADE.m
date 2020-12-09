% RADE£ºRegion-Adaptive Defogging and Enhancement
% Input:
%    HazyIn: Hazy input color image
%    x:     parameter related to color recovery factor C, scalar, default:x=5
%    belta: parameter related to color recovery Gamma transform (in MSRCR), scalar, default:belta=0.03
%    alpha: parameter for Gamma Correction, scalar, default:alpha=0.8;
% Output:
%    ClearOut:  Dehazed color image 
% example:
%    HazyIn = imread('3.jpg'); 
%    DehazeOut = RADE(HazyIn,5,0.8,0.03);
%
% Authorized by Li Zhan: lizhangray@qq.com on the date 20200223
% Reference Paper: 
%   Z. Li, X. Zheng, B. Bhanu, S. Long, Q. Zhang, Z. Huang. Fast Region-Adaptive 
%   Defogging and Enhancement for Outdoor Images Containing Sky [C]//The 25th 
%   International Conference on Pattern Recognition (ICPR). IEEE, Milan, Italy. 2021,10th-15th Jan. 


function [ClearOut] = RADE(HazyIn,x,alpha,belta)
     tic;
     thres_white = 0.9738;
     thres_gray = 0.7154;
%%  Step1£ºluminance-inverted MSR -- (MSRgray: MSR on Y channel)
    yuvHazyIn = rgb2ycbcr(HazyIn);          % RGB->YCbCr: HazyIn:uint8 [0-255][0-255][0-255];  yuvHazyIn:uint8 [16-235][16-240][16-240] 
    yHazyIn = yuvHazyIn(:,:,1);             % Y channel: yHazyIn:uint8 [0-255]
    Invert_yClearOut = MSRgray(255-yHazyIn);% MSR on invert Y: input:uint8[0-255];output:double[0-1]    
    Invert_yClearOut =uint8((1 - Invert_yClearOut)*(235-16)+16); % invert Y of output: Invert_yClearOut:double[16-235]
    Invert_yuvClearOut = yuvHazyIn;                 % concat CbCr of input [0-255]
    Invert_yuvClearOut(:,:,1) = (Invert_yClearOut);   % concat invert Y of output [0-1]
    Invert_grayClearOut = ycbcr2rgb(Invert_yuvClearOut); % YCbCr->RGB    
    MSRY = Invert_grayClearOut;
    t1=toc;
    
%%  Step2£ºColor Recovery 
    tic;
    P0 = double(Invert_grayClearOut); % P0 is a color image: uint8 [0-255][0-255][0-255]
    R0 = P0(:, :, 1); %compute color-recovery factor of R\G\B three channels
    G0 = P0(:, :, 2);
    B0 = P0(:, :, 3);
    II = R0+G0+B0;
    C(:,:,1) = x*R0./II;    
    C(:,:,2) = x*G0./II;   
    C(:,:,3) = x*B0./II;   
    C = log(C+1);  
    P = P0.^(1+C*belta); % P = InvertMSR + color recovery
    t2=toc;
  
%% Step3£ºAdaptive Gamma
    tic;
    [m,n,channel] = size(HazyIn);
    if(channel>1) % if HazyIn is a color image
        I0 = rgb2gray(HazyIn); % RGB color image -> Grayscale image
    end; 
    I1=im2double(I0);
    I1=medfilt2(I1,[9,9]);% denoise by median filter
  % Treshold Segmentation
    I2 = ones(m,n); %I2 is a m*n all ones matrix
    I2 = (I1 > thres_gray).* 0.5;
    I2 = I2 + (I1 > thres_white) .* 0.5;
    Iwhite = (I1 > thres_white);
    Igray = ((I1 >= thres_gray) & (I1 <= thres_white));
  % Estimate ratio of white and grayish regions
    count_white = sum(sum(Iwhite));
    count_gray = sum(sum(Igray));
%     count_other = sum(sum(I1<thres_gray));
%     if (count_white + count_gray + count_other ~= m*n) 
%         disp('count part pixels error!');
%     end;
    ratio = (count_white + count_gray)/(m * n);      
  % region-ratio-based Adaptive Gamma Correction
    gamma_b=1+alpha*(1-ratio);     
    P = (P./255).^gamma_b;    
    t3=toc;
    
%% Step4£ºCLAHE - Contrast-Limited Adaptive Histogram Equaliztion
    tic;
    CLAHEImg=zeros(m,n);

    R=HazyIn(:,:,1);
    G=HazyIn(:,:,2);
    B=HazyIn(:,:,3);

    M=adapthisteq(R);
    L=adapthisteq(G);
    N=adapthisteq(B);

    CLAHEImg=cat(3,M,L,N);
    CLAHEImg=im2double(CLAHEImg); % CLAHEImg is the grayish region enhanced by CLAHE
    
%% Step5 Seamless Stitching
  % Mean-filtered Mask 
    MeanSize = 100;
    MeanFilter = fspecial('average',[MeanSize,MeanSize]); % 100*100 Mean filter
    Igray = double(Igray);
    Igray = imfilter(Igray,MeanFilter,'replicate');
    Iwhite = double(Iwhite);
    Iwhite = imfilter(Iwhite,MeanFilter,'replicate');   
  % White regions + Other parts
    a = im2double(HazyIn); % a is the input image
    StitchImg = P;
    StitchImg(:,:,1)=(1-Iwhite(:,:)).*P(:,:,1)+Iwhite(:,:).*a(:,:,1);  
    StitchImg(:,:,2)=(1-Iwhite(:,:)).*P(:,:,2)+Iwhite(:,:).*a(:,:,2);
    StitchImg(:,:,3)=(1-Iwhite(:,:)).*P(:,:,3)+Iwhite(:,:).*a(:,:,3);
  % Gray regions + Other parts
    P = StitchImg;
    StitchImg(:,:,1)=(1-Igray(:,:)).*P(:,:,1)+Igray(:,:).*CLAHEImg(:,:,1);  
    StitchImg(:,:,2)=(1-Igray(:,:)).*P(:,:,2)+Igray(:,:).*CLAHEImg(:,:,2);
    StitchImg(:,:,3)=(1-Igray(:,:)).*P(:,:,3)+Igray(:,:).*CLAHEImg(:,:,3);
    
    ClearOut = uint8(StitchImg*255);  % ClearOut is the dehazed output image
    t4=toc;    
    
    figure;
    subplot(121);    imshow(HazyIn);       title(['Hazy Input:' num2str(ratio)]);
    subplot(122);    imshow(ClearOut);     title('Dehaze Output');
    runtime = t1 + t2 + t3 + t4  %compute run time of four major processes
    
end