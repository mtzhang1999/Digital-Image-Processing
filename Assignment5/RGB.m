clear all;
close all;
clc;

fig_A = imread('作业5_A.jpg');
fig_B = imread('作业5_B.jpg');

global flag;
flag = 1;
global mode;
mode = 3;

re_figA = REG(fig_A, fig_B);
re_figB = REG(fig_B, fig_A);

function re_fig = REG(fig, m)
    global flag;
    global mode;

    switch mode
        case 1
            fig_gray = rgb2gray(fig);
            m_gray = rgb2gray(m);
        case 2
            fig_gray = round(mean(fig, 3));
            m_gray = round(mean(m, 3));
        otherwise
            fig_gray = round(max(fig, [], 3));
            m_gray = round(max(m, [], 3));
    end

    D_fig = distribution(fig_gray);
    D_m = distribution(m_gray);
    remap = zeros(256, 1, 'double');
    for i = 1: 256
        [~, remap(i)] = min(abs(D_m - D_fig(i)));
    end

    D_tmp = zeros(256, 1, 'double');
    for i = 1: 256
        D_tmp(remap(i)) = D_fig(i);
    end
    
    l = 0;
    if flag
        for i = 1: 256
            if D_tmp(i) == 0
                D_tmp(i) = l;
            else
                l = D_tmp(i);
            end
        end
    else
        for i = 256: -1: 1
            if D_tmp(i) == 0
                D_tmp(i) = l;
            else
                l = D_tmp(i);
            end
        end
    end
    remap(2: end) = remap(2: end) ./ (1: 255)';
    
    re_fig = fig;
    S = size(fig);
    for i = 1: S(1)
        for j = 1: S(2)
            tmp = double(fig_gray(i, j));
            if tmp == 0
                re_fig(i, j, :) = re_fig(i, j, :) + remap(1);
            else
                re_fig(i, j, :) = re_fig(i, j, :) * remap(tmp + 1);
            end
        end
    end

    figure;
    subplot(2, 3, 1);
    imshow(fig);
    title('origin_fig');
    subplot(2, 3, 2);
    bar([0: 255], cdf2pdf(D_fig));
    title('origin_distribution');
    xlim([0, 300]);
    subplot(2, 3, 3);
    bar([0: 255], cdf2pdf(D_m));
    title('expected_distribution');
    xlim([0, 300]);
    
    subplot(2, 3, 4);
    imshow(re_fig);
    title('fig_new');
    subplot(2, 3, 5);
    bar([0: 255], cdf2pdf(D_tmp));
    title('cdf_new');
    xlim([0, 300]);
    subplot(2, 3, 6);
    refig_gray = round(max(re_fig, [], 3));
    switch mode
        case 1
            refig_gray = rgb2gray(re_fig);
        case 2
            refig_gray = round(mean(re_fig, 3));
        otherwise
            refig_gray = round(max(re_fig, [], 3));
    end
    bar([0: 255], cdf2pdf(distribution(refig_gray)));
    title('real_cdf');
    xlim([0, 300]);
    
end


function D = distribution(fig)
    S = size(fig);
    D = zeros(256, 1, 'double');
    for i = 1: S(1)
        for j = 1: S(2)
            tmp = double(fig(i, j));
            D(tmp + 1) = D(tmp + 1) + 1;
        end
    end
    D = D / (S(1) * S(2));
    D = pdf2cdf(D);
end

function cdf = pdf2cdf(pdf)
    global flag;
    cdf = pdf;
    if flag
        for i = 2: length(pdf)
            cdf(i) = cdf(i) + cdf(i - 1);
        end
    else
        for i = length(pdf) - 1 : -1 : 1
            cdf(i) = cdf(i) + cdf(i + 1);
        end
    end
end

function pdf = cdf2pdf(cdf)
    global flag;
    pdf = cdf;
    if flag
        pdf(2: end) = pdf(2: end) - pdf(1: end - 1);
    else
        pdf(1: end - 1) = pdf(1: end - 1) - pdf(2: end);
    end
end
