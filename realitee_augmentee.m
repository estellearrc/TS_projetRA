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
close all
clear all

%Récupération de la frame 1
video = VideoReader('vid_in2.mp4');
frame = double(read(video,50));
%figure,imshow(uint8(frame))

%homographie
%coinsQuad = ginput(4)
%coinsQuad = fix(coinsQuad);
coinsQuad = [685 413;1339 236;1432 578;629 764]; %pour la frame 1 et 50

%premier masque

maskFrame = zeros(1080,1920,3);%masque du frame de la vidéo
maskImg = zeros(100,100,3);%petite image avec que des 1 de taille 100x100
maskImg(25:66,76:100,:) = ones(42,25,3);
coinsMain = [76 100 100 76;25 25 66 66;1 1 1 1];
dim = size(maskImg);
coinsImg = [0 0;dim(2)-1 0;dim(2)-1 dim(1)-1;0 dim(1)-1];
H = determineH(coinsQuad,coinsImg);
maskFrame = projection(maskFrame,maskImg,H,coinsQuad);%Homographie avec grand carré blanc de la main
maskFrame = double(maskFrame(:,:,:)>=0.99);
maskFrame = maskFrame .* frame;

%préparation pour le deuxième masque
coordFrameCoinsMain = appliqueHomographie(inv(H),coinsMain);
coordFrameCoinsMain = uint32(passeEnCoordEucli(coordFrameCoinsMain));
%figure,imshow(double(maskFrame))
%figure,imshow(uint8(maskFrame))

%deuxième masque
xmin = min(coordFrameCoinsMain(1,:));
xmax = max(coordFrameCoinsMain(1,:));
ymin = min(coordFrameCoinsMain(2,:));
ymax = max(coordFrameCoinsMain(2,:));
maskMain = maskFrame(ymin:ymax,xmin:xmax,:);
R = maskMain(:,:,1);
G = maskMain(:,:,2);
B = maskMain(:,:,3);
Y = 0.299*R+0.587*G+0.114*B;
CR = 0.713*(R-Y);
maskMain = double(((CR > 0) | (maskMain(:,:,3)<95) | (maskMain(:,:,2)<115)) .* (maskMain(:,:,3)>0) .* (maskMain(:,:,2)>0) ); 
%maskMain = double(((maskMain(:,:,3)<95) | (maskMain(:,:,2)<115)) .* (maskMain(:,:,3)>0) .* (maskMain(:,:,2)>0)); 
%>0 pour retirer les pixels noirs du frameFiltre
%figure,imshow(double(maskMain))

%masque total
maskFrame(ymin:ymax,xmin:xmax,1) = maskMain;
maskFrame(ymin:ymax,xmin:xmax,2) = maskMain;
maskFrame(ymin:ymax,xmin:xmax,3) = maskMain;
%figure,imshow(double(maskFrame))

%projection de l'image à insérer
bouboule= double(imread('bouboule.jpg'));
dimBouboule = size(bouboule);
coinsBouboule = [0 0;dimBouboule(2)-1 0;dimBouboule(2)-1 dimBouboule(1)-1;0 dimBouboule(1)-1];
H = determineH(coinsQuad,coinsBouboule);
frameApresProjection = projection(frame,bouboule,H,coinsQuad);
%figure,imshow(uint8(frameApresProjection))
frameFinal = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
%figure,imshow(uint8(frameFinal))

%tracer un segment
%figure,imshow(uint8(frame))
%coins2d = ginput(6)
%coins2d = fix(coins2d);
%cage
coins2d = [686 410;1337 235;1430 581;629 766;919 473;725 695];
coins3d = [0 0 0;1 0 0;1 1 0;0 1 0;0.38 0.875 0.2;0.125 0.875 0];
%cadre
%coins2d = [686 410;1337 235;1430 581;629 766;730 524; 922 472];
%coins3d = [0 0 0;1 0 0;1 1 0;0 1 0;0.11 0.4 0.2;0.38 0.4 0.2];
P = determineP(coins3d,coins2d);
modele = scene3d(50,5,P);
X = modele(1,:);
Y = modele(2,:);
pos = Y +(X-1)*1080;
rouge = 255*ones(size(pos));
vert = zeros(size(pos));
bleu = zeros(size(pos));
frameFinal([pos pos+1080*1920 pos+2*1080*1920]) = [rouge vert bleu];
figure,imshow(uint8(frameFinal))



