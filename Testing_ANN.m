clc;clear;close all;warning off all;
 
image_folder = 'D:\Materi Kuliah\S2 - MMSI\Semester 1\Sistem Penunjang Keputusan\Kategori Data\Total Data\Testing';
filenames = dir(fullfile(image_folder, '*.png'));
total_images = numel(filenames);

for n = 1:total_images
    full_name = fullfile(image_folder, filenames(n).name);
    img = imread(full_name);
    
    %Preprocessing
    img_resize = imresize(img,[50 50]);
    img_pre = medfilt2(img_resize);

    %Gray Level Coocurence Matrix (GLCM) Texture Feature Extraction
    jarak = 2; %distance beetwen pixel
    GLCM = graycomatrix(img_pre,'NumLevels',8, 'GrayLimits',[], 'Offset',[0 jarak; -jarak jarak; -jarak 0; -jarak -jarak]);
    stats = graycoprops(GLCM,{'contrast','homogeneity','correlation','energy'});

    contrast = stats.Contrast;
    contrast0(n) = contrast(1);
    contrast45(n) = contrast(2);
    contrast90(n) = contrast(3);
    contrast135(n) = contrast(4);
    
    homogeneity = stats.Homogeneity;
    homogeneity0(n) = homogeneity(1);
    homogeneity45(n) = homogeneity(2);
    homogeneity90(n) = homogeneity(3);
    homogeneity135(n) = homogeneity(4);
   
    correlation = stats.Correlation;
    correlation0(n) = correlation(1);
    correlation45(n) = correlation(2);
    correlation90(n) = correlation(3);
    correlation135(n) = correlation(4);
    
    energy = stats.Energy;
    energy0(n) = energy(1);
    energy45(n) = energy(2);
    energy90(n) = energy(3);
    energy135(n) = energy(4);
    
end

input = [contrast0;contrast45;contrast90;contrast135;homogeneity0;homogeneity45;homogeneity90;homogeneity135;...
        correlation0;correlation45;correlation90;correlation135;energy0;energy45;energy90;energy135];

[~,N] = size(input);
t1 = [1;0;0]; %Benign
t2 = [0;1;0]; %Malignant
t3 = [0;0;1]; %Normal
target(:,1:19) = [t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1 t1]
target(:,20:34) = [t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2]
target(:,35:96) = [t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3 t3]
target1 = vec2ind(target)

%Load trained weight
load jst

output = sim(net,input)
testIndices = vec2ind(output) %predict

plotconfusion(target,output) %Testing accuracy
cp = classperf(target1,testIndices);
cp.CountingMatrix
cp.CorrectRate