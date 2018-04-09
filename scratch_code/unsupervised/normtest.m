%% Select 3 typical images
sind=[1,1000,800];
for s=1:3
    Stile{s}=tileimg{sind(s)};
end
%% lab space, imadjust
srgb2lab = makecform('srgb2lab');
lab2srgb = makecform('lab2srgb');

Stilelab{3}=applycform(double(Stile{3}/(2^12)),srgb2lab);
Stilelab{3}(:,:,1)=imadjust(Stilelab{3}(:,:,1)/100)*100;
Stile1{3}=applycform(Stilelab{3},lab2srgb);

% better than histogram equalization, saturates 1% at max and min
% boundaries
%% HSV space
for s=1:3
    Stilehsv{s}=rgb2hsv(double(Stile{s}));
end
%% hsv space, histeq
Stilehsv1=Stilehsv;
Stilehsv1{3}(:,:,3)=histeq(Stilehsv{3}(:,:,3));
Stile1{3}=hsv2rgb(Stilehsv1{3});
% Comment: histogram equalization is not adjusting at a desired threshold
%% hsv space, adapthisteq
Stilehsv1=Stilehsv;
Stilehsv1{3}(:,:,3)=adapthisteq(Stilehsv{3}(:,:,3));
Stile1{3}=hsv2rgb(Stilehsv1{3});
%% normalize V channel with N[0,1]
Stilehsv1=Stilehsv;
for s=1:3
    Stilehsv1{s}(:,:,1)=(Stilehsv{s}(:,:,1)>=.5).*(Stilehsv{s}(:,:,1)<=.75).*Stilehsv{s}(:,:,1);
    Stilehsv1{s}(:,:,3)=(Stilehsv{s}(:,:,3)-mean(nonzeros(Stilehsv{s}(:,:,3))))./std(nonzeros(Stilehsv{s}(:,:,3)));
    Stile1{s}=hsv2rgb(Stilehsv1{s});
end
%% sigmoid function to normalize V channel
Stilehsv1=Stilehsv;
for s=1:3
    Stilehsv1{s}(:,:,1)=(Stilehsv{s}(:,:,1)>=.5).*(Stilehsv{s}(:,:,1)<=.75).*Stilehsv{s}(:,:,1);
    Imax=max(nonzeros(Stilehsv{s}(:,:,3)))*.8;
    Imean=mean(nonzeros(Stilehsv{s}(:,:,3)));
    Isd=std(nonzeros(Stilehsv{s}(:,:,3)));
    Stilehsv1{s}(:,:,3)=Imax./(1+exp(-(Stilehsv{s}(:,:,3)-Imean)/Isd));
    Stile1{s}=hsv2rgb(Stilehsv1{s});
end
%%
Stilehsv1=Stilehsv;
for s=1:3
    % adjust color, set all non-blue pixels to pure red
    Stilehsv1{s}(:,:,1)=(Stilehsv{s}(:,:,1)>=.5).*(Stilehsv{s}(:,:,1)<=.75).*Stilehsv{s}(:,:,1);
    % adjust saturation. Saturate everything
    Stilehsv1{s}(:,:,2)=1;
    %% normalize value channel
    V=Stilehsv1{s}(:,:,3);
    % The cdf of N[0,1] shows inconsistent mid-point 
    V1=V./max(max(V));
    % sigmoid
    Imax=1;
    Imin=0;
%     sd=std(reshape(V,[M^2,1]));
gain=20;
    Imid=.5;
    V1=(Imax-Imin)./(1+exp(gain*(Imid-V1)))+Imin;    
    figure, subplot(1,2,1), H1=histogram(V1);
    H1c=cumsum(H1.Values);
    subplot(1,2,2), plot(H1.BinEdges(1:end-1),H1c)
    %%
    Stilehsv1{s}(:,:,3)=V1*255;
    % convert back
    Stile1{s}=hsv2rgb(Stilehsv1{s});
    % remove pure red [x,0,0]
    [rows,cols,~]=size(Stile1{s});
    for r=1:rows
        for c=1:cols
            if sum(Stile1{s}(r,c,2:3))==0
                Stile1{s}(r,c,1)=0;
            end
        end
    end
    figure, subplot(1,2,1), imagesc(uint8(Stile{s}))
    subplot(1,2,2), imagesc(uint8(Stile1{s}))
end