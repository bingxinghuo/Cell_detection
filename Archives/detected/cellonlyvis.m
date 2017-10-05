stack3d.x=[];
 stack3d.y=[];
 stack3d.z=[];
%  FBclear=FBdetected;
 for i=1:292
     stack3d.x=[stack3d.x;FBclear{i}.x];
     stack3d.y=[stack3d.y;FBclear{i}.y];
     stack3d.z=[stack3d.z;ones(length(FBclear{i}.x),1)*i];
 end
figure, scatter3(stack3d.x,stack3d.y,stack3d.z,'.')