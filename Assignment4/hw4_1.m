clear all;
close all;
clc;

Plot = 1;
img = imread('work1.png');
if Plot
    subplot(2, 2, 1);
    imshow(img);
    title('raw image');
end

[h, s, v] = rgb2hsv(img);
img = rgb2gray(img);

cnt = zeros(256, 1, 'double');
for i = 1: size(img, 1)
    for j = 1: size(img, 2)
        x = img(i, j) + 1;
        cnt(x) = cnt(x) + 1;
    end
end
cnt = cnt / (i*j);
if Plot
    subplot(2, 2, 2);
    bar(cnt);
    title('histogram of raw image');
end

tk = cnt;
for i = 1: 255
    tk(i+1) = tk(i+1) + tk(i);
end
tK = round(tk * 255);

n = zeros(256, 1, 'double');
for i = 1: 256
    n(tK(i)+1) = n(tK(i)+1) + cnt(i);
end
if Plot
    subplot(2, 2, 4);
    bar(n);
    title('histogram of new image');
end

vtmp = zeros(size(img));
for i = 1: size(img, 1)
    for j = 1: size(img, 2)
        vtmp(i, j) = tK(img(i, j)+1);
    end
end

img_new = hsv2rgb(h, s, double(vtmp)/255);
if Plot
    subplot(2, 2, 3);
    imshow(img_new);
    title('new image');
end