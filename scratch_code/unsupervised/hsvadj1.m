%% hsvadj1.m
% March 2018
% This function selects only blue colors from hue channel, and normalizes
% value and saturation
% input should be uint16
function Stile1=hsvadj1(Stile)
% note: rgb2hsv is only accurate on double precision
% Shsv=rgb2hsv(double(Stile)/2^12);
Shsv=rgb2hsv(double(Stile));
%% Hue
% setting everything non-blue to pure red
Shsv(:,:,1)=(Shsv(:,:,1)>=.5).*(Shsv(:,:,1)<=.75).*Shsv(:,:,1); %
%% Saturation
% Saturate everything
Shsv(:,:,2)=1;
%% Value
% normalize value channel
V=Shsv(:,:,3);
% V=V./max(max(V)); % normalize to range [0 1]
% sigmoid
Imax=2^12-1;
Imin=0;
gain=20;
Imid=100;
V=(Imax-Imin)./(1+exp(gain*(Imid-V)))+Imin;
%% Convert back to rgb, preserving [0 1] range
% %% Convert everything back
Shsv(:,:,3)=V;
% convert back
Stile1=hsv2rgb(Shsv);
% remove pure red [x,0,0]
[rows,cols,~]=size(Stile1);
for r=1:rows
    for c=1:cols
        if sum(Stile1(r,c,2:3))==0
            Stile1(r,c,1)=0;
        end
    end
end
