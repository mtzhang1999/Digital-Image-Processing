clear all;
close all;
clc;

flag = 0;
if flag
    img = imread('image1.jpg');
    img = im2double(img);
    m = imread('image1_mask.jpg');
    m = double(m >= 100);
    bg = imread('background.jpg');
    bg = im2double(bg);
else
    img = imread('image2.jpg');
    img = im2double(img);
    load('image2_mask.mat');
    m = mask;
    bg = imread('background.jpg');
    bg = im2double(bg);
    bg = imresize(bg, 1);
end

if flag
    borderSize = 5;
    borderDetect = ones(borderSize, borderSize);
    border = (conv2(m(:, :, 1), borderDetect, 'same') ./ (borderSize^2)).^2;
    border = repmat(border, [1, 1, 3]);

    x = 0;
    y = 0;
    Size = max(size(img), size(bg));
    mask = zeros(Size, 'double');
    mask(Size(1) - size(img, 1) + x + 1: Size(1), y + 1: y + size(img, 2), :) = border;
    part1 = bg .* (1 - mask);
    part2 = zeros(Size, 'double');
    part2(Size(1) - size(img, 1) + x + 1: Size(1), y + 1: y + size(img, 2), :) = border .* img;
    pic = part1 + part2;
    % pic = part2;
    imshow(pic);
else
    [bound, l] = bwboundaries(m);
    bound = bound{1};
    X = bound(:, 1);
    Y = bound(:, 2);
    [xmin, index1] = min(X);
    [xmax, index2] = max(X);
    flag = 0;
    for i = 1: length(X)
        if X(i) == xmax && ~flag
            flag = 1;
            head = i;
        end
        if flag && X(i) ~= xmax
            flag = 0;
            tail = i;
        end 
    end

    degree1 = 16;
    Ones = ones(1000, 1);
    Rand = rand(1000, 1)./2;
    X1 = [X(tail: end); X(1: index1)];
    tmpX = [Ones * X1(1) + Rand; X1; Ones * X1(end) + Rand];
    Y1 = [Y(tail: end); Y(1: index1)];
    tmpY = [Ones * Y1(1) + Rand; Y1; Ones * Y1(end) + Rand];
    line = polyfit(tmpX, tmpY, degree1);
    area1 = zeros(size(img, 1), size(img, 2));
    y1 = round(polyval(line, [X(tail: end); X(1: index1)]));
    for i = 1: length(X1)
        area1(round(X1(i)), y1(i): end) = 1;
    end

    X2 = X(index1 + 1: head);
    Y2 = Y(index1 + 1: head);
    ymax = max(Y2);
    head = [];
    tail = [];
    flag = 0;
    for i = 1: length(X2)
        if Y2(i) == ymax && ~flag
            flag = 1;
            head = [head, i];
        end
        if flag && Y2(i) ~= ymax
            flag = 0;
            tail = [tail, i];
        end 
    end
    if flag
        tail = [tail, length(X2)];
    end

    degree2 = 6;
    area2 = zeros(size(img, 1), size(img, 2));
    idx = 0;
    Ones = ones(500, 1);
    Rand = rand(500, 1)./2;
    len = length(head);
    for i = 2: len
        if i <= len && head(i) - tail(i - 1) <= 10
            head = [head(1: i - 1), head(i + 1: end)];
            tail = [tail(1: i - 2), tail(i: end)];
            len = len - 1;
        end
    end
    for i = 1: length(head)
        tmpX = X2(idx + 1: head(i));
        tmpX = [Ones * tmpX(1); tmpX; Ones * tmpX(end)];
        tmpY = Y2(idx + 1: head(i));
        tmpY = [Ones * tmpY(1); tmpY; Ones * tmpY(end)];
        line = polyfit(tmpX, tmpY, degree2);
        y2 = min(round(polyval(line, X2(idx + 1: head(i)))), ymax);
        for j = 1: length(y2)
            area2(round(X2(idx + j)), 1: y2(j)) = 1;
        end
        for k = head(i) + 1: tail(i)
            area2(X2(k), 1: ymax) = 1;
        end
        idx = tail(i);
    end

    area = (area1 & area2);
    
    borderSize = 5;
    borderDetect = ones(borderSize, borderSize);
    border = (conv2(area, borderDetect, 'same') ./ (borderSize^2)).^2;
    border = repmat(border, [1, 1, 3]);

    x = 0;
    y = 0;
    Size = max(size(img), size(bg));
    mask = zeros(Size, 'double');
    mask(Size(1) - size(img, 1) + x + 1: Size(1), y + 1: y + size(img, 2), :) = border;
    part1 = bg .* (1-mask);
    part2 = zeros(Size, 'double');
    part2(Size(1) - size(img, 1) + x + 1: Size(1), y + 1: y + size(img, 2), :) = border .* img;
    pic = part1 + part2;
    imshow(pic);
end

% img_cal("image1.jpg", "image1_mask.jpg", "jpg", "background.jpg");
% img_cal("image2.jpg", "image2_mask.mat", "mat", "background.jpg");