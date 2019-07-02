% find the cutoff threshold for removing background
function thresh=imgcutoff(imgbit)
global bitinfo
bitinfo=14;
v=version('-release'); % check matlab version
v=str2double(v(1:4));
%% determine the threshold
xbins=[0:.05:bitinfo]; % 12-bit image
[N,X]=hist(log2(nonzeros(imgbit(~isinf(imgbit)))),xbins); % histogram of log2 of log2 image (approx. second derivative)
%
nz=find(N); % nonzero elements of N
if length(nz)>2
    if v<2016
        pks=findpeaks(N(nz)); % find local maxima
        locs=pks.loc;
    else
        [~,locs]=findpeaks(N(nz));
    end
    if length(locs)<=1 % if there is only one maximum, there is only background
        peakind=length(X);
    else % if there are more than one maxima
        N1=N;
        N1(nz(locs))=0; % remove local peaks to look at trend
        nz1=find(N1); % nonzero elements of the "trend"
        if ~isempty(nz1) % if there are points other than the peaks
            N1d=diff(N1(nz1)); % take the first derivative of "trend"
            if sum(N1d>0)>0 % if there exist upward trend
                segpt=X(nz1(find(N1d>0))); % get the points where the curve is increasing
                if length(segpt)>1 % if there is more than one upward trend turning point
                    if segpt(1)==0 % if it is 1,
                        segpt=segpt(2); % take the next
                    else
                        segpt=segpt(1); % take only the first upward point that's not 1
                    end
                    % segpt=segpt(end);
                end
                segptdist=X(nz(locs))-segpt; % calculate the distance to the turning point
                [~,minind]=min(abs(segptdist)); % find the closest peak point
                minind=minind(1); % if there is more than 1 peak points, take the first one
                peakind=nz(locs(minind)); % take the peak as the threshold point
            else % if there is no upward trend
                maxind=find(N==max(N)); % check the global maximum
                if sum(maxind==1)==1 % if 1 is one of the global maximum location
                    maxvalue=max(N(nz(locs(2:end)))); % look for the global maximum in the rest of range
                    maxind=find(N==maxvalue);
                end
                peakind=maxind(end); % if there is more than 1 peak points, take the last one
                
            end
        else % if there are no other points than the peaks
            peakind=nz(locs(end)); % take the last peak as the threshold
        end
        % peakind=nz(locs(end));
    end
else % if there is no peak
    peakind=length(X); % no signal
end
Xpeak=X(peakind);  % the maximum value index correspond to the log2 of the bit-image
thresh=2^Xpeak;