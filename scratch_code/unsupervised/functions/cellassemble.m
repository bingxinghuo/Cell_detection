% assemble detected cells into a variable
function FBdetected=cellassemble(centroids,FBdetected,pars)
win=pars.win;
if ~isempty(centroids)
    ptx=centroids(:,1)+(pars.h-1)*win.width;
    pty=centroids(:,2)+(pars.v-1)*win.height;
    % visualize
    %                             scatter(ax1,centroids(:,1),centroids(:,2),'m*')
    %                             scatter(ax2,centroids(:,1),centroids(:,2),'m*')
    % save data
    FBdetected.x=[FBdetected.x;ptx];
    FBdetected.y=[FBdetected.y;pty];
end