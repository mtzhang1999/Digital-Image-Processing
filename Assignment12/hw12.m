clear all;
close all;
clc;

save = 1;
kernel_size = [5, 5];

for kernel_type = 0: 2
    for Noise_Var = [0, 8, 16, 32]
        main(save, Noise_Var, kernel_type, kernel_size);
    end
end

function main(save, Noise_Var, kernel_type, kernel_size)
    fig = imread('Lena.bmp');
    fig = im2double(fig);
    fig_size = size(fig);
    figure;
     subplot(2, 2, 1);
     imshow(fig);
     title('original img');
    x = ones(1, kernel_size(1))' * (1: kernel_size(1)) - (kernel_size(1) + 1) / 2;
    y = (1: kernel_size(2))' * ones(1, kernel_size(2)) - (kernel_size(2) + 1) / 2;
    switch kernel_type
        case 0
            kernel = exp(sqrt(x.^2 + y.^2) / 240);
        case 1
            k = 0.01;
            kernel = exp(-k * (x.^2 + y.^2) .^ (5 / 6));
        case 2
            x = ones(1, kernel_size(1))' * (1: kernel_size(1));
            y = (1: kernel_size(2))' * ones(1, kernel_size(2));
            vx = 0.1;
            vy = 0.1;
            T = 1;
            kernel = T ./ (pi * (vx * x + vy * y)) .* sin(pi * (vx * x + vy * y)) .* ...
                exp(-1j * pi * (vx * x + vy * y));
    end
    kernel = kernel / sum(kernel(:));

    fig_extension = conv2(fig, kernel, 'full');

    if Noise_Var ~= 0
        noise = normrnd(0, sqrt(Noise_Var), size(fig_extension)) / 255;
        fig_extension = min(1, fig_extension + noise);
    end

    res = abs(fig_extension((kernel_size(1) + 1) / 2: ...
        (kernel_size(1) - 1) / 2 + fig_size(1), ...
        (kernel_size(1) + 1) / 2: ...
        (kernel_size(1) - 1) / 2 + fig_size(1)) - fig).^2;
    MSE = mean(res(:));
    PSNR = 10 * log10(1 / MSE);
    subplot(2, 2, 2);
    imshow(abs(fig_extension));
    title(['Noise Blur:PSNR=', num2str(PSNR)]);


    %%
    extension_size = fig_size + kernel_size - 1;
    kernel_extension = zeros(extension_size, 'double');
    kernel_extension(1: kernel_size(1), 1: kernel_size(2)) = kernel;

    fig_F = fftshift(fft2(fig_extension));
    kernel_F = fftshift(fft2(kernel_extension));

    bestPSNR_i = 0;
    bestfig_I = fig;
    bestK = 0;
    for k = exp(-3: 0.01: 3)
        [fig_RI, PSNR_i] = Inv(fig_F, kernel_F, fig, k);
        if PSNR_i > bestPSNR_i
            bestPSNR_i = PSNR_i;
            bestfig_I = fig_RI;
            bestK = k;
        end
    end
    subplot(2, 2, 3);
    imshow(abs(bestfig_I));
    title(['Inverse filter£ºK=', num2str(bestK), ...
        ', PSNR=', num2str(bestPSNR_i)]);
    if save
        imwrite(bestfig_I, ['InverseFilter\', num2str(kernel_type), '\Noise_Var', ...
            num2str(Noise_Var), '.jpg']);
    end

    bestPSNR_W = 0;
    bestfig_W = fig;
    best_S = 0;
    for s = exp(3: 0.01: 8)
        [fig_RW, PSNRW] = Wiener(fig_F, kernel_F, fig, Noise_Var, s);
        if PSNRW > bestPSNR_W
            bestPSNR_W = PSNRW;
            bestfig_W = fig_RW;
            best_S = s;
        end
    end
    subplot(2, 2, 4);
    imshow(abs(bestfig_W));
    title(['Wiener filter£ºS=', num2str(best_S), ...
      ', PSNR=', num2str(bestPSNR_W)]);
    if save
        imwrite(bestfig_W, ['WienerFilter\', num2str(kernel_type), '\Noise_Var', ...
            num2str(Noise_Var), '.jpg']);
    end
end

%% Inverse filter
function [fig_R, PSNR] = Inv(fig_F, kernel_F, fig, para)
    tmp = abs(kernel_F);
    index = tmp < para;
    kernel_F(index) = para * kernel_F(index) ./ tmp(index);
    
    fig_RF = fig_F ./ kernel_F;
    fig_R = ifft2(ifftshift(fig_RF));
    fig_R = fig_R(1: size(fig, 1), 1: size(fig, 2));

    res = abs(fig_R - fig) .^ 2;
    MSE = mean(res(:));
    PSNR = 10 * log10(1 / MSE);
end

%% Wiener
function [fig_R, PSNR] = Wiener(fig_F, kernel_F, fig, Noise_Var, para)
    Sn = Noise_Var / 255 ^ 2;
    Sf = mean(mean(fig .^ 2));
    K = para * Sn / Sf;
    k = abs(kernel_F) .^ 2 ./ (abs(kernel_F) .^ 2 + K);
    k = k / max(k(:));
    
    fig_RF = k .* fig_F ./ kernel_F;
    fig_R = ifft2(ifftshift(fig_RF));
    fig_R = fig_R(1: size(fig, 1), 1: size(fig, 2));

    res = abs(fig_R - fig) .^ 2;
    MSE = mean(res(:));
    PSNR = 10 * log10(1 / MSE);
end
