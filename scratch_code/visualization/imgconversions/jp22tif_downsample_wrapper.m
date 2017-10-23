brainids={'m920';'m919'};
for d=1:2
    brainid=brainids{d};
    %     cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/binaryimg'])
    cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/8bitRGB/'])
    filelist=jp2lsread;
    Nf=length(filelist);
    parfor f=1:Nf
        filein=filelist{f};
        fileout=[filein(1:end-4),'.tif'];
        if ~exist([pwd,'/',fileout])
            % 1. read image
            maskimg=imread(filein,'jp2');
            % 2. take only one channel suffices
            maskimg=maskimg(:,:,3);
            % 3. check if the image contains signal
            %         pixcount=sum(sum(logical(maskimg)));
            M=64; % 64 times downsampling
            %         if pixcount>10
            % 4. downsample
            tic;
            maskdown=jp22tif_downsample(maskimg,M);
            toc
            %         end
            maskdown=cat(3,maskdown,maskdown,maskdown);
            imwrite(maskdown,fileout,'tif','compression','none','writemode','overwrite')
            %         % 3. downsample using Xu's routine (ref: email communication
            %         % 10/18/2017)
            %         for i=1:6
            %             maskfilt=medfilt2(maskimg,[5,5]);
            %             % pad zeros for odd number of rows/columns
            %             [rows,cols]=size(maskfilt);
            %             if mod(rows,2)==1
            %                 maskfilt=[maskfilt;uint8(zeros(1,cols))];
            %                 [rows,cols]=size(maskfilt);
            %             end
            %             if mod(cols,2)==1
            %                 maskfilt=[maskfilt,uint8(zeros(rows,1))];
            %                 [rows,cols]=size(maskfilt);
            %             end
            %             maskdown=uint8(zeros(rows/2,cols/2));
            %             for rs=1:rows/2
            %                 for cs=1:cols/2
            %                     imgblk=maskimg((rs-1)*2+1:rs*2,(cs-1)*2+1:cs*2);
            %                     maskdown(rs,cs)=max(reshape(imgblk,4,1));
            %                 end
            %             end
            %             maskimg=maskdown;
            %         end
        end
    end
end
