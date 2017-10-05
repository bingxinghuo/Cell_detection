%% FBdetection_win2.m
% Bingxing Huo
% This function contains strategy for detecting all cells within a specific
% window
function FBdetected=FBdetection_win2(varargin)
%% 0. preparation
% 0.1 input
imgtemp_rgb=varargin{1}; % image
pars=varargin{2}; % parameters
if nargin>2
    bitinfo=varargin{3}; % info on bits
else
    bitinfo=12; % 12-bit is the default
end
%% 0.2 parameters
thresh.count=10;
%% 1. color filter
imgtemp_rgb1=cellcolor(imgtemp_rgb); 
%% 2. Remove background
imgtemp_nobak=rmbg(imgtemp_rgb1);
%% 3. Detect cell bodies, 
% 3.1 consider if there is saturation in the image
imgtemp=cell(2,1);
if (sum(sum(imgtemp_rgb1(:,:,3)>=2^bitinfo))<thresh.count) % Case 1: less than M saturated pixels in the image
    imgtemp{1}=imgtemp_nobak(:,:,3); % get the monochrome image
else    % Case 2. If there are saturation in the image
    warning('There is saturation in the image!')
    [~,satumask]=satmask(imgtemp_rgb);
%     [imgtemp{1},satumask]=satmask(imgtemp_rgb); % generate the monochrome image for saturated area
    imgtemp{2}=imgtemp_nobak(:,:,3).*(1-satumask); % non-saturated area
    %                 imgtemp_rgb_unsat=double(imgtemp_rgb).*cat(3,1-satumask,1-satumask,1-satumask);
end
% 3.2 detect cells
for i=1:2
    if ~isempty(imgtemp{i})
        %                     centroids=celldetect_vis(imgtemp_sat,imgtemp_rgb);
        centroids=celldetect_s2(imgtemp{i},bitinfo);
        FBdetected=cellassemble_v2(centroids,FBdetected,pars);
    end
end