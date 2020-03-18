% the second step 2
% read the shape file and extract plot images from orthomosaic
% calculate the height and cannopy cover

clear  
clc

basepath=pwd;
IMGpath=[basepath,'\dataR\2019tanashi_fukano5all_AP\'];
SFname=[basepath,'\dataR\2019tanashi_fukano5all_RE\'];
% save geotiff 
outpath1=[SFname,'1_geo_plot\'];
% save raw  images of each plot
outpath2=[SFname,'2_rotated_plot\'];
outpath3=[SFname,'2_rotated_plot_raw\'];
% % save all the raw dsm, note this dsm is not multipied by binary
outpath4=[SFname,'3_rotated_plot_dsm_raw\'];
outpath5=[SFname,'3_rotated_plot_dsm\'];
outpath6=[SFname,'4_dsm_seg\'];%outpath8
outpath7=[SFname,'5_dsmdtsm_seg\']; %outpath3
% outpath8=[SFname,'6_dsmdtsmmop_seg\']; %outpath5
% outpath9=[SFname,'7_dsm_seg_V\']; %outpath7

outpath0=SFname;

%read shape file 
polygon=[basepath,'\GIS\field1plot.shp'];
% polygon=[basepath,'survey_plot_2\survey_plot_50cm.shp'];
[shape,A] = shaperead(polygon,'Attributes',{'Plot'});
% figure, mapshow(polygon)
num=size(shape,1);
D= dir (IMGpath);
len=length(D); 
s_name='single';


%%
% load DTSM model made from step "makeSegModel"
% may change later
startpath=pwd;
[nameoftrain,trainpath]=uigetfile({'*.mat','All Files'},...
        'Slect Model for segmentation', startpath,...
        'MultiSelect', 'off');
struct=load([trainpath,nameoftrain]);
modelreadname=char(fieldnames(struct));
DTSMModel=struct.(modelreadname);
%%



% read all the geotiff/orthomosaic and then extract the plot
for n=3:len
    NAME=D(n).name;
% read  geotiff/orthomosaic
    if isfile([IMGpath,NAME,'\',NAME,'_transparent_mosaic_group1.tif'])
        [M,R]=geotiffread([IMGpath,NAME,'\',NAME,'_transparent_mosaic_group1.tif']);
        disp(['read rgb: ',NAME]);
        M=M(:,:,1:3);
        info = geotiffinfo([IMGpath,NAME,'\',NAME,'_transparent_mosaic_group1.tif']);
        % boundingbox of shape pylgon
        shape_geobox=zeros(num,4);
        for gg=1:num
            shape_geobox(gg,1)=shape(gg).BoundingBox(1,1); %map_xmin left
            shape_geobox(gg,2)=shape(gg).BoundingBox(1,2); %map_ymin down
            shape_geobox(gg,3)=shape(gg).BoundingBox(2,1); %map_xmax right
            shape_geobox(gg,4)=shape(gg).BoundingBox(2,2); %map_ymax up
        end
        %% transfer Geo-coordinate to image coordinate
        dx=R.CellExtentInWorldX;
        dy=R.CellExtentInWorldY;
        % left upper corner, right down corner
        img_xymin = xy_map2image( R, shape_geobox(:,1), shape_geobox(:,4));
        img_xymax = xy_map2image( R, shape_geobox(:,3)-dx, shape_geobox(:,2)+dy);

        width=ceil(img_xymax(1,1)-img_xymin(1,1));
        height=ceil(img_xymax(1,2)-img_xymin(1,2));
        %% still Bbox
        % calculate image coordinates after cropping
        img_xymax1=[(img_xymin(:,1)+width),(img_xymin(:,2)+height)];
        map_xyimgmin = xy_image2map( R,img_xymin(:,1),img_xymin(:,2));% [x,y]
        map_xyimgmax = xy_image2map( R,img_xymax1(:,1),img_xymax1(:,2));% [x,y]
        % calculate Image boundary coordinates
        map_xmin=map_xyimgmin(:,1);% left
        map_xmax=map_xyimgmax(:,1)+dx;% right
        map_ymax=map_xyimgmin(:,2);% up
        map_ymin=map_xyimgmax(:,2)-dy;% down
        % crop plot images
        RECT=zeros(num,4);
        RECT(:,1)=img_xymin(:,1);%
        RECT(:,2)=img_xymin(:,2);%
        RECT(:,3)=width;%
        RECT(:,4)=height;%
        %% polygon
        polygon_x=zeros(num,length(shape(1).X));    
        polygon_y=zeros(num,length(shape(1).Y));    
        for gg=1:num
            polygon_x(gg,:)=shape(gg).X;
            polygon_y(gg,:)=shape(gg).Y;
        end
        img_xy = xy_map2image( R,polygon_x,polygon_y);

%         % %% if want confirm
%         figure,imshow(M);
%         hold on;
%         for mm=1:length(img_xy)
%             plot(img_xy(mm,1:5),img_xy(mm,7:11))
%         end
        %% read  DSM as well
        [M_dsm,R_dsm]=geotiffread([IMGpath,NAME,'\',NAME,'_dsm.tif']);% ????????????
        disp(['read dsm: ',NAME]);
        % creat the folder for save the data
        mkdir([outpath1,NAME]);
        mkdir([outpath2,NAME]);
        mkdir([outpath3,NAME]);
        mkdir([outpath4,NAME]);
        mkdir([outpath5,NAME]);
%         mkdir([outpath6,NAME]);
        mkdir([outpath7,NAME]);
%         mkdir([outpath8,NAME]);
%         mkdir([outpath9,NAME]);
        %% make containers for save the result
        coverlist=zeros(num,7);
        namelist=cell(num,1);
        %%
        for m=1:num
             % if only want single plant, action for fukano
             % for single planting name like: T25-4
             % for double planting name like: T25-3/T28-10
            % check if the name of the PLOT include string

            if ischar(A(m).Plot)==0
                NAME_plot=num2str(A(m).Plot);
            else
                NAME_plot=A(m).Plot;
            end
            %only read the signle_plots from A
            checkifsingle=find(NAME_plot=='/');
            if isempty(checkifsingle)
            % only read the double_plots from A
            %  if isempty(checkifsingle)~=1 %for double use
            % need to save the result one by one also use for multiline
            %  NAME_plot(checkifsingle)='_';    %for double use        
                % imcrop rgb image
                x=imcrop(M,RECT(m,:));
                % change parameters
                XR=R;
                XR.RasterSize=size(x);
                XR.XWorldLimits=[map_xmin(m),map_xmax(m)];%...............................mapbox
                XR.YWorldLimits=[map_ymin(m),map_ymax(m)];%...............................mapbox
                Tag=info.GeoTIFFTags.GeoKeyDirectoryTag;
            % geotiffwrite([outpath1,NAME,'\',NAME_plot,'.tif'],x,XR,'GeoKeyDirectoryTag',Tag);
                % shape
                Shapei.X=(shape(m).X)';
                Shapei.Y=(shape(m).Y)';
                shape_mask_1  = shapemask( x,XR,Shapei);
                shape_mask=shape_mask_1;

            % calculate the angle from polygon first two points
                x_1=img_xy(m,1);
                x_2=img_xy(m,2);
                y_1=img_xy(m,7);
                y_2=img_xy(m,8);
                angle_pre=atand((y_2-y_1)/(x_2-x_1));
                if -90 < angle_pre && angle_pre< -45
                    angle=-(90+angle_pre);
                elseif -45<angle_pre && angle_pre<0
                    angle=angle_pre;
                else
                    angle=-angle_pre;
                end
                % if size(x,3)==3
                x_masked=x.*uint8(shape_mask);
                geotiffwrite([outpath1,NAME,'\',NAME_plot,'.tif'],x_masked,XR,'GeoKeyDirectoryTag',Tag);
                % imcrop dsm
                x_dsm=imcrop(M_dsm,RECT(m,:));
                x_masked_dsm=x_dsm.*single(shape_mask);
                % angle
                x_rotated=imrotate(x_masked,angle);
                shape_mask_rotated=imrotate(shape_mask,angle);
                box=regionprops(shape_mask_rotated,'BoundingBox');
                x_rot_crop=imcrop(x_rotated,box.BoundingBox);

                %
                x_rotated_dsm=imrotate(x_masked_dsm,angle);
                shape_mask_rotated=imrotate(shape_mask,angle);
                box=regionprops(shape_mask_rotated,'BoundingBox');
                x_rot_crop_dsm=imcrop(x_rotated_dsm,box.BoundingBox);
                % check if the name of the PLOT include string
                if isstring(A(m).Plot)==0
                    NAME_plot=num2str(A(m).Plot);
                else
                    NAME_plot=A(m).Plot;
                end

                %% save original rgb
                geotiffwrite([outpath1,NAME,'\',NAME_plot,'.tif'],x_masked,XR,'GeoKeyDirectoryTag',Tag);
                imwrite(x_rot_crop,[outpath2,NAME,'\',NAME_plot,'.jpg']);
                save([outpath3,NAME,'\',NAME_plot,'_rgb.mat'],'x_rot_crop');
                %% write dsm as gray images
                x_rot_crop_dsm_1=x_rot_crop_dsm;
                idx_0=find(x_rot_crop_dsm_1==0);
                idx_n0=find(x_rot_crop_dsm_1~=0);     
                amax=double(max(x_rot_crop_dsm_1(idx_n0)));
                amin=double(min(x_rot_crop_dsm_1(idx_n0)));
                x_rot_crop_dsm_1(idx_0)=amin;
                new_DSM_img=mat2gray(x_rot_crop_dsm_1,[amin,amax]);
                imwrite(new_DSM_img ,[outpath5,NAME,'\',NAME_plot,'_dsm.jpg']);
                save([outpath4,NAME,'\',NAME_plot,'_dsm.mat'],'x_rot_crop_dsm');
                disp(['saved Plot:',num2str(m),'_' , NAME_plot] );
                %% start to phenotyping from here:
                idx_v0=find(x_rot_crop_dsm==0);
                idx_n0=find(x_rot_crop_dsm~=0);   
                dsm_p95=prctile(x_rot_crop_dsm(idx_n0),95);
                dsm_p99=prctile(x_rot_crop_dsm(idx_n0),99);
                
                % use the dsm to cut the background to elimite the effect of grass
                % cannot run DTSM on RGB first, because we need to handle 
                % the field with weed and without weed? 
                %% first dsm
                th_1=range(x_rot_crop_dsm(idx_n0));
                % cut the ground
                th=min(x_rot_crop_dsm(idx_n0))+th_1*0.4;
                idx_d=find(x_rot_crop_dsm>th);
                [d_w,d_h,d_z]=size(x_rot_crop_dsm);
                newBin_dsm=logical(zeros(d_w,d_h));
                newBin_dsm(idx_d)=1;
                newRgb_dsm=im2double(x_rot_crop).*newBin_dsm;
                %% 2nd rgb 
                % start here calculate the coverage
                filtsize = 10;
                [binimg,rgbimg] = extractVE(DTSMModel,newRgb_dsm,filtsize);

%                 %% actions if needed
                newBin_1=bwareafilt(binimg,1);
                newRgb=rgbimg.*newBin_1;

                coverage=sum(newBin_1(:));
                [xx,yy]=size(newBin_1);
                [ww,hh]=size(x_rot_crop_dsm); 
                % dsm need to check this part
                idx_n=find(x_rot_crop_dsm~=0);
                newBin=newBin_1;
                % imshowpair(binimg,newBin)
                dsmimg_v=newBin.*x_rot_crop_dsm;
                idx=find(dsmimg_v~=0);
                dsm_v_p99=prctile(dsmimg_v(idx),99);
                dsm_v_p95=prctile(dsmimg_v(idx),95);

                dsmimg_g=~newBin.*x_rot_crop_dsm;
                idx_g=find(dsmimg_g~=0);
                dsm_g_p1=prctile(dsmimg_g(idx_g),1);
                dsm_g_p5=prctile(dsmimg_g(idx_g),5);
                
                coverlist(m,1)=coverage/(xx*yy);
                coverlist(m,2)=dsm_v_p99;
                coverlist(m,3)=dsm_g_p1;
                coverlist(m,4)=dsm_v_p95;
                coverlist(m,5)=dsm_g_p5;
                coverlist(m,6)=dsm_p95;
                coverlist(m,7)=dsm_p99;
                namelist{m,1}=NAME_plot;

                % [outpath4,NAME,'\',NAME_plot,'_dsm.mat']
%                 save([outpath7,NAME,'\',NAME_plot,'_bin.mat'],'binimg');
%                 imwrite(rgbimg,[outpath7,NAME,'\',NAME_plot,'_rgb.jpg']);
                imwrite(newRgb ,[outpath7,NAME,'\',NAME_plot,'_dsmV_rgb.jpg']);
%                 save([outpath8,NAME,'\',NAME_plot,'_bin.mat'],'newBin');

                %write dsmimg_v as jpg image
                dsmimg_v_1=dsmimg_v;
                idx_0=find(dsmimg_v_1==0);
                idx_n0=find(dsmimg_v_1~=0);     
                amax=double(max(dsmimg_v_1(idx_n0)));
                amin=double(min(dsmimg_v_1(idx_n0)));
                dsmimg_v_1(idx_0)=amin;
                new_DSM_img_v=mat2gray(dsmimg_v_1,[amin,amax]);
                imwrite(new_DSM_img_v ,[outpath7,NAME,'\',NAME_plot,'_dsmV.jpg']);
%                 save([outpath9,NAME,'\',NAME_plot,'_dsm.mat'],'dsmimg_v');
                imwrite(newBin_dsm ,[outpath7,NAME,'\',NAME_plot,'_dsmAll_bin.jpg']);
                imwrite(newRgb_dsm ,[outpath7,NAME,'\',NAME_plot,'_dsmAll_rgb.jpg']);
%                 save([outpath6,NAME,'\',NAME_plot,'_bin.mat'],'newBin_dsm');
            end
        end
    end
       T=table (namelist(:,1),coverlist(:,1),coverlist(:,2),coverlist(:,3),coverlist(:,4),...
       coverlist(:,5),coverlist(:,6),coverlist(:,7),...
       'VariableNames',{'PlotID' 'coverageR' 'dsm_v_p99' 'dsm_g_p1'...
       'dsm_v_p95' 'dsm_g_p5' ...
       'dsm_p95' 'dsm_p99'});
        writetable(T,[outpath0,NAME,'.csv'],'Delimiter',',');
end