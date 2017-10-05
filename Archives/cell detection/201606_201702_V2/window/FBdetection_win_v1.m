function FBdetected=layer3fun(varargin)
imgtemp_rgb=varargin{1};
pars=varargin{2};
if nargin>2
    bitinfo=varargin{3};
else
    bitinfo=12; % 12-bit is the default
end
f=pars.f;
%% Feature 1: color
imgtemp_rgb1=cellcolor(imgtemp_rgb);
%% Remove background
imgtemp_nobak=rmbg(imgtemp_rgb1);
%% Detect cell bodies
imgtemp=cell(2,1);
if (sum(sum(imgtemp_rgb1(:,:,3)>=2^bitinfo))<100) % Case 1: less than 100 saturated pixels in the image
    imgtemp{1}=imgtemp_nobak(:,:,3); % get the monochrome image
else    % Case 2. If there are saturation in the image
    warning('There is abundant saturation in the image!')
    [imgtemp{1},satumask]=satmask(imgtemp_rgb); % generate the monochrome image for saturated area
    imgtemp{2}=imgtemp_nobak(:,:,3).*(1-satumask); % non-saturated area
    %                 imgtemp_rgb_unsat=double(imgtemp_rgb).*cat(3,1-satumask,1-satumask,1-satumask);
end
for i=1:2
    if ~isempty(imgtemp{i})
        %                     centroids=celldetect_vis(imgtemp_sat,imgtemp_rgb);
        centroids=celldetect_s1(imgtemp{i},bitinfo);
        FBdetected{f}=cellassemble(centroids,FBdetected{f},pars);
    end
end