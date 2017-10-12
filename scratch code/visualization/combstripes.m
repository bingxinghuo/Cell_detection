function combimg=combstripes(rgbimg,f0,channels)
%% 1. Design the comb filter
fs=1;
% f0=.0009766;
q=16;
bw=(f0/(fs/2))/q;
[b,a]=iircomb(round(fs/f0),bw,'notch');
%% 2. apply filter to desired channels
combimg=rgbimg;
for i=1:length(channels)
    c=channels(i);
    I=rgbimg(:,:,c);
    I=double(I);
    % adjust zero
    dc=mean((I(:,1:500)+I(:,(end-499):end))/2,2);
    I_zero=I-dc*ones(1,size(I,2));
    % pad zero
    I_pad=[zeros(size(I,1),5000),I_zero,zeros(size(I,1),5000)];
    % apply comb filter
    Icomb=filtfilt(b,a,I_pad');
    % remove zero-padded area
    Icomb=Icomb(5001:end-5000,:);
    % readjust baseline
    combimg(:,:,c)=uint8(Icomb'+dc*ones(1,size(I,2)));
end