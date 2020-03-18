function [ xy ] =  xy_map2image( R,mapx,mapy )
% mapx,mapy geo coordinate of leftupper corner 
% read geo parameters 
% Limits of image in intrinsic units in the x-dimension, specified as a 2-element row vector [xMin xMax]. For an m-by-n image (or an m-by-n-by-p image), XIntrinsicLimits equals [0.5, n+0.5].
x0=R.XIntrinsicLimits(1);% 0.5
% Limits of image in intrinsic units in the y-dimension, specified as a 2-element row vector [yMin yMax]. For an m-by-n image (or an m-by-n-by-p image), YIntrinsicLimits equals [0.5, m+0.5].
y0=R.YIntrinsicLimits(1);% 0.5
% Limits of image in world x-dimension, specified as a 2-element row numeric vector [xMin xMax].
map_xmin=R.XWorldLimits(1);
% Limits of image in world y-dimension, specified as a 2-element numeric row vector [yMin yMax].
map_ymax=R.YWorldLimits(2);
% 
dx=R.CellExtentInWorldX;
dy=R.CellExtentInWorldY;
% geo to image coordinate
x=roundn(((mapx-map_xmin)/dx+x0),-1);
y=roundn(((map_ymax-mapy)/dy+y0),-1);
indx=find(x~=fix(x));
x(indx)=round(abs(x(indx)-0.5))+0.5;
indy=find(y~=fix(y));
y(indy)=round(abs(y(indy)-0.5))+0.5;   
xy=[x,y];
end

