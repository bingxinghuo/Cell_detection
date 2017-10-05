global sigma sizepar eccpar
%% 0. parameters
sizepar=[40,5000];
eccpar=[.99,.95];
sigma=[20,1];
%%
% envector=cell(4,1);
% for n=3:6
n=5;
bg=imgaussfilt(single(testimg),sigma(1));
img_nobak=single(testimg)-bg;
img_nobak=img_nobak.*(img_nobak>0);
ensemv=contextimg(testimg,n);
%     envector{n-2}=ensemv;
envector11=ensemv;
% end
save('testgroup1','envector11','-append')