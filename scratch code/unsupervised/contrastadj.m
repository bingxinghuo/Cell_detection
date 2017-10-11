%% scratch code for contrast adjustment
%% enhance blue channel using a naiive sigmoid function
Btest=fluoroimg(:,:,3);
Btest=single(Btest);
Bcontrast=Btest+Btest.*(1./(1+exp(-Btest)));
contrastimg=fluoroimg;
contrastimg(:,:,3)=uint8(Bcontrast);
%% histogram match the red and green channels
Rtest=fluoroimg(:,:,1);
Rtest=single(Rtest);
Rcontrast=imhistmatch(fluoroimg(:,:,1),fluoroimg(:,:,2));
contrastimg(:,:,1)=Rcontrast;
%% remove the vertical stripes in the image
% 1. Since all stripes are vertical, calculate the power spectrum along horizontal direction
% Use only a portion of the image for analysis
imgtest=Bcontrast(10000:15000,:)';
fs=1;
imgfft=fft(imgtest);
N=size(imgfft,1);
freq = 0:fs/N:fs/2;
imgfft=imgfft(1:N/2+1,:);
imgS=abs(imgfft).^2; % power of each line
imgSm=mean(imgS,2);
figure, loglog(freq,imgSm)
% 2. Observed harmonics of a fundamental frequency. Use a comb filter to
% cancel it. This method can be improved in future. 
f0=.0009766;
q=1;
bw=(f0/(fs/2))/q;
[b,a]=iircomb(round(fs/f0),bw,'notch');
Bcontrast=double(Bcontrast);
% detrend
[yupper,ylower]=envelope(Bcontrast',50,'peak');
ytrend=(yupper+ylower)/2;
Bcontrast_detrend=Bcontrast-ytrend;
combtest=filter(b,a,Bcontrast_detrend');
% 3. Check the PSD now
combfft=fft(combtest1');
combfft=combfft(1:N/2+1,:);
combS=abs(combfft).^2;
combSm=mean(combS,2);
figure, loglog(freq,combSm)
% 4. assemble the filtered image
combtestimg=uint8(combtest'+Bcontrast_mean*ones(1,size(Bcontrast,2)));
save('sampleadj','combtestimg','-append')
%% One more thing to try: log the image first