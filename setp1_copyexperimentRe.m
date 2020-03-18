% the first step 1 
% copy the necerrcey images from Pix4Dmapper
clear 
clc

% choose the Pix4Dmapper project folder 
% eg: Pf=fullfile('E:\pix4dProjects\2019\2019tanashi\fukano5all\');
Pf=uigetdir(pwd);
DofP=dir(Pf);
len=length(DofP);
% define a save path
savepath_1=uigetdir(Pf);
savepath_2=[savepath_1,'\2019tanashi_fukano5all_AP\'];

for n=3:len
    if DofP(n).isdir==1
        
        folder_name=DofP(n).name;
        Rp_Pm=fullfile(folder_name,'1_initial\');
        Pc=fullfile(folder_name,'2_densification\');
        dsmOrt=fullfile(folder_name,'3_dsm_ortho\');
        
        Fname_Rp=[Pf,'\',Rp_Pm,'report\',folder_name,'_report.pdf'];
        Fname_Os=[Pf,'\',Rp_Pm,'params\',folder_name,'_offset.xyz'];
        Fname_Pc=[Pf,'\',Pc,'point_cloud\',folder_name,'_group1_densified_point_cloud.ply'];
        Fname_dsm=[Pf,'\',dsmOrt,'1_dsm\',folder_name,'_dsm.tif'];
        Fname_Ort=[Pf,'\',dsmOrt,'2_mosaic\',folder_name,'_transparent_mosaic_group1.tif'];
        Fname_Pm=[Pf,'\',Rp_Pm,'params\',folder_name,'_pmatrix.txt'];
% creat a new folder to save the extracted data        
        savepath=fullfile(savepath_2,folder_name,'\');
        if isfile(Fname_Ort) 
            mkdir(savepath);
            [status,message,messageId] = copyfile(Fname_Rp, [savepath,folder_name,'_report.pdf']);
            [status,message,messageId] = copyfile(Fname_Pm, [savepath,folder_name,'_pmatrix.txt']);
            [status,message,messageId] = copyfile(Fname_Os, [savepath,folder_name,'_offset.xyz']);
            [status,message,messageId] = copyfile(Fname_Pc, [savepath,folder_name,'_group1_densified_point_cloud.ply']);
            [status,message,messageId] = copyfile(Fname_dsm, [savepath,folder_name,'_dsm.tif']);
            [status,message,messageId] = copyfile(Fname_Ort, [savepath,folder_name,'_transparent_mosaic_group1.tif']);
     
            
           disp(['finished copy: ',folder_name]);
        else
           disp(['no Pix4D output for : ',folder_name]); 
        end
    end
end