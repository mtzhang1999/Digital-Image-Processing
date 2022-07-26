clear all;
close all;
clc;


	fig = imread('image.bmp');


 test(fig);

 Analysis(fig);


%% test
function test(pic)
    Size = size(pic);
    Scale = Size(1) * Size(2);
    %% Noise
    Plot = 1;
    Save = 1;

    param_G = 0.005;
    param_S = 0.015;
    [fig_G, MSE_G] = Imnoise(pic, 'gaussian', param_G);
    [fig_S, MSE_S] = Imnoise(pic, 'salt & pepper', param_S);
    
    if Plot
        figure;
        subplot(1, 3, 1);
        imshow(pic);
        title('Original');
        subplot(1, 3, 2);
        imshow(fig_G);
        title(['Gaussian: MSE = ', num2str(MSE_G)]);
        subplot(1, 3, 3);
        imshow(fig_S);
        title(['Salt & Pepper: MSE = ', num2str(MSE_S)]);
    end
    
    if Save
        imwrite(fig_G, ['image_Gauss.bmp'])
        imwrite(fig_S, ['image_SP.bmp'])
    end

    %% Filter
    Plot = 1;
    % Gauss
    Gauss = [1; 2; 1] * [1, 2, 1];
    [fig_G1, PSNR_G1] = Linear_Smooth(pic, fig_G, Gauss);
    [fig_G2, PSNR_G2] = Linear_Smooth(pic, fig_S, Gauss);
    
    if Plot
        figure;
        subplot(1, 2, 1);
        imshow(fig_G1);
        title(['Gaussian: PSNR = ', num2str(PSNR_G1)]);
        subplot(1, 2, 2);
        imshow(fig_G2);
        title(['Salt & Pepper: PSNR = ', num2str(PSNR_G2)]);
    end
    % Mid
    Mid = [0, 0, 1, 0, 0; ...
               0, 0, 1, 0, 0; ...
               1, 1, 1, 1, 1; ...
               0, 0, 1, 0, 0; ...
               0, 0, 1, 0, 0;];
    [fig_M1, PSNR_M1] = M_Filter(pic, fig_G, Mid);
    [fig_M2, PSNR_M2] = M_Filter(pic, fig_S, Mid);
    
    if Plot
        figure;
        subplot(1, 2, 1);
        imshow(fig_M1);
        title(['Gaussian: PSNR = ', num2str(PSNR_M1)]);
        subplot(1, 2, 2);
        imshow(fig_M2);
        title(['Salt & Pepper: PSNR = ', num2str(PSNR_M2)]);
    end
    
    % Wiener
    fig_Wiener1 = wiener2(fig_G, [3, 3]);
    tmp = sum(sum((double(fig_Wiener1) - double(pic)).^2)) / Scale;
    PSNR_Wiener1 = 10 * log10(255^2 / tmp);
    fig_Wiener2 = wiener2(fig_S, [3, 3]);
    tmp = sum(sum((double(fig_Wiener2) - double(pic)).^2)) / Scale;
    PSNR_Wiener2 = 10 * log10(255^2 / tmp);
    
    if Plot
        figure;
        subplot(1, 2, 1);
        imshow(fig_Wiener1);
        title(['Gaussian: PSNR = ', num2str(PSNR_Wiener1)]);
        subplot(1, 2, 2);
        imshow(fig_Wiener2);
        title(['Salt & Pepper: PSNR = ', num2str(PSNR_Wiener2)]);
    end
    
    %% Sharpen
    Plot = 1;
    Lap = [0, -1, 0; ...
                    -1, 5, -1; ...
                    0, -1, 0];
    param_Lap1 = 0.25;
    [fig_Lap1, PSNR_Lap1] = Lap_Sharpen(pic, Lap, ...
        param_Lap1);
    param_Lap2 = 1;
    [fig_Lap2, PSNR_Lap2] = Lap_Sharpen(pic, Lap, ...
        param_Lap2);
    
    if Plot
        figure;
        subplot(1, 2, 1);
        imshow(fig_Lap1);
        title(['LaplaceSharpening: ', num2str(param_Lap1), ...
            ', PSNR = ', num2str(PSNR_Lap1)]);
        subplot(1, 2, 2);
        imshow(fig_Lap2);
        title(['LaplaceSharpening: ', num2str(param_Lap2), ...
            ', PSNR = ', num2str(PSNR_Lap2)]);
    end
    
    MMS = [0, 0, 1, 0, 0; ...
               0, 0, 1, 0, 0; ...
               1, 1, 1, 1, 1; ...
               0, 0, 1, 0, 0; ...
               0, 0, 1, 0, 0;];
    [picMMS1, PSNRMMS1] = MinMaxSharpen(pic, MMS);
    [picMMS2, ~] = MinMaxSharpen(picMMS1, MMS);
    [picMMS2, ~] = MinMaxSharpen(picMMS2, MMS);
    [picMMS2, ~] = MinMaxSharpen(picMMS2, MMS);
    [picMMS2, ~] = MinMaxSharpen(picMMS2, MMS);
    tmp = sum(sum((double(picMMS2) - double(pic)).^2)) / Scale;
    PSNRMMS2 = 10 * log10(255^2 / tmp);
    
    if Plot
        figure;
        subplot(1, 2, 1);
        imshow(picMMS1);
        title(['MinMaxSharpening1: PSNR = ', num2str(PSNRMMS1)]);
        subplot(1, 2, 2);
        imshow(picMMS2);
        title(['MinMaxSharpening5: PSNR = ', num2str(PSNRMMS2)]);
    end

end

%% Analysis
function Analysis(fig)
    N = 200;

    step_G = 8.5e-4;
    param_G = step_G: step_G: N * step_G;
    [noise_G, filter_G] = Ana_sub(fig, 'gaussian', param_G);

    step_S = 2.4e-3;
    param_S = step_S: step_S: N * step_S;
    [noise_S, filter_S] = Ana_sub(fig, 'salt & pepper', param_S);

    X = [noise_G, noise_S];
    X = 10 * log10(255^2 ./ X); 
    xMin = min(X(:));
    xMax = max(X(:));
    Y = [filter_G, filter_S];
    num_f = size(filter_G, 2); 
    nameNoise = ["Gaussian: ", "Salt & Pepper: "];
    nameFilter = ["Linear3*3", "Linear5*5", "Median1", ...
                  "Median2", "Wiener3*3", "Wiener5*5"];

    figure;
    for indexX = 1: size(X, 2)
        subplot(1, 2, indexX);
        hold on;
        title(nameNoise(indexX));
        l_Str = [];
        x = X(:, indexX);
        for indexY = 1: num_f
            y = Y(:, (indexX-1) * num_f + indexY);
            plot(x, y-x, 'linewidth', 2);
            l_Str = [l_Str, nameFilter(indexY)];
        end
        plot([xMin, xMax], [0, 0], 'linewidth', 3);
        l_Str = [l_Str, 'Reference Line'];
        xlabel('PSNR Noised');
        ylabel('PSNR Filtered');
        legend(l_Str);
        set(gca,'linewidth',3,'fontsize',17,'fontname','Times');
    end
    
end

%% 
function [noiseMSE, filteredPSNR] = Ana_sub(pic, type, param)
    Size = size(pic);
    Scale = Size(1) * Size(2);
    
    L = length(param);
    reptNum = 3;
    noiseMSE = zeros(L, 1, 'double');
    filteredPSNR = zeros(L, 6, 'double');
    for l = 1: L
        for r = 1: reptNum
            [picNoise, tmp] = Imnoise(pic, type, param(l));
            noiseMSE(l) = noiseMSE(l) + tmp;
            modelLS = [1; 2; 1] * [1, 2, 1];
            [~, tmp] = Linear_Smooth(pic, picNoise, modelLS);
            filteredPSNR(l, 1) = filteredPSNR(l, 1) + tmp;
            modelLS = [1, 4, 7, 4, 1; ...
                       4, 16, 26, 16, 4; ...
                       7, 26, 41, 26, 7; ...
                       4, 16, 26, 16, 4; ...
                       1, 4, 7, 4, 1;];
            [~, tmp] = Linear_Smooth(pic, picNoise, modelLS);
            filteredPSNR(l, 2) = filteredPSNR(l, 2) + tmp;
            modelMF = [0, 0, 1, 0, 0; ...
                       0, 0, 1, 0, 0; ...
                       1, 1, 1, 1, 1; ...
                       0, 0, 1, 0, 0; ...
                       0, 0, 1, 0, 0;];
            [~, tmp] = M_Filter(pic, picNoise, modelMF);
            filteredPSNR(l, 3) = filteredPSNR(l, 3) + tmp;
            modelMF = [0, 1, 1, 1, 0; ...
                       1, 0, 0, 0, 1; ...
                       1, 0, 1, 0, 1; ...
                       1, 0, 0, 0, 1; ...
                       0, 1, 1, 1, 0;];
            [~, tmp] = M_Filter(pic, picNoise, modelMF);
            filteredPSNR(l, 4) = filteredPSNR(l, 4) + tmp;
            pNew = wiener2(picNoise, [3, 3]);
            MSE = sum(sum((double(pNew) - double(pic)).^2)) / Scale;
            tmp = 10 * log10(255^2 / MSE);
            filteredPSNR(l, 5) = filteredPSNR(l, 5) + tmp;
            pNew = wiener2(picNoise, [5, 5]);
            MSE = sum(sum((double(pNew) - double(pic)).^2)) / Scale;
            tmp = 10 * log10(255^2 / MSE);
            filteredPSNR(l, 6) = filteredPSNR(l, 6) + tmp;
        end
    end
    noiseMSE = noiseMSE / reptNum;
    filteredPSNR = filteredPSNR / reptNum;
end

%%
function [fig_noise, MSE] = Imnoise(pic, type, param)
    S = size(pic);
    Scale = S(1) * S(2);
    switch type
        case 'gaussian'
            fig_noise = imnoise(pic, type, 0, param);
        otherwise
            fig_noise = imnoise(pic, type, param);
    end
    MSE = sum(sum((double(fig_noise) - double(pic)).^2)) / Scale;
end

%% Linear
function [New_fig, PSNR] = Linear_Smooth(pic, picNoise, model)
    S = size(pic);
    Scale = S(1) * S(2);
    tmp = ones(S);
    count = conv2(tmp, model, 'same');
    New_fig = conv2(picNoise, model, 'same');
    New_fig = uint8(New_fig ./ count);
    
    MSE = sum(sum((double(New_fig) - double(pic)).^2)) / Scale;
    PSNR = 10 * log10(255^2 / MSE);
end

%% Median
function [New_fig, PSNR] = M_Filter(pic, picNoise, model)
    Size = size(pic);
    Scale = Size(1) * Size(2);
    New_fig = picNoise;
    model = uint8(model);
    
    padSize = (size(model, 1) - 1) / 2;
    padNum = sum(model(:));
    picNoise = padarray(picNoise, [padSize, padSize]);
    for i = 1: Size(1)
        for j = 1: Size(2)
            map = picNoise(i: i + 2 * padSize, j: j + 2 * padSize) .* model;
            tmp = sort(map(:), 'descend');
            New_fig(i, j) = tmp((padNum + 1) / 2);
        end
    end
    
    MSE = sum(sum((double(New_fig) - double(pic)).^2)) / Scale;
    PSNR = 10 * log10(255^2 / MSE);
end

%% Laplace
function [New_fig, PSNR] = Lap_Sharpen(fig, model, param)
    S = size(fig);
    Scale = S(1) * S(2);
    padSize = (size(model, 1) - 1) / 2;
    
    model(padSize + 1, padSize + 1) = 0;
    count = -1 * ones(S);
    tmp = conv2(count, model, 'same');
    diff = tmp .* double(fig) + conv2(fig, model, 'same');
    New_fig = uint8(double(fig)  + param .* diff);
    
%     imshow(New_fig);
    MSE = sum(sum((double(New_fig) - double(fig)).^2)) / Scale;
    PSNR = 10 * log10(255^2 / MSE);
end

%% MinMax
function [New_fig, PSNR] = MinMaxSharpen(fig, model)
    S = size(fig);
    Scale = S(1) * S(2);
    New_fig = fig;
    model = uint8(model);
    
    pad_S = (size(model, 1) - 1) / 2;
    padNum = sum(model(:));
    fig_Pad = padarray(fig, [pad_S, pad_S]);
    count = ones(S);
    num = conv2(count, model, 'same');
    for i = 1: S(1)
        for j = 1: S(2)
            map = fig_Pad(i: i + 2 * pad_S, j: j + 2 * pad_S) .* model;
            tmp = sort(map(:), 'descend');
            ori = fig(i, j);
            Min = tmp(num(i, j));
            Max = tmp(1);
            if ori - Min < Max- ori
                New_fig(i, j) = Min;
            else
                New_fig(i, j) = Max;
            end
        end
    end
    
    MSE = sum(sum((double(New_fig) - double(fig)).^2)) / Scale;
    PSNR = 10 * log10(255^2 / MSE);
end