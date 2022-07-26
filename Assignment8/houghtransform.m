clear all;
close all;
clc;

I = imread('board-orig.bmp');
rotI = I;
BW = edge(I, 'Canny', [0.25, 0.5]);

num = 30;

figure;
% subplot(1, 3, 1);
% imshow(BW);
% title('edge detection')
subplot(1, 2, 1);
[H, T, R] = hough(BW, 'RhoResolution', 1, 'Theta', -90: 0.25: 89);
P = houghpeaks(H, num);
imshow(imadjust(H),'XData',T,'YData',R,...
      'InitialMagnification','fit');
colormap(gca,hot);
xlabel('\theta');
ylabel('\rho');
axis on;
axis normal;
hold on;
plot(T(P(:,2)),R(P(:,1)),'s','color','r');
title('Hough');

%%
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
subplot(1, 2, 2);
imshow(I);
hold on;
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
title('line detection')
