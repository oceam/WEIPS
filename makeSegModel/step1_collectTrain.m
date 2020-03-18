% collect the training data from image by click
% 2015.11.26
% by Oceam, The University of Tokyo
% last modefied 2019.06.05
% for UAV soybean use 
clc
clear all

% please change donow value to collect the training data from different classes; 
donow=1;

% change it to your own folder, to creat a new training folder was recommend 
startpath=pwd;

% change this part for you own file format  
[filename,trainpath]=uigetfile({'*.jpg','All Image Files'},...
        'Slect Image', startpath,...
        'MultiSelect', 'on');
    
L=length(filename);
names=filename';
startclass1='1vegetation';
startclass2='2background';

if donow==1
    startclass=startclass1;
elseif donow==2
    startclass=startclass2;
end

allclicked=[];
allsavename=[];
allrecordedfeature=[];
% can change area depends on the iamge resolution
Area=5;
for i=1:L
    name=names{i};
%     if (strcmpi(name(end-3:end), '.jpg')==1) % if current file IS JPG:        
        RGB = imread([trainpath,name]);
        %RGB information
        RGB1=im2double(RGB);       
        %Hue Saturation Luminance/Intensity
        HSV1 = rgb2hsv(RGB1);
        cform = makecform('srgb2lab');
        LAB1 = applycform(RGB1,cform);
        % record the coordinates for each image
%         clicked=round(clickRecord(RGB,Area(1)));
        clicked=round(clickRecord(RGB,Area));
        [row,col]=size(clicked);
        % caculate the features
        recordedTfeature=zeros(row,9);
        recordedname=cell(row,1);
        for m=1:row
            Tfeatureall=[];
            r=RGB1(clicked(m,2),clicked(m,1),1);
            g=RGB1(clicked(m,2),clicked(m,1),2);
            b=RGB1(clicked(m,2),clicked(m,1),3);
            h1=HSV1(clicked(m,2),clicked(m,1),1);
            s1=HSV1(clicked(m,2),clicked(m,1),2);
            v1=HSV1(clicked(m,2),clicked(m,1),3);
            l1=LAB1(clicked(m,2),clicked(m,1),1);
            a1=LAB1(clicked(m,2),clicked(m,1),2);
            b1=LAB1(clicked(m,2),clicked(m,1),3);

         recordedTfeature(m,:)=[r,g,b,h1,s1,v1,l1,a1,b1]; 
         recordedname{m,1}=name;
        end
        % clicked coordinates for save
        allrecordedfeature=[allrecordedfeature;recordedTfeature];
        savename=repmat(name,row,1);
        allclicked=[allclicked;clicked];
        allsavename=[allsavename;recordedname];
%     end
end
T=table (allsavename,...
    allclicked(:,1),allclicked(:,2),...
    allrecordedfeature(:,1),allrecordedfeature(:,2),allrecordedfeature(:,3),...
    allrecordedfeature(:,4),allrecordedfeature(:,5),allrecordedfeature(:,6),...
    allrecordedfeature(:,7),allrecordedfeature(:,8),allrecordedfeature(:,9),...
    'VariableNames',{'imgnames' 'X' 'Y' 'R' 'G' 'B' 'H1' 'S1' 'V1' 'L1' 'A1' 'B1' });
writetable(T,[trainpath,'/',startclass,'.txt'],'Delimiter',',');

