M=64;
%% 1. generate a set of windows
k=9;
% DPSS filter bank
dps_seq=dpss(M,k);
% convert to 2D
for s=1:2*k
    F{s}=dps_seq(:,s)*dps_seq(:,s)';
end
%% 2. apply filters
% for t=1:Ntiles
t=1000;
tilestack{t}=cell(3,1);
for c=1:3
    for s=1:2*k
        tilestack{t}{c}{1}{s}=conv2(tilefilt{t}(:,:,c),F{s},'same');
    end
end
for c=1:3
    for i=1:log2(M)
        tilein=tilestack{t}{c}{(i-1)*2+1};
        % create a stack of filtered images
        for s=1:2*k
            S0=conv2(tilein{s},F{s},'same');
            tilestack{t}{c}{i*2}{s}=S0;
            % pooling within each filtered image
            w=2; d=2;
            [rows,cols]=size(S0);
            S1=zeros(rows/d,cols/d);
            for rs=1:rows/d % steps
                for cs=1:cols/d % steps
                    imgblk=S0((rs-1)*w+1:rs*w,(cs-1)*w+1:cs*w);
                    S1(rs,cs)=max(max(imgblk));
                end
            end
            % ReLU
            tilestack{t}{c}{i*2+1}{s}=S1.*(S1>0);
        end
    end
end
% end