sampleimgs={'M820-F50--_3_0150.jp2';'M820-F112--_3_0336.jp2'};
% for i=1:2
fileid=sampleimgs{i};
fluoroimg=imread(fileid,'jp2');
%% scratch code for image adjustment
contrastimg=fluoroimg;
for c=1:3
    [n(:,c),x]=imhist(contrastimg(:,:,c));
end
figure, semilogy(x,n)
%% 1. histogram match the red and green channels
Rcontrast=imhistmatch(fluoroimg(:,:,1),fluoroimg(:,:,2));
contrastimg(:,:,1)=Rcontrast;
%% 2. remove the vertical stripes in the image
c=3;
imgtest=fluoroimg(10000:15000,:,c);
imgtest=double(imgtest);
% 2.1. Since all stripes are vertical, calculate the power spectrum along horizontal direction
% Use only a portion of the image for analysis
fs=1;
imgfft=fft(imgtest');
N=size(imgfft,1);
freq = 0:fs/N:fs/2;
imgfft=imgfft(1:N/2+1,:);
imgS=abs(imgfft).^2; % power of each line
imgSm=mean(imgS,2);
figure, loglog(freq,imgSm)
%% 2.2. Observed harmonics of a fundamental frequency. Use a comb filter to
% cancel it. This method can be improved in future.
f0=.0009766;
combimg=combstripes(contrastimg,f0,[1:3]);
%% 2.3. Check the PSD now
combtest=combimg(10000:15000,:,c);
combfft=fft(combtest');
combfft=combfft(1:N/2+1,:);
combS=abs(combfft).^2;
combSm=mean(combS,2);
hold on, loglog(freq,combSm)
%% 2.4. save the filtered image
save('sampleadj','combtestimg')
%% 3. enhance blue channel using a sigmoid function
% Bcontrast=fluoroimg(:,:,3);
Bcontrast=combimg(:,:,3);
Bcontrast=single(Bcontrast);
% Bcontrast=Btest+Btest.*(1./(1+exp(-Btest)));
Bcontrast=Bcontrast+Bcontrast.*(1./(1+exp(-(Bcontrast-30)/1)));
% contrastimg(:,:,3)=uint8(Bcontrast);
combimg(:,:,3)=uint8(Bcontrast);
%% 4. save the adjusted image
% save('sampleadj','contrastimg','-append')
save('sampleadj','combimg','-append')
%% One more thing to try: log the image first