clear all;
close all;
clc;

demo(255/4,  1/3);
save=0;
for p = 1: 2
    base_pro(p, 1, 0, save);
    base_pro(p, 2, 1, save);
    base_pro(p, 2, 2, save);
    base_pro(p, 2, 3, save);
    base_pro(p, 2, 4, save);
end
for i = 0.05: 0.05: 2
    test(1, [255/2, 255/4, 255], i, save);
end

test(2, [255/2, 255/4, 255], 0.45, save);

function base_pro(fig, method, param, save)
    switch fig
        case 1
            fig = imread('美国NOAA可见光云图.jpg');
            fig_tmp = fig;
            fig = rgb2gray(fig);
        case 2
            fig = imread('焊接X光图像.jpg');
            fig_tmp = fig;
            fig = rgb2gray(fig);
    end

    switch method
        case 1
            fig_tmp(:, :, 1) = rFake(fig);
            fig_tmp(:, :, 2) = gFake(fig);
            fig_tmp(:, :, 3) = bFake(fig);
            figure;
            subplot(1, 2, 1);
            imshow(fig);
            title('original img');
            subplot(1, 2, 2);
            imshow(fig_tmp);
            title('1');
        case 2
            switch param
                case 1
                    T = 255;
                    delta = 1/6;
                case 2
                    T = 255;
                    delta = 1/3;
                case 3
                    T = 255 / 2;
                    delta = 1/3;
                case 4
                    T = 255 / 4;
                    delta = 1/3;
            end
            fig_tmp(:, :, 1) = Trans(fig, T, delta, 0);
            fig_tmp(:, :, 2) = Trans(fig, T, delta, 1);
            fig_tmp(:, :, 3) = Trans(fig, T, delta, 2);
            figure;
            subplot(1, 2, 1);
            imshow(fig);
            title('original img');
            subplot(1, 2, 2);
            imshow(fig_tmp);
            title(['Method2: T = ', num2str(T), ...
                ', \delta = ', num2str(delta)]);
    end
end

function R = rFake(fig)
    R = fig;
    index = (R <= 64);
    R(index) = 0;
    R(~index) =  uint8((double(R(~index)) - 64) * 255 / 64);
end

function G = gFake(fig)
    G = fig;
    index = (G >= 128);
    G(index) = 0;
    G(~index) = uint8((128 - double(G(~index))) * 255 / 64);
end

function B = bFake(fig)
    B = fig;
    index = (B <= 192);
    B(index) = uint8(double(B(index)) * 255 / 64);
    B(~index) = uint8((255 - double(B(~index))) * 255 / 63);
end

function tmp = Trans(fig, T, delta, n)
    tmp = uint8(255 * (1 + sin(2 * pi / T * ...
        (double(fig) - n * delta * T))) / 2);
end

function demo(T, delta)
    x = 0: 255;
    y0 = Trans(x, T, delta, 0);
    y1 = Trans(x, T, delta, 1);
    y2 = Trans(x, T, delta, 2);
    figure;
    hold on;
    plot(x, y0, 'r');
    plot(x, y1, 'g');
    plot(x, y2, 'b');
    xlim([0, 255]);
    title(['T = ', num2str(T), ', \delta = ', num2str(delta)]);
end

function fig_temp = test(fig, T, delta, save)
    x = 0: 255;

    y0 = Trans(x, T(1), delta * T(2) / T(1), 0);
    y1 = 0.5*Trans(x, T(2), delta * T(2) / T(2), 1)+64;
    y2 = Trans(x, T(3), delta * T(2) / T(3), 2);
    figure;
    hold on;
    plot(x, y0, 'r');
    plot(x, y1, 'g');
    plot(x, y2, 'b');
    xlim([0, 255]);
    
    switch fig
        case 1
            pic = imread('美国NOAA可见光云图.jpg');
            fig_temp = pic;
            pic = rgb2gray(pic);
        case 2
            pic = imread('焊接X光图像.jpg');
            fig_temp = pic;
            pic = rgb2gray(pic);
    end
    fig_temp(:, :, 1) = Trans(pic, T(1), delta*T(2)/T(1), 0);
    fig_temp(:, :, 2) = 0.5*Trans(pic, T(2), delta*T(2)/T(2), 1)+64;
    fig_temp(:, :, 3) = Trans(pic, T(3), delta*T(2)/T(3), 2);
    figure;
    subplot(1, 2, 1);
    imshow(pic);
    title('original img');
    subplot(1, 2, 2);
    imshow(fig_temp);
    title('new img');
end