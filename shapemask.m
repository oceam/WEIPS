function [ shape_mask ] = shapemask( M,R,shapefile )
%   
shape_xys = xy_map2image(R,shapefile.X,shapefile.Y);% 提取shape矢量点图像坐标
m=size(M,1);
n=size(M,2);
shape_mask =zeros(m,n,'logical');
for i=1:size(shape_xys,2)
shape_xys(end,:)=[];
shape_mask1=poly2mask(shape_xys(:,1), shape_xys(:,2), m, n);
shape_mask = logical(imadd(shape_mask,shape_mask1));
end
end

