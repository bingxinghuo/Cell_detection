% filedir='/Users/bhuo/CSHLservers/gpu2_Mdrives/M29/PeterStrickData/';
filedir='/Users/bingxinghuo/CSHLservers/mitragpu2/PeterStrickData/';
cd([filedir,'Normalized'])
system('ls *.jp2 > filenames.txt')
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
sizepar=[2,1000]; % radius in microns
sigma=[200 1]; % s.d. in microns
N=10000;
Prec=[];
Rec=[];
for f=1:length(filelist)
    sampleid=filelist{f}(1:end-4);
    outputfile=[filedir,'/unsupervised/',sampleid,'.mat'];
    if ~exist(outputfile,'file') % skip the ones that are already processed
        if ismember('DL26',sampleid)
            resolution=.25;
        elseif ismember('242',sampleid)
            resolution=.25;
        else
            resolution=.5;
        end
        rabiescell(filedir,sampleid,sigma,sizepar,resolution,N);
    else
        load(outputfile,'cellannotile')
        if isempty(cellannotile)
            prec=0;
            rec=NaN;
        else
            load(outputfile,'cellmask','hitscoretile')
            [R,C]=size(cellmask);
            TPFP=zeros(R,C);
            TPFN=zeros(R,C);
            TPlabels=cell(R,C);
            hitscoretile=zeros(R,C);
            for r=1:R
                for c=1:C
                    if sum(sum(cellmask{r,c}))>0
                        cc=bwconncomp(cellmask{r,c});
                        L=labelmatrix(cc);
                        TPFP(r,c)=max(nonzeros(L));
                        L1=size(cellannotile{r,c},1);
                        TPFN(r,c)=L1;
                        % recalculate hitscoretile based on a square neighborhood
                        hitscore=zeros(L1,1);
                        n=25;
                        for l=1:L1
                            hitscore(l)=sum(sum(cellmask{r,c}(max(1,(cellannotile{r,c}(l,1)-25)):...
                                min(size(cellmask{r,c},1),cellannotile{r,c}(l,1)+25),...
                                max(1,cellannotile{r,c}(l,2)-25):min(size(cellmask{r,c},2),...
                                cellannotile{r,c}(l,2)+25))))>0;
                        end
                        hitscoretile(r,c)=sum(hitscore);
                    end
                end
            end
            TP=sum(sum(hitscoretile));
            TPFPs=sum(sum(TPFP));
            TPFNs=sum(sum(TPFN));
            prec=TP/TPFPs;
            rec=TP/TPFNs;
        end
        save(outputfile,'hitscoretile','prec','rec','-append')
    end
    disp(sampleid)
    Prec=[Prec;prec];
    Rec=[Rec;rec];
end