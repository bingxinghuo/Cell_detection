function fullimg=imgstitch(fullimg,partimg,xedge,yedge)
[H,W]=size(fullimg);
fullimg(yedge(1)+1:min(yedge(2),H),xedge(1)+1:min(xedge(2),W))=partimg;
