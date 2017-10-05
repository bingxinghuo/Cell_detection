for i=40:length(neurons{1})
    h=imagesc(neurons{1}{i}.labels);
    saveas(h,['cells_red_',num2str(i)],'tif')
    h=imagesc(processes{1}{i}.labels);
    saveas(h,['axons_red_',num2str(i)],'tif')
end
%%
clear all
load labeldata_2
for i=1:40
    h=imagesc(neurons{2}{i}.labels);
    saveas(h,['cells_green_',num2str(i)],'tif')
    h=imagesc(processes{2}{i}.labels);
    saveas(h,['axons_green_',num2str(i)],'tif')
end
%%
clear all
load labeldata_2_2
for i=41:length(neurons{2})
    h=imagesc(neurons{2}{i}.labels);
    saveas(h,['cells_green_',num2str(i)],'tif')
    h=imagesc(processes{2}{i}.labels);
    saveas(h,['axons_green_',num2str(i)],'tif')
end
%%
% clear all
% load labeldata_3_1
% for i=1:50
%     h=imagesc(neurons{3}{i}.labels);
%     saveas(h,['cells_blue_',num2str(i)],'tif')
%     h=imagesc(processes{3}{i}.labels);
%     saveas(h,['axons_blue_',num2str(i)],'tif')
% end
% %%
% clear all
% load labeldata_3_2
% for i=51:length(neurons{3})
%     h=imagesc(neurons{3}{i}.labels);
%     saveas(h,['cells_blue_',num2str(i)],'tif')
%     h=imagesc(processes{3}{i}.labels);
%     saveas(h,['axons_blue_',num2str(i)],'tif')
% end