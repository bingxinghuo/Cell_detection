load('traindata.mat','trainimg','groupvectors')
for n=3:6
    N=2*n+1; % length of one side of the neighborhood
    trainensemv=[];
    for s=1:5 % go through all the training images
        % i=1;
        % 1. pad the image with zeros
        [rows,cols,~]=size(trainimg{s});
        imgpad=[zeros(n,cols,3);trainimg{s};zeros(n,cols,3)]; % pad rows of zeros outside the image
        [rows1,cols1,~]=size(imgpad);
        imgpad=[zeros(rows1,n,3),imgpad,zeros(rows1,n,3)]; % pad columns of zeros outside the image
        % 2. associate a neighborhood of pixels with each pixel in the image
        trainensemimg=zeros(rows,cols,N^2*4);
        for i=n+1:n+rows
            for j=n+1:n+cols
                pixensemimg=imgpad(i-n:i+n,j-n:j+n,:);
                pixensemv=reshape(pixensemimg,N^2,3); % rearrange into a 2-dimensional matrix
                pixensemangles=acos(pixensemv./(sqrt(sum(pixensemv.^2,2))*ones(1,3))); % 3 angles
                pixensemrad=sqrt(sum(pixensemv.^2,2)); % radius
                pixensemv=[pixensemangles,pixensemrad]; % transformed into N^2-by-4 matrix                
                % every pixel has a feature vector with length 4N^2
                trainensemimg(i-n,j-n,:)=reshape(pixensemv,N^2*4,1); % attach the group vector at the end of the feature vector                
            end
        end
        % assemble all the pixels
        trainensemv=[trainensemv;[reshape(trainensemimg,rows*cols,N^2*4),groupvectors{s}]];
    end
    savefile=['trainensemdata_',num2str(N),'.csv'];
    % save(savefile,'trainensemv','-v7.3')
    csvwrite(savefile,trainensemv)
    % tic
    % svmmodel1=fitcsvm(trainensemv(:,1:4),trainensemv(:,5));
    % toc
end