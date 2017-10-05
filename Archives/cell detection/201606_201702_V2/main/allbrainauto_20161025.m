%% m823 (16-bit)
ismask=0;
cd ~/marmosetRIKEN/NZ/m823/m823F/JP2-16
FB_detection_v8_parallel
cellsavecsv
%% m820 (8-bit)
ismask=1;
cd ~/marmosetRIKEN/NZ/m820/m820F/JP2
FB_detection_v8_parallel
cellsavecsv
%% m851 (8-bit)
cd ~/marmosetRIKEN/NZ/m851/m851F/JP2
FB_detection_v8_parallel
cellsavecsv
%% m819 (8-bit)
cd ~/marmosetRIKEN/NZ/m819/m819F/JP2
cellmask
FB_detection_v8_parallel
cellsavecsv
%% m822 (8-bit)
cd ~/marmosetRIKEN/NZ/m822/m822F/JP2/
cellmask
FB_detection_v8_parallel
cellsavecsv
%% m855 (8-bit)
cd ~/marmosetRIKEN/NZ/m855/m855F/JP2/
cellmask
FB_detection_v8_parallel
cellsavecsv
%% m919 (16-bit)
cd ~/marmosetRIKEN/NZ/m919/m919F/JP2/
FB_detection_v8_parallel
cellsavecsv