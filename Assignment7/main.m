clear all;
close all;
clc;

mode = 2;

if mode == 1
    pic = imread('Lena.bmp');
    spec = fftshift(fft2(pic));
    task1(pic, spec);
elseif mode == 2
    pic = imread('board-orig.bmp');
    spec = fftshift(fft2(pic));
    task2(pic, spec);
elseif mode == 3
    pic = imread('Lena.bmp');
    spec = fftshift(fft2(pic));
    task3(pic, spec);
else
    pic = imread('Lena.bmp');
    spec = fftshift(fft2(pic));
    task4(pic, spec);
end

%% LowPass
function task1(fig, spec)
    figure;
    subplot(1, 2, 1);
    imshow(fig);
    title('original figure');
    subplot(1, 2, 2);
    SpecPlot(spec)
    title('original spectrum');
    %% Ideal
    d0 = 0.2;
    [Mask, new_S] = IdealLowPass(spec, d0);
    figure;
    subplot(2, 3, 2);
    imagesc(Mask);
    colorbar;
    title(['ideal mask: d0 = ', num2str(d0)]);
    subplot(2, 3, 3);
    SpecPlot(new_S);
    title('new spectrum');
    subplot(2, 3, 1);
    ImagePlot(new_S);
    title('new figure');
    %% BW
    degree = 3;
    [Mask, new_S] = BWLowPass(spec, d0, degree);
    subplot(2, 3, 5);
    imagesc(Mask);
    colorbar;
    title(['Butterworth mask: d0 = ', num2str(d0), ', degree = ', num2str(degree)]);
    subplot(2, 3, 6);
    SpecPlot(new_S);
    title('new spectrum');
    subplot(2, 3, 4);
    ImagePlot(new_S);
    title('new figure');
end

%%
function task2(fig, spec)
    figure;
    subplot(1, 2, 1);
    imshow(fig);
    title('original figure');
    subplot(1, 2, 2);
    SpecPlot(spec)
    title('original spectrum');
    %% Ideal
    d0 = 0.2;
    a = 0.5;
    b = 1.5;
    [mask, new_S] = IdealHighPass(spec, d0, a, b);
    figure;
    subplot(2, 3, 2);
    imagesc(mask);
    colorbar;
    title(['ideal mask: d0 = ', num2str(d0)]);
    subplot(2, 3, 3);
    SpecPlot(new_S);
    title('new spectrum');
    subplot(2, 3, 1);
    ImagePlot(new_S);
    title('new figure');
    %% BW
    degree = 3;
    [mask, new_S] = BWHighPass(spec, d0, degree, a, b);
    subplot(2, 3, 5);
    imagesc(mask);
    colorbar;
    title(['Butterworth mask: d0 = ', num2str(d0), ', degree = ', num2str(degree)]);
    subplot(2, 3, 6);
    SpecPlot(new_S);
    title('new spectrum');
    subplot(2, 3, 4);
    ImagePlot(new_S);
    title('new figure');
end

%% Bell
function task3(~, spec)
    num = 8;
    D0 = 0.05: 0.05: 0.05*num;
    figure;
    for i = 1: num
        d0 = D0(i);
        subplot(2, 4, i);
        [~, new_S] = IdealLowPass(spec, d0);
        ImagePlot(new_S);
        title(['figure: d0 = ', num2str(d0)]);
    end
end

%% 
function task4(~, spec)
    num = 8;
    Degree = 3: 1: num + 2;
    figure;
    d0 = 0.2;
    for i = 1: num
        degree = Degree(i);
        subplot(2, 4, i);
        [~, new_S] = BWLowPass(spec, d0,degree);
        ImagePlot(new_S);
        title(['figure: degree = ', num2str(degree)]);
    end
end

%% freq_plot
function SpecPlot(spec)
    spec = abs(spec);
    k = 1e-5;
    spec = spec / (k*max(spec(:)));
    new_fig = log(1+spec);
    new_fig = min(1, new_fig / (max(new_fig(:))));
    imshow(new_fig)
end

%%
function fig = ImagePlot(spec)
    fig = uint8(ifft2(ifftshift(spec)));
    imshow(fig);
end

%% Ideal
function [mask, new_S] = IdealLowPass(spec, d0)
    S = size(spec);
    x0 = round((S(1)+1) / 2);
    y0 = round((S(2)+1) / 2);
    x = 1: S(1);
    y = 1: S(2);
    dis = (2*(x - x0)/S(1))'.^2 + (2*(y - y0)/S(2)).^2;
    mask = (dis < d0.^2);
    new_S = mask .* spec;
end

%% BW
function [Mask, new_S] = BWLowPass(spec, d0, degree)
    S = size(spec);
    x0 = round((S(1)+1) / 2);
    y0 = round((S(2)+1) / 2);
    x = 1: S(1);
    y = 1: S(2);
    dis = (2*(x - x0)/S(1))'.^2 + (2*(y - y0)/S(2)).^2;
    Mask = 1 ./ (1 + (dis / d0^2) .^ degree);
    new_S = Mask .* spec;
end

%% Ideal
function [mask, new_S] = IdealHighPass(spec, d0, a, b)
    S = size(spec);
    x0 = round((S(1)+1) / 2);
    y0 = round((S(2)+1) / 2);
    x = 1: S(1);
    y = 1: S(2);
    dis = (2*(x - x0)/S(1))'.^2 + (2*(y - y0)/S(2)).^2;
    mask = a + b * (dis > d0.^2);
    new_S = mask .* spec;
end

%% BW
function [mask, new_S] = BWHighPass(spec, d0, degree, a, b)
    S = size(spec);
    x0 = round((S(1)+1) / 2);
    y0 = round((S(2)+1) / 2);
    x = 1: S(1);
    y = 1: S(2);
    dis = (2*(x - x0)/S(1))'.^2 + (2*(y - y0)/S(2)).^2;
    mask = a + b * (1 ./ (1 + (d0^2 ./ dis) .^ degree));
    new_S = mask .* spec;
end
