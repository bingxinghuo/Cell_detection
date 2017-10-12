sampleimgs={'M820-F50--_3_0150.jp2';'M820-F112--_3_0336.jp2'};
% for i=1:2
    fileid=sampleimgs{i};
    fluoroimg=imread(fileid,'jp2');
%% scratch code for contrast adjustment
%% histogram match the red and green channels
Rtest=fluoroimg(:,:,1);
Rtest=single(Rtest);
Rcontrast=imhistmatch(fluoroimg(:,:,1),fluoroimg(:,:,2));
contrastimg(:,:,1)=Rcontrast;
%% remove the vertical stripes in the image
Btest=fluoroimg(:,:,3);
Btest=double(Btest);
% 1. Since all stripes are vertical, calculate the power spectrum along horizontal direction
% Use only a portion of the image for analysis
imgtest=Btest(10000:15000,:)';
fs=1;
imgfft=fft(imgtest);
N=size(imgfft,1);
freq = 0:fs/N:fs/2;
imgfft=imgfft(1:N/2+1,:);
imgS=abs(imgfft).^2; % power of each line
imgSm=mean(imgS,2);
figure, loglog(freq,imgSm)
%% 2. Observed harmonics of a fundamental frequency. Use a comb filter to
% cancel it. This method can be improved in future. 
f0=.0009766;
q=16;
bw=(f0/(fs/2))/q;
[b,a]=iircomb(round(fs/f0),bw,'notch');
% adjust zero
dc=mean((Btest(:,1:500)+Btest(:,(end-499):end))/2,2);
Btest_zero=Btest-dc*ones(1,size(Btest,2));
% pad zero
Btest_pad=[zeros(size(Btest,1),5000),Btest_zero,zeros(size(Btest,1),5000)];
combtest=filtfilt(b,a,Btest_pad');
combtest=combtest(5001:end-5000,:);
combtest=uint8(combtest');
% 3. Check the PSD now
combfft=fft(combtest1');
combfft=combfft(1:N/2+1,:);
combS=abs(combfft).^2;
combSm=mean(combS,2);
figure, loglog(freq,combSm)
% 4. assemble the filtered image
combtestimg=uint8(combtest'+dc*ones(1,size(Btest,2)));
save('sampleadj','combtestimg','-append')
%% enhance blue channel using a naiive sigmoid function
% Bcontrast=Btest+Btest.*(1./(1+exp(-Btest)));
Bcontrast=Btest/2+Btest.*(1./(1+exp(-(Btest-100)/1)));
contrastimg(:,:,3)=uint8(Bcontrast);
%% One more thing to try: log the image first