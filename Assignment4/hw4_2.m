clear all;
close all;
clc;

load('work2.mat');
img = abs(image) / 2.2e5;
Angle = angle(image)/pi;
%imshow(pic);
flag = 1;
switch flag
    case 1
        k = 18;
        img_new = log(1+img);
        img_new = min(1, img_new / (k*mean(img_new(:))));
    case 2
        degree = 0.15;
        img_new = img .^ degree;
    otherwise
        base = exp(-250);
        img_new = (1 -base .^ img) / (1-base);
end

imshow(img_new);