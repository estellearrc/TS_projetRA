% close all
% clear all
% 
% %Vidéo complète à compresser
% video = VideoReader('vid_in2.mp4');
% vidFrames = read(video);
% numFrames = get(video,'NumberOfFrames');
% mov = immovie(vidFrames,[]);
% %hf = figure;
% %set(hf, 'position', [150 150 480 270])
% %movie(hf, mov, 1, video.FrameRate);
% 
% Itot = ones(1,numFrames,1080,1920);
% for k = 1:numFrames
%     frame = mov(k);
%     %frame = double(read(video,1));
%     %figure,imshow(uint8(frame))
% 
%     %détection de contours
%     matFrame = double((frame.cdata(:,:,1)+frame.cdata(:,:,2)+frame.cdata(:,:,3))/3); %pour dériver, on doit prendre une matrice
%     sigma = 0.5; %on prend sigmax = sigmay pour avoir un filtre isotrope
%     [X,Y] = meshgrid(-5:5); %[-3*sigma,3*sigma]
%     dxMatFrame = -X.*exp(-(X.^2.+Y.^2)/2*sigma^2)./2*pi*sigma^4;
%     dyMatFrame = -Y.*exp(-(X.^2.+Y.^2)/2*sigma^2)./2*pi*sigma^4;
%     Ix = conv2(matFrame,dxMatFrame,'same'); %same permet de centrer le filtre sur le point considéré
%     Iy = conv2(matFrame,dyMatFrame,'same');
%     I = sqrt(Ix.^2+Iy.^2);
%     Itot(1,k,:,:) = I;
%     %figure, imshow(I,[0 50])
%     %colormap(flipud(gray(256)))
% end
% mov2 = immovie(Itot,colormap(flipud(gray(256))));
% hf = figure;
% set(hf, 'position', [150 150 480 270])
% movie(hf, mov2, 1, video.FrameRate);


%%
%1 frame
close all
clear all

%Récupération de la frame 1
video = VideoReader('vid_in2.mp4');
frame = double(read(video,1));
%figure,imshow(uint8(frame))

    %détection de contours
    matFrame = double((frame(:,:,1)+frame(:,:,2)+frame(:,:,3))/3); %pour dériver, on doit prendre une matrice
    sigma = 0.5; %on prend sigmax = sigmay pour avoir un filtre isotrope
    [X,Y] = meshgrid(-5:5); %[-3*sigma,3*sigma]
    dxMatFrame = -X.*exp(-(X.^2.+Y.^2)/2*sigma^2)./2*pi*sigma^4;
    dyMatFrame = -Y.*exp(-(X.^2.+Y.^2)/2*sigma^2)./2*pi*sigma^4;
    Ix = conv2(matFrame,dxMatFrame,'same'); %same permet de centrer le filtre sur le point considéré
    Iy = conv2(matFrame,dyMatFrame,'same');
    I = sqrt(Ix.^2+Iy.^2);
    %figure, imshow(I,[0 50])
    %colormap(flipud(gray(256)))


%%
close all
clear all

%Récupération de la frame 1
video = VideoReader('vid_in2.mp4');
frame = double(read(video,50));
figure,imshow(uint8(frame))

%homographie
%coinsQuad = ginput(4)
%coinsQuad = fix(coinsQuad);
coinsQuad = [685 413;1339 236;1432 578;629 764]; %pour la frame 1 et 50

%img= double(imread('bouboule.jpg'));;
mask = zeros(1080,1920,3);
img = zeros(100,100,3);
img(25:74,76:100,:) = 255*ones(50,25,3);
coinsMain = [76 100 100 76;25 25 74 74;1 1 1 1];
dim = size(img);
coinsImg = [0 0;dim(2)-1 0;dim(2)-1 dim(1)-1;0 dim(1)-1];
H = determineH(coinsQuad,coinsImg);
mask = projection(mask,img,H,coinsQuad);
frameFiltre = mask .* frame;
%frame = projection(frame,img,H,coinsQuad);
coordFrameCoinsMain = H \ coinsMain;
S = coordFrameCoinsMain(3,:);
coordFrameCoinsMain = uint32(coordFrameCoinsMain(1:2,:) ./ [S;S]);
figure,imshow(uint8(mask))
figure,imshow(uint8(frameFiltre))




xmin = min(coordFrameCoinsMain(1,:));
xmax = max(coordFrameCoinsMain(1,:));
ymin = min(coordFrameCoinsMain(2,:));
ymax = max(coordFrameCoinsMain(2,:));
pieceOfFrame = frameFiltre(ymin:ymax,xmin:xmax,:);
coinsMain = double(coordFrameCoinsMain');

%pieceOfFrame = projection(pieceOfFrame,img,inv(H),coinsMain);
pieceOfFrame = double((pieceOfFrame(:,:,3)<130) .* (pieceOfFrame(:,:,3)>60));
figure,imshow(double(pieceOfFrame))
dim = size(pieceOfFrame);
coinsImg = [0 0;dim(2)-1 0;dim(2)-1 dim(1)-1;0 dim(1)-1];
triplePieceOfFrame = zeros(dim(1),dim(2),3);
triplePieceOfFrame(ymin:ymax,xmin:xmax,1) = pieceOfFrame;
triplePieceOfFrame(ymin:ymax,xmin:xmax,2) = pieceOfFrame;
triplePieceOfFrame(ymin:ymax,xmin:xmax,3) = pieceOfFrame;
figure,imshow(double(triplePieceOfFrame))

H = determineH(coinsMain,coinsImg);
mask2 = projection(mask,triplePieceOfFrame,H,coinsMain);

figure,imshow(double(mask2))








% Rframe = frame(:,:,1);
% Gframe = frame(:,:,2);
% Bframe = frame(:,:,3);
% Y = 0.299*Rframe+0.587*Gframe+0.114*Bframe;
% Mask=(Y>150) .* (Y<180);

% Rquad = quadrangle(:,:,1);
% Gquad = quadrangle(:,:,2);
% Bquad = quadrangle(:,:,3);
% %faire l'homographie
% Rframe=Rquad.*(1-Mask)+Rframe.*Mask;
% Gframe=Gquad.*(1-Mask)+Gframe.*Mask;
% Bframe=Bquad.*(1-Mask)+Bframe.*Mask;
% img = uint8(cat(3,R2,G2,B2));
% figure, imshow(img)