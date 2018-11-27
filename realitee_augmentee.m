% close all
% clear all
% 
% %Vid�o compl�te � compresser
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
%     %d�tection de contours
%     matFrame = double((frame.cdata(:,:,1)+frame.cdata(:,:,2)+frame.cdata(:,:,3))/3); %pour d�river, on doit prendre une matrice
%     sigma = 0.5; %on prend sigmax = sigmay pour avoir un filtre isotrope
%     [X,Y] = meshgrid(-5:5); %[-3*sigma,3*sigma]
%     dxMatFrame = -X.*exp(-(X.^2.+Y.^2)/2*sigma^2)./2*pi*sigma^4;
%     dyMatFrame = -Y.*exp(-(X.^2.+Y.^2)/2*sigma^2)./2*pi*sigma^4;
%     Ix = conv2(matFrame,dxMatFrame,'same'); %same permet de centrer le filtre sur le point consid�r�
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

%R�cup�ration de la frame 1
video = VideoReader('vid_in2.mp4');
%bipbip = VideoReader('bipbip.mp4');
%nbFramesBipbip = bipbip.NumberOfFrames;
for i = 1:10:300
    numFrame = 50;
    frame = double(read(video,numFrame));
    %figure,imshow(uint8(frame))

    %homographie
    %coinsQuad = ginput(4)
    %coinsQuad = fix(coinsQuad);
    coinsQuad = [685 413;1339 236;1432 578;629 764]; %pour la frame 1 et 50
    coinsFrame = [1 1;1920 1;1920 1080;1 1080];

    %premier masque

    maskFrame = zeros(1080,1920,3);%masque du frame de la vid�o
    maskFrame(1:540,960:1920,:) = ones(540,961,3);
    maskFrame = maskFrame .* frame;
    R = maskFrame(:,:,1);
    G = maskFrame(:,:,2);
    B = maskFrame(:,:,3);
    Y = 0.299*R+0.587*G+0.114*B;
    CR = 0.713*(R-Y);
    maskBras = (CR > 6) .* (R < 115);
    %figure,imshow(double(maskBras))
    maskFrame(:,:,1) = maskBras; 
    maskFrame(:,:,2) = maskBras;
    maskFrame(:,:,3) = maskBras;
    %figure,imshow(double(maskFrame))
    
    maskImg = zeros(100,100,3);%petite image avec que des 1 de taille 100x100
    maskImg(25:66,76:100,:) = ones(42,25,3);
    coinsMain = [76 100 100 76;25 25 66 66;1 1 1 1];
    dim = size(maskImg);
    coinsImg = [0 0;dim(2)-1 0;dim(2)-1 dim(1)-1;0 dim(1)-1];
    H = determineH(coinsQuad,coinsImg);
    maskFrame = projection(maskFrame,maskImg,H,coinsQuad);%Homographie avec grand carr� blanc de la main
    maskFrame = double(maskFrame(:,:,:)>=0.99);
    maskFrame = maskFrame .* frame;

    %pr�paration pour le deuxi�me masque
    coordFrameCoinsMain = appliqueHomographie(inv(H),coinsMain);
    coordFrameCoinsMain = uint32(passeEnCoordEucli(coordFrameCoinsMain));
    %figure,imshow(double(maskFrame))
    %figure,imshow(uint8(maskFrame))

    %deuxi�me masque
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
    maskMain = double(((CR > 0)| (maskMain(:,:,3)<95) | (maskMain(:,:,2)<115)) .* (maskMain(:,:,3)>0) .* (maskMain(:,:,2)>0) ); 
    %maskMain = double(((maskMain(:,:,3)<95) | (maskMain(:,:,2)<115)) .* (maskMain(:,:,3)>0) .* (maskMain(:,:,2)>0)); 
    %>0 pour retirer les pixels noirs du maskMain
    %figure,imshow(double(maskMain))

    %masque total
    maskFrame(ymin:ymax,xmin:xmax,1) = maskMain; 
    maskFrame(ymin:ymax,xmin:xmax,2) = maskMain;
    maskFrame(ymin:ymax,xmin:xmax,3) = maskMain;
    maskFrame = double(maskFrame(:,:,:)>0);
    %figure,imshow(maskFrame)

    %projection de l'image � ins�rer
    desert= double(imread('desert2.jpg'));
    %bip = double(read(bipbip,mod(numFrame,nbFramesBipbip)));
    dimDesert = size(desert);
    coinsDesert = [0 0;dimDesert(2)-1 0;dimDesert(2)-1 dimDesert(1)-1;0 dimDesert(1)-1];
    H = determineH(coinsFrame,coinsDesert);
    frameApresProjection = projection(frame,desert,H,coinsFrame);
    %figure,imshow(uint8(frameApresProjection))
    frameApresProjection = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    %figure,imshow(uint8(frameApresProjection))
    
    
    bouboule= double(imread('bouboule.jpg'));
    dimBouboule = size(bouboule);
    coinsBouboule = [0 0;dimBouboule(2)-1 0;dimBouboule(2)-1 dimBouboule(1)-1;0 dimBouboule(1)-1];
    H = determineH(coinsQuad,coinsBouboule);
    frameApresProjection = projection(frameApresProjection,bouboule,H,coinsQuad);
    % figure,imshow(uint8(frameApresProjection))
    frameFinal = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    %figure,imshow(uint8(frameFinal))

    %tracer un segment
    %figure,imshow(uint8(frame))
    %coins2d = ginput(6)
    %coins2d = fix(coins2d);
    %cage
    coins2d = [686 410;1337 235;1430 581;629 766;919 473;725 695];
    coins3d = [0 0 0;1 0 0;1 1 0;0 1 0;0.38 0.875 0.2;0.125 0.875 0];
    P = determineP(coins3d,coins2d);
    modele = scene3d(numFrame,5,P,0.1);
    frame3d = dessineScene3d(frameFinal, modele, [255 0 255]);
    figure,imshow(uint8(frame3d))
    
    
    
    
    bip = double(imread('bipbip.gif'));
    coinsCactus = [1318 640;1543 640;1541 1021;1316 1024];
    dimBipBip = size(bip);
    coinsBipBip = [0 0;dimBipBip(2)-1 0;dimBipBip(2)-1 dimBipBip(1)-1;0 dimBipBip(1)-1];
    H = determineH(coinsCactus,coinsBipBip);
    frame3d = projection(frame3d,bip,H,coinsFrame);
    figure,imshow(uint8(frame3d))
end




