% using RGB and LAB and HSV color information
% In this part create the tree-based model give the name as "treemodel"

%%
% tic;
clear;
clc;
time=datestr(now,1);
savename=[time,'-WEIPS_DTSM'];

startpath = pwd;
[nameoftrain,trainpath]=uigetfile({'*.txt','All Files'},...
        'Slect Model', startpath,...
        'MultiSelect', 'on');
L=length(nameoftrain);
names=nameoftrain'; 

disp('started')
    
newT=[];
classVariable=[];
for m= 1:L
    trainname=char(names(m));
    if strcmp(trainname(end-3:end),'.txt')==1
        nameofclass1=trainname(2:end-4);
        %20151218
        T=readtable([trainpath,trainname]);
%         if strcmp(nameofclass1,'leaf_cross')==1|| strcmp(nameofclass1,'leaf_side')==1
%             nameofclass='heads';
%         else
%             nameofclass=nameofclass1;
%         end
        nameOfclass=repmat({trainname(2:end-4)},height(T),1);
        classVariable=[classVariable;nameOfclass];
        newT=[newT;T];
    end
end
newT.classname=classVariable;
savemodelname=[trainpath,time,'_DTSMuseData.txt'];
writetable(newT,savemodelname);
    
% nameoftrain='DTSMuseData.txt'; % testuse
newT=readtable(savemodelname);
% col 1 is the image name 
% col 2 and 3 is the coordinate of collected point
classname = newT.Properties.VariableNames(4:12);
classVariable = newT{:,'classname'};
trainfeature=newT{:,classname};

t1 = fitctree(trainfeature,classVariable,'PredictorNames',classname);
% view(t1);

%%
cvmodel=crossval(t1);      
resuberror=resubLoss(t1);
%cvloss = kfoldLoss(cvmodel);
[~,~,~,bestlevel] = cvLoss(t1,...
    'SubTrees','All','TreeSize','min');
% find the most appropriate size of tree
% Here also need to change when use different color information
DTSMmodel = prune(t1,'level',bestlevel);
% view(treemodel); %
save([savename,'.mat'], 'DTSMmodel'); %for future use

disp(['finished: ', savename])





