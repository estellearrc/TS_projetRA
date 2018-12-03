close all
clear all

%interpolation bilinéaire à enlever quand masque scalaire (fail)
%agrandir zone masque zone feuille (fail)
%revoir couleurs du masque bras YCbCr
%ranger code
load('a.mat', 'C');

%Récupération de la frame 1
video = VideoReader('vid_in2.mp4');
nbFramesVideo = video.NumberOfFrames;
bipbip = VideoReader('bipbip_frames2_png/video_bipbip.avi');
nbFramesBipbip = bipbip.NumberOfFrames;
coyote = VideoReader('coyote_frames_png/video_coyote.avi');
nbFramesCoyote = coyote.NumberOfFrames;

v = VideoWriter('peaks.avi');
open(v);

for i = 1:nbFramesVideo
    numFrame = 50;
    frame = double(read(video,numFrame));
    coy = double(read(coyote,mod(numFrame,nbFramesCoyote)+1));
    bip = double(read(bipbip,mod(numFrame,nbFramesBipbip)+1));
    %figure,imshow(uint8(frame))

    %homographie
    %coinsQuad = ginput(4)
    %coinsQuad = fix(coinsQuad);
    rangx = 2*i-1;
    rangy = 2*i;

    X1base = C(rangx,1);
    Y1base = C(rangy,1);
    X2base = C(rangx,2);
    Y2base = C(rangy,2);
    X3base = C(rangx,3);
    Y3base = C(rangy,3);
    X4base = C(rangx,4);
    Y4base = C(rangy,4);
    
    %coinsQuad = [685 413;1339 236;1432 578;629 764]; %pour la frame 1 et 50
    coinsQuad = [X1base Y1base;X2base Y2base;X4base Y4base;X3base Y3base];
    coinsFrame = [1 1;1920 1;1920 1080;1 1080];
    coinsCactus = [1516 640;1741 640;1741 1024;1516 1024];
    
        
    %projection de bipbip =================================================
    dimBipBip = size(bip);
    coinsBipBip = [0 0;dimBipBip(2)-1 0;dimBipBip(2)-1 dimBipBip(1)-1;0 dimBipBip(1)-1];
    H = determineH(coinsCactus,coinsBipBip);
    frame = projection(frame,bip,H,coinsFrame);
    
    %masque bras ==========================================================
    maskFrame = zeros(1080,1920,3);%masque du frame de la vidéo
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
    
    %masque main ==========================================================
    %premier masque
    maskImg = zeros(100,100,3);%petite image avec que des 1 de taille 100x100
    maskImg(15:66,76:100,:) = ones(52,25,3);
    coinsMain = [76 100 100 76;15 15 66 66;1 1 1 1];
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
    
    %masque bipbip ========================================================
    [xmin,xmax,ymin,ymax] = calculeMinMax(coinsCactus);
    maskFrame(ymin+4:ymax,xmin+4:xmax,:) = ones(ymax-ymin+1-4,xmax-xmin+1-4,3);
    maskBipBip = ones(100,100,3);%petite image avec que des 1 de taille 100x100
    dim = size(maskBipBip);
    coinsBip = [0 0;dim(2)-1 0;dim(2)-1 dim(1)-1;0 dim(1)-1];
    H = determineH(coinsCactus,coinsBip);
    maskFrame = projection(maskFrame,maskBipBip,H,coinsCactus);%Homographie avec grand carré blanc de la main
    maskFrame = double(maskFrame(:,:,:)>=0.99);
    maskFrame = maskFrame .* frame;

    %deuxième masque
    [xmin,xmax,ymin,ymax] = calculeMinMax(coinsCactus);
    maskBipBip = maskFrame(ymin:ymax,xmin:xmax,:);
    R = maskBipBip(:,:,1);
    G = maskBipBip(:,:,2);
    B = maskBipBip(:,:,3);
%     Y = 0.299*R+0.587*G+0.114*B;
%     CR = 0.713*(R-Y);
%     maskMain = double(((CR > 0)| (maskMain(:,:,3)<95) | (maskMain(:,:,2)<115)) .* (maskMain(:,:,3)>0) .* (maskMain(:,:,2)>0) ); 
    maskBipBip = double((R>10).* (G>10) .* (B>10));
    %maskMain = double(((maskMain(:,:,3)<95) | (maskMain(:,:,2)<115)) .* (maskMain(:,:,3)>0) .* (maskMain(:,:,2)>0)); 
    %>0 pour retirer les pixels noirs du maskMain
    %figure,imshow(double(maskMain))

    %masque total
    maskFrame(ymin:ymax,xmin:xmax,1) = maskBipBip; 
    maskFrame(ymin:ymax,xmin:xmax,2) = maskBipBip;
    maskFrame(ymin:ymax,xmin:xmax,3) = maskBipBip;
    maskFrame = double(maskFrame(:,:,:)>0);
    %figure,imshow(maskFrame)
    
    
    %projection du décor ==================================================
    desert= double(imread('desert5.jpg'));
    %bip = double(read(bipbip,mod(numFrame,nbFramesBipbip)));
    dimDesert = size(desert);
    coinsDesert = [0 0;dimDesert(2)-1 0;dimDesert(2)-1 dimDesert(1)-1;0 dimDesert(1)-1];
    H = determineH(coinsFrame,coinsDesert);
    frameApresProjection = projection(frame,desert,H,coinsFrame);
    %figure,imshow(uint8(frameApresProjection))
    frameApresProjection = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    %figure,imshow(uint8(frameApresProjection))
    
    %projection de coyote =================================================
    dimCoyote = size(coy);
    coinsCoyote = [0 0;dimCoyote(2)-1 0;dimCoyote(2)-1 dimCoyote(1)-1;0 dimCoyote(1)-1];
    H = determineH(coinsQuad,coinsCoyote);
    frameApresProjection = projection(frameApresProjection,coy,H,coinsQuad);
    % figure,imshow(uint8(frameApresProjection))
    frameFinal = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    %figure,imshow(uint8(frameFinal))
    
    %insertion 3d =========================================================
    coins2d = [686 410;1337 235;1430 581;629 766;919 473;725 695];
    coins3d = [0 0 0;1 0 0;1 1 0;0 1 0;0.38 0.875 0.2;0.125 0.875 0];
    P = determineP(coins3d,coins2d);
    modele = scene3d(numFrame,5,P,0.1);
    frame3d = dessineScene3d(frameFinal, modele, [255 0 255]);
    figure,imshow(uint8(frame3d))
    
    writeVideo(v, uint8(frame3d));
end

close(v);

%implay('peaks.avi');