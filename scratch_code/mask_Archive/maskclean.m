function FBclear=maskclean(FBdetected,imgmask)
FBclear.x=[];
FBclear.y=[];
for j=1:length(FBdetected.x)
    if imgmask(round(FBdetected.y(j)),round(FBdetected.x(j)))==1
        FBclear.x=[FBclear.x;FBdetected.x(j)];
        FBclear.y=[FBclear.y;FBdetected.y(j)];
    end
end