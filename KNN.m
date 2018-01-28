clc;clear;close all;
 
%Training
image_folder = 'D:\Materi Kuliah\S2 - MMSI\Semester 1\Sistem Penunjang Keputusan\Kategori Data\Total Data\Training';
filenames = dir(fullfile(image_folder, '*.png'));
total_images = numel(filenames);
 
for n = 1:total_images
    full_name = fullfile(image_folder, filenames(n).name);
    img = imread(full_name);
    
    %Preprcessing
    img_pre = medfilt2(img);
    img_resize = imresize(img_pre,[50 50]);
    
    %Gray Level Coocurence Matrix (GLCM) Texture Feature Extraction
    jarak = 1; %distance beetwen pixel
    GLCM = graycomatrix(img_resize,'Offset',[0 jarak; -jarak jarak; -jarak 0; -jarak -jarak]);
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

training = [contrast0;contrast45;contrast90;contrast135;homogeneity0;homogeneity45;homogeneity90;homogeneity135;correlation0;correlation45;correlation90;correlation135;energy0;energy45;energy90;energy135]'

group_train(1:43,:) = 1;
group_train(44:77,:) = 2;
group_train(78:222,:) = 3;

save group_train.mat group_train %TRAINING TARGET
save knn_train.mat training %TRAINING DATA

clc;
clear all;
close all;

%Testing

image_folder_ = 'D:\Materi Kuliah\S2 - MMSI\Semester 1\Sistem Penunjang Keputusan\Kategori Data\Total Data\Testing';
filenames = dir(fullfile(image_folder_, '*.png'));
total_images = numel(filenames);
 
for n = 1:total_images
    full_name = fullfile(image_folder_, filenames(n).name);
    img = imread(full_name);
    
    %Preprcessing
    img_resize = imresize(img,[50 50]);
    img_pre = medfilt2(img_resize);

    %Gray Level Coocurence Matrix (GLCM) Texture Feature Extraction
    jarak = 1; %distance beetwen pixel
    GLCM = graycomatrix(img_pre, 'Offset', [0 jarak; -jarak jarak; -jarak 0; -jarak -jarak]);
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

testing_knn = [contrast0;contrast45;contrast90;contrast135;homogeneity0;homogeneity45;homogeneity90;homogeneity135;correlation0;correlation45;correlation90;correlation135;energy0;energy45;energy90;energy135]'

% group_test(1:19,:) = 1;
% group_test(20:34,:) = 2;
% group_test(35:96,:) = 3;

group_test(1:19,:) = 1;
group_test(20:34,:) = 2;
group_test(35:96,:) = 3;

load knn_train
load group_train

result = knnclassify(testing_knn,training,group_train,5,'euclidean','nearest')

if isempty(group_test)==0
    accuracy=length(find(result==group_test))/size(testing_knn,1)
end


cp = classperf(group_test,result)
cp.CountingMatrix
accuracy = cp.CorrectRate %accuracy