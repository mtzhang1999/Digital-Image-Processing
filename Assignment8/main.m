 <h2><center>第七周作业</center></h2>

 <h6><center>张茗曈 2017011214</center></h6>clear all;
close all;
clc;

noise_set = 0;
filter = 0;
mode = 4;
imageSave = 1;

switch noise_set
    case 0
        fig = imread('board-orig.bmp');
    case 1
        fig = imread('board-Gauss-0.005.bmp');
    case 2
        fig = imread('board-Gauss-0.01.bmp');
    otherwise
        fig = imread('board-orig.bmp');
        fig = imnoise(fig, 'gaussian', 0, 0.1);
end

switch filter
    case 1
        fig = wiener2(fig, [3, 3]);
    case 2
        modelLS = [1; 2; 1] * [1, 2, 1];
        fig = LinearSmoother(fig, modelLS);
end

threRobert = 0.07;
threSobel = 0.07;
threLaplace = 0.07;
threCanny = [0.25, 0.5];
mix = 0.5;

switch mode
    case 1
        mask1 = [-1, 0; 0, 1];
        mask2 = [0, -1; 1, 0];
        tmp1 = conv2(fig, mask1, 'same');
        tmp2 = conv2(fig, mask2, 'same');
        Edge = abs(tmp1)+abs(tmp2);
        tmp = sort(Edge(:), 'descend');
        thre = tmp(round(length(tmp)*threRobert));
        Edge = (Edge >= thre);
        result = uint8(double(fig)*mix + Edge*256);
    case 2
        mask1 = [-1, -2, -1; 0, 0, 0; 1, 2, 1];
        mask2 = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
        tmp1 = conv2(fig, mask1, 'same');
        tmp2 = conv2(fig, mask2, 'same');
        Edge = abs(tmp1)+abs(tmp2);
        tmp = sort(Edge(:), 'descend');
        thre = tmp(round(length(tmp)*threSobel));
        Edge = (Edge >= thre);
        result = uint8(double(fig)*mix + Edge*256);
    case 3
        mask = [1, 1, 1; 1, -8, 1; 1, 1, 1];
%         mask = [0, 1, 0; 1, -4, 1; 0, 1, 0];
        Edge = abs(conv2(fig, mask, 'same'));
        tmp = sort(Edge(:), 'descend');
        thre = tmp(round(length(tmp)*threLaplace));
        Edge = (Edge >= thre);
        result = uint8(double(fig)*mix + Edge*256);
    otherwise
        Edge = edge(fig, 'Canny', threCanny);
        result = uint8(double(fig)*mix + Edge*256);
end

figure;
subplot(1, 2, 1);
imshow(Edge, []);
title('edge detection');
subplot(1, 2, 2);
imshow(result);
title('edge in image');

figure;
[H, T, R] = hough(Edge, 'RhoResolution', 1, 'Theta', -90: 0.25: 89);
imshow(imadjust(H),'XData',T,'YData',R,...
      'InitialMagnification','fit');
colormap(gca,hot);
xlabel('\theta');
ylabel('\rho');
axis on;
axis normal;
hold on;
colormap(gca, 'default');
title('Hough result');

%%
if imageSave
    path = ['data\noiseLevel', num2str(noise_set), ...
            '_filter', num2str(filter), ...
            '_mode', num2str(mode)];
    if ~exist(path, 'dir')
        mkdir(path);
    end
    imwrite(Edge, [path, '\Edge.jpg']);
    imwrite(result, [path, '\Result.jpg']);
    imwrite(H, [path, '\H.jpg']);
end

    
%% filter
function fig_filter = LinearSmoother(fig, model)
    tmp = ones(size(fig));
    count = conv2(tmp, model, 'same');
    fig_filter = conv2(fig, model, 'same');
    fig_filter = uint8(fig_filter ./ count);
end