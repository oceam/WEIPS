function clicked=clickRecord(img,area)
% 2015.11.26
% finish with right click
% the last right click would also be collected, be careful!
% by Oceam, The University of Tokyo
Area=area;
I=img;
% figure;
imshow(I);
hold on
x=[];
y=[];
n=0;
button=1;
while button~=3
    % this part need to use right click
[xi,yi,button]=ginput(1);
rectangle('Position',[xi-Area/2,yi-Area/2,Area,Area],'FaceColor','r');
plot(xi,yi,'bo')
n=n+1;
x(n,1)=xi;
y(n,1)=yi;
end
clicked=[x,y];

hold off