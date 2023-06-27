% luminance MSR: Multi-Scale Retinex on Luminance Component
% input a: [0-255] uint8, m*n grayscale image: the luminance component of a image
% output P: [0-1] double, m*n grayscale image

function P = MSRgray(a)
    Y0 = double(a);  %Í¼ÏñDOUBLE»¯
    
    [N1, M1] = size(Y0);

    Ylog = log(Y0+1);
    Yfft2 = fft2(Y0);
    
    sigma1 = 128;
    F1 = fspecial('gaussian', [N1,M1], sigma1);
    Efft1 = fft2(double(F1));
    DY0 = Yfft2.* Efft1;
    DY = ifft2(DY0);
    DYlog = log(DY +1);
    Yy1 = Ylog - DYlog;
    
    sigma2 = 256;
    F2 = fspecial('gaussian', [N1,M1], sigma2);
    Efft2 = fft2(double(F2));
    DY0 = Yfft2.* Efft2;
    DY = ifft2(DY0);
    DYlog = log(DY +1);
    Yy2 = Ylog - DYlog;
    
    sigma3 = 512;
    F3 = fspecial('gaussian', [N1,M1], sigma3);
    Efft3 = fft2(double(F3));
    DY0 = Yfft2.* Efft3;
    DY = ifft2(DY0);
    DYlog = log(DY +1);
    Yy3 = Ylog - DYlog;
    Yy = (Yy1 + Yy2 +Yy3)/3;
 
    EXPYy = exp(Yy);
    MIN = min(min(EXPYy));
    MAX = max(max(EXPYy));
    EXPYy = (EXPYy - MIN)/(MAX - MIN);
    EXPYy = adapthisteq(EXPYy);  
    P = EXPYy;  

end
