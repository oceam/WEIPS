clear;
clc;
% get the path from step1:
% shoud be "dataR\2019tanashi_fukano5all_AP\"
img_path=uigetdir(pwd);
D1=dir(img_path);
savepath=[pwd,'\trainforDTSM\'];
if isfolder(savepath)==0
    mkdir(savepath);
end
% please adjust n to decide how many training image you want to get
for m=3:length(D1)
        RGB_name=[D1(m).name,'_transparent_mosaic_group1.tif'];
        [M,R]=geotiffread(fullfile(img_path,D1(n).name,RGB_name));
        disp(['reading: ' RGB_name])
        RGB=M(:,:,1:3);
        imshow(RGB);
    %    crop 2 patches from one image
        h=imrect;
        p1=wait(h);
        p2=wait(h);
    %     p3=wait(h);
        disp('finished choosing')
    %     hold off
        I1=imcrop(RGB,p1);
        imwrite(I1,[savepath,RGB_name(1:end-4),'_1.jpg']);
        I2=imcrop(RGB,p2);
        imwrite(I2,[savepath,RGB_name(1:end-4),'_2.jpg']);    
        disp('finished saving')
end
    
    
