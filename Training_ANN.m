clc;clear;close all;warning off all;
 
image_folder = 'D:\Materi Kuliah\S2 - MMSI\Semester 1\Sistem Penunjang Keputusan\Kategori Data\Total Data\Training';
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

input = [contrast0;contrast45;contrast90;contrast135;homogeneity0;homogeneity45;homogeneity90;homogeneity135;...
        correlation0;correlation45;correlation90;correlation135;energy0;energy45;energy90;energy135];
    
[~,N] = size(input);
t1 = [1;0;0]; %Benign
t2 = [0;1;0]; %Malignant
t3 = [0;0;1]; %Normal
target(:,1:43) = [t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1,t1];
target(:,44:77) = [t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2,t2];
target(:,78:222) = [t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3 t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3 t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3,t3];

rng(27);

% Training using Backpropagation ANN
net = newff(input,target,{15},{'logsig','tansig'},'traingd');
% net.IW{1,1} = [-0.1920,-0.4876,-1.1113,1.3023,1.1390;...
%     1.7783,-0.5090,-0.6322,0.8257,0.0001;...
%     0.1504,1.5682,0.5776,1.2974,-0.0645;...
%     0.0551,-1.2048,-0.9473,1.0189,1.0549;...
%     -1.0248,1.4706,0.8446,-0.6332,0.4195;...
%     -0.0383,1.4274,-1.3556,0.6851,0.4056;...
%     0.4467,1.0665,0.5537,-1.0882,1.2943;...
%     0.5339,-1.1961,-0.0174,-1.3992,0.9105];
%  
% net.b{1,1} = [2.1220;-1.5157;-0.9094;-0.3031;-0.3031;-0.9094;1.5157;2.1220];
%   
% net.LW{2,1} = [0.1534,-0.6342,-0.5201,0.7730,-0.9427,-0.0202,-0.6641,0.9574];
%  
% net.b{2,1} = [0.4254];

bobot_hidden1 = net.IW{1,1}
bias_hidden1 = net.b{1,1}
bobot_keluaran1 = net.LW{2,1}
bias_keluaran1 = net.b{2,1}

net.trainParam.epochs = 30000;
net.performFcn = 'mse';
net.trainParam.lr = 0.5;
% net.trainParam.mc = 0.95;
net.trainParam.goal = 0.01;
% net.trainParam.max_fail = 20000;
net.divideFcn = '';
[net, tr, Y, ee] = train(net,input,target);

output = sim(net,input)
trainIndices = vec2ind(output) %predict

hasilbobot_hidden = net.IW{1,1}
hasilbias_hidden = net.b{1,1}
hasilbobot_keluaran = net.LW{2,1}
hasilbias_keluaran = net.b{2,1}
jumlah_iterasi = tr.num_epochs
nilai_keluaran = Y
nilai_error = ee
D = abs(nilai_error).^2;
error_MSE = sum(D(:))/numel(nilai_error)
plotperform(tr)
plotconfusion(target,output) %Training accuracy

save jst.mat net