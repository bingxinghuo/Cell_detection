%% hsvadjcolor.m
% March 2018
% This function selects only blue colors from hue channel, and normalizes
% value and saturation
function Stile1=hsvadjcolor(Stile,colorspec)
% note: rgb2hsv is only accurate on double precision
% Shsv=rgb2hsv(double(Stile)/2^12);
Shsv=rgb2hsv(double(Stile));
%% Hue
if colorspec=='b'
    cmask=(Shsv(:,:,1)>(180/360)).*(Shsv(:,:,1)<=(300/360));
elseif colorspec=='g'
    cmask=(Shsv(:,:,1)>(60/360)).*(Shsv(:,:,1)<=(180/360)); % green
elseif colorspec=='r'
    cmask=(Shsv(:,:,1)>(300/360)).*(Shsv(:,:,1)<=(60/360)); % red
elseif colorspec=='m'
    cmask=(Shsv(:,:,1)>(270/360)).*(Shsv(:,:,1)<=(330/360)); % red
    
end
% keeping only blue
Shsv(:,:,1)=cmask.*Shsv(:,:,1); %
%% Saturation
% Saturate everything
Shsv(:,:,2)=cmask;
%% Value
% normalize value channel
V=Shsv(:,:,3).*cmask;
% V=V./max(max(V)); % normalize to range [0 1]
% % sigmoid
% Imax=1;
% Imin=0;
% gain=20;
% Imid=.5;
% V=(Imax-Imin)./(1+exp(gain*(Imid-V)))+Imin;
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
