function [ mapxy ] = xy_image2map( R,imgx,imgy )

% read geo parameters 
img_x0=R.XIntrinsicLimits(1);%0.5
img_y0=R.YIntrinsicLimits(1);%0.5
map_xmin=R.XWorldLimits(1);
map_ymax=R.YWorldLimits(2);
dx=R.CellExtentInWorldX;
dy=R.CellExtentInWorldY;
n=size(imgx,1);
% image to geo coordinate
for i=1:n
% calculate target left upper geo coordinate
mapx=(imgx-img_x0)*dx+map_xmin;
mapy=map_ymax-(imgy-img_y0)*dy;
mapxy=[mapx,mapy];
end
end

