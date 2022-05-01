clear all;clc;close all
A=imread('AmScope MT.bmp');
% A2=A(:,:,1)+A(:,:,2)+A(:,:,3);    % a bit more contrast
A2=rgb2gray(A);  % since green marker used no need for red blue layers
th1=34.33;
D=size(A2);

A2(A2<th1)=0;
A2(A2>th1)=255;

for i=1:D(1)
    for j=1:D(2)
        if A2(i,j) ==255
           A2(i,j) =0; 
        elseif A2(i,j) ==0
            A2(i,j) =255; 
        end
        j=j+1;
    end
    i=i+1;
end


figure(1);imshow(A);
figure(2);imshow(A2);
A20=~A2;
area_threshold=95;
A21 = bwareaopen(A20,area_threshold);
figure(10);imshow(A21);

A32= rgb2gray(A);
figure(30);imshow(A32);
colormap jet(55);
Thickness = double(A32*0);
max_think = 0.5;
A32 = double(A32);
for i=1:D(1)
    for j=1:D(2)
        if A32(i,j) >= 50 
            Thickness(i,j) = (((A32(i,j))/10)-5)*((2/41)*max_think);
        elseif A32(i,j) < 50
           Thickness(i,j) =0; 
        end
        j=j+1;
    end
    i=i+1;
end

Area = A21*(0.5/12);
Thickness = double(Thickness);
Volume = Area.*Thickness;
Tot_Vol = sum(Volume,'all');


A22=imfill(A21, 'holes');
figure(11); imshow(A22);
[B,L] = bwboundaries(A22,'noholes');
map=zeros(length(B),3);cmap=colormap(map);
figure(3);imshow(label2rgb(L,cmap, [.5 .5 .5]))
m=size(A22);
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
   sp = num2str(k);
   text(mean(boundary(:,2)),mean(boundary(:,1)),sp,'Color', 'g')
%    Area(k)= length(boundary);
%    
%    for j = 1:m(1)
%     for i = 1:m(2)
%         if B(i,j)>
end
length(B)
% i=sum(Area);
White=nnz(A22);
m=size(A22);
Area_ratio = White/( m(1)*m(2));

PSF = fspecial('gaussian',5,5);
A3 = deconvlucy(uint8(255*(~A20)),PSF,5);
figure(4);imshow(A3);

R=rgb2gray(A); % It is gray now
y=colormap(jet(55));
imwrite(R,y,'rgb.jpg','jpg'); % Re-change it to colored one 
figure(5);imshow('rgb.jpg');


