function rgbimg1=baselineadj(rgbimg,bgimgmed,bgimgmed0)
% Make background adjustment on raw image
adjmat=ones(size(rgbimg));
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
rgbimg1=double(rgbimg);
rgbimg1=rgbimg1-adjmat;