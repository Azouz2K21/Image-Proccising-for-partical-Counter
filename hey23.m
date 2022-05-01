clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 18;

%===============================================================================
% Read in gray scale demo image.
folder = pwd; % Determine where demo folder is (works with all versions).
baseFileName = 'Capture10.PNG';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
  % The file doesn't exist -- didn't find it there in that folder.
  % Check the entire search path (other folders) for the file by stripping off the folder.
  fullFileNameOnSearchPath = baseFileName; % No path this time.
  if ~exist(fullFileNameOnSearchPath, 'file')
    % Still didn't find it.  Alert user.
    errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
    uiwait(warndlg(errorMessage));
    return;
  end
end
rgbImage = imread(fullFileName);

% Get the dimensions of the image.
% numberOfColorChannels should be = 1 for a gray scale image, and 3 for an RGB color image.
[rows, columns, numberOfColorChannels] = size(rgbImage)
if numberOfColorChannels > 1
  % It's not really gray scale like we expected - it's color.
  % Use weighted sum of ALL channels to create a gray scale image.
  %   grayImage = rgb2gray(rgbImage);
  % ALTERNATE METHOD: Convert it to gray scale by taking only the green channel,
  % which in a typical snapshot will be the least noisy channel.
  grayImage = rgbImage(:, :, 1); % Take red channel.
else
  grayImage = rgbImage; % It's already gray scale.
end
% Now it's gray scale with range of 0 to 255.

% Display the image.
subplot(3, 3, 1);
imshow(grayImage, []);
title('Original Image', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
hp = impixelinfo();

%------------------------------------------------------------------------------
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;

% Binarize the image
binaryImage = grayImage > 128;
% Display the image.
subplot(3, 3, 2);
imshow(binaryImage, []);
title('Binary Image', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');

% Make one type of mask, and display it.
mask1 = bwareafilt(binaryImage, 1);
mask1 = imfill(mask1, 'holes');
% Display the image.
subplot(3, 3, 3);
imshow(mask1, []);
title('Mask1 = exact outline of biggest blob', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
% Find boundary and display it
boundary1 = bwboundaries(mask1);
hold on;
plot(boundary1{1}(:, 2), boundary1{1}(:, 1), 'r-', 'LineWidth', 2);

% Make another type of mask, and display it.
mask2 = imclose(binaryImage, true(3));
mask2 = bwareafilt(mask2, 1);
mask2 = imfill(mask2, 'holes');
mask2 = bwconvhull(mask2);
% Display the image.
subplot(3, 3, 4);
imshow(mask2, []);
title('Mask2 = smoothed then convex hull', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
% Find boundary and display it
boundary2 = bwboundaries(mask2);
hold on;
plot(boundary2{1}(:, 2), boundary2{1}(:, 1), 'r-', 'LineWidth', 2);

% Make another type of mask, and display it.
windowWidth = 89;
kernel = ones(windowWidth) / windowWidth^2;
threshold = 0.13;
mask3 = conv2(double(binaryImage), kernel, 'same') > threshold;
mask3 = bwareafilt(mask3, 1);
mask3 = imfill(mask3, 'holes');
% Display the image.
subplot(3, 3, 5);
imshow(mask3, []);
title('Mask3 = blurred then thresholded', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
% Find boundary and display it
boundary3 = bwboundaries(mask3);
hold on;
plot(boundary3{1}(:, 2), boundary3{1}(:, 1), 'r-', 'LineWidth', 2);

% Make another type of mask, and display it.
mask4 = imclose(binaryImage, true(3));
mask4 = bwareafilt(mask4, 1);
mask4 = imfill(mask4, 'holes');
mask4 = bwconvhull(mask4);
se = strel('disk', 35, 0);
mask4 = imdilate(mask4, se);
% Display the image.
subplot(3, 3, 6);
imshow(mask4, []);
title('Mask4 = dilated convex hull', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
% Find boundary and display it
boundary4 = bwboundaries(mask4);
hold on;
plot(boundary4{1}(:, 2), boundary4{1}(:, 1), 'r-', 'LineWidth', 2);

% Make one type of mask, and display it.
mask5 = bwareafilt(binaryImage, 1);
mask5 = imfill(mask5, 'holes');
% Find centroid
props = regionprops(mask5, 'Centroid');
% Create a logical image of a circle with specified
% diameter, center, and image size.
% First create the image.
[columnsInImage rowsInImage] = meshgrid(1:columns, 1:rows);
% Next create the circle in the image.
centerX = props.Centroid(1);
centerY =  props.Centroid(2);
radius = 200;
mask5 = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
% circlePixels is a 2D "logical" array.
% Display the image.
subplot(3, 3, 7);
imshow(mask5, []);
title('Mask5 = perfect circle', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
% Find boundary and display it
boundary5 = bwboundaries(mask5);
hold on;
plot(boundary5{1}(:, 2), boundary5{1}(:, 1), 'r-', 'LineWidth', 2);

%=====================================================================
% Show all boundaries on original image.
% Display the image.
figure;
imshow(binaryImage, []);
title('All Boundaries', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
%------------------------------------------------------------------------------
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;

hold on;
plot(boundary1{1}(:, 2), boundary1{1}(:, 1), 'r-', 'LineWidth', 2);
plot(boundary2{1}(:, 2), boundary2{1}(:, 1), 'r-', 'LineWidth', 2);
plot(boundary3{1}(:, 2), boundary3{1}(:, 1), 'r-', 'LineWidth', 2);
plot(boundary4{1}(:, 2), boundary4{1}(:, 1), 'r-', 'LineWidth', 2);
plot(boundary5{1}(:, 2), boundary5{1}(:, 1), 'r-', 'LineWidth', 2);

% Compute number of white, black, and area fraction of each mask
fprintf('Mask #    Num White,  Num Black,  Num Mask,  Area Fraction\n----------------------------------------------------------\n');
% For mask #1:
areaMask = nnz(mask1);
areaWhite = nnz(mask1 & binaryImage);
areaBlack = areaMask - areaWhite;
areaFraction = areaWhite / areaMask;
fprintf('   1 %12d %10d %11d %12.3f\n', areaWhite, areaBlack, areaMask, areaFraction);
% For mask #2:
areaMask = nnz(mask2);
areaWhite = nnz(mask2 & binaryImage);
areaBlack = areaMask - areaWhite;
areaFraction = areaWhite / areaMask;
fprintf('   2 %12d %10d %11d %12.3f\n', areaWhite, areaBlack, areaMask, areaFraction);
% For mask #3:
areaMask = nnz(mask3);
areaWhite = nnz(mask3 & binaryImage);
areaBlack = areaMask - areaWhite;
areaFraction = areaWhite / areaMask;
fprintf('   3 %12d %10d %11d %12.3f\n', areaWhite, areaBlack, areaMask, areaFraction);
% For mask #4:
areaMask = nnz(mask4);
areaWhite = nnz(mask4 & binaryImage);
areaBlack = areaMask - areaWhite;
areaFraction = areaWhite / areaMask;
fprintf('   4 %12d %10d %11d %12.3f\n', areaWhite, areaBlack, areaMask, areaFraction);
% For mask #5:
areaMask = nnz(mask5);
areaWhite = nnz(mask5 & binaryImage);
areaBlack = areaMask - areaWhite;
areaFraction = areaWhite / areaMask;
fprintf('   5 %12d %10d %11d %12.3f\n', areaWhite, areaBlack, areaMask, areaFraction);