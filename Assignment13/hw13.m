clear all; close all; clc;

fig = imread('Lena.bmp');
mode = 1;
switch mode
    case 0
        interpolation = 'linear';
    otherwise
        interpolation = 'nearest';
end

subplot(1, 3, 1);
T_x = 100;
T_y = -60;
picT = Transformation(fig, T_x, T_y);
title(['平移变换：T_x=', num2str(T_x), ', T_y=', num2str(T_y)]);

subplot(1, 3, 2);
S_x = 1.5;
S_y = 0.75;
picS = Scaling(fig, S_x, S_y, interpolation);
title(['放缩变换：S_x=', num2str(S_x), ', S_y=', num2str(S_y)]);

subplot(1, 3, 3);
theta = 60 * pi / 180;
picR = Rotation(fig, theta, interpolation);
title(['旋转变换：\theta=', num2str(theta)]);

figure;
e = 1;
theta = 30 * pi / 180;
tmp = [e*cos(theta), sin(theta), 0; ...
       -e*sin(theta), cos(theta), 0; ...
       0, 0, 1];
fig_New = imwarp(fig, affine2d(tmp), 'linear');
imshow(fig_New);

function fig_T = Transformation(fig, T_x, T_y)
    fig_T = zeros(size(fig) + abs([T_x, T_y]), 'uint8');
    if T_x >= 0
        X_tmp = size(fig_T, 1) - size(fig, 1) + 1: size(fig_T, 1);
    else
        X_tmp = 1: size(fig, 1);
    end
    if T_y >= 0
        Y_tmp = size(fig_T, 2) - size(fig, 2) + 1: size(fig_T, 2);
    else
        Y_tmp = 1: size(fig, 2);
    end
    fig_T(X_tmp, Y_tmp) = fig;
    imshow(fig_T);
end

function fig_S = Scaling(fig, S_x, S_y, interpolation)
    scaling = [1/S_x, 0, 0; 0, 1/S_y, 0; 0, 0, 1];
    fig_S = imwarp(fig, affine2d(scaling), interpolation);
    imshow(fig_S);
end

function fig_R = Rotation(fig, theta, interpolation)
    rotation = [cos(-theta), sin(-theta), 0; ...
                -sin(-theta), cos(-theta), 0; ...
                0, 0, 1];
    fig_R = imwarp(fig, affine2d(rotation), interpolation);
    imshow(fig_R);
end