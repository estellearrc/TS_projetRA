close all
clear all

load('a.mat', 'C');

%Récupération des différentes vidéos utiles
video = VideoReader('vid_in2.mp4');
nbFramesVideo = video.NumberOfFrames;
bipbip = VideoReader('bipbip_frames2_png\video_bipbip.avi');
nbFramesBipbip = bipbip.NumberOfFrames;
coyote = VideoReader('coyote_frames_png\video_coyote.avi');
nbFramesCoyote = coyote.NumberOfFrames;
desert= double(imread('desert5.jpg'));

%v = VideoWriter('video_finale.avi');
%open(v);

%for i = 1:nbFramesVideo
    numFrame = 50;
    frame = double(read(video,numFrame));
    coy = double(read(coyote,mod(numFrame,nbFramesCoyote)+1));
    bip = double(read(bipbip,mod(numFrame,nbFramesBipbip)+1));

    rangx = 2*numFrame-1;
    rangy = 2*numFrame;

    X1base = C(rangx,1);
    Y1base = C(rangy,1);
    X2base = C(rangx,2);
    Y2base = C(rangy,2);
    X3base = C(rangx,3);
    Y3base = C(rangy,3);
    X4base = C(rangx,4);
    Y4base = C(rangy,4);
    
    coinsQuad = [X1base Y1base;X2base Y2base;X4base Y4base;X3base Y3base];
    coinsFrame = genereCoins(frame);
    coinsCactus = [1516 640;1741 640;1741 1024;1516 1024];
    coinsMain = [76 100 100 76;15 15 66 66;1 1 1 1];
    
        
    %projection de bipbip =================================================
    coinsBip = genereCoins(bip);
    [frame,H] = routineProjection(bip,coinsBip,frame,coinsFrame,coinsCactus);
    
    %masque bras ==========================================================
    maskFrame = zeros(1080,1920,3);%masque du frame de la vidéo
    xmin = 960;
    xmax = 1920;
    ymin = 1;
    ymax = 540;
    maskFrame(ymin:ymax,xmin:xmax,:) = ones(ymax-ymin+1,xmax-xmin+1,3);
    filtreBras = @(R,G,B,Y,CR) (CR > 6).*(R < 115);
    maskFrame = masqueSansProjection(frame,maskFrame,filtreBras,[]);
    
    %masque main ==========================================================
    %premier masque
    maskImg = zeros(100,100,3);%petite image avec que des 1 de taille 100x100
    maskImg(15:66,76:100,:) = ones(52,25,3);
    filtreMain = @(R,G,B,Y,CR) ((CR > 0) | (B<95) | (G<115)) .* (B>0) .* (G>0);
    maskFrame = masqueAvecProjection(frame,maskImg,maskFrame,coinsMain,coinsQuad,filtreMain);
    
%     dim = size(maskImg);
%     coinsImg = [0 0;dim(2)-1 0;dim(2)-1 dim(1)-1;0 dim(1)-1];
%     H = determineH(coinsQuad,coinsImg);
%     maskFrame = projection(maskFrame,maskImg,H,coinsQuad);%Homographie avec grand carré blanc de la main
%     maskFrame = double(maskFrame(:,:,:)>=0.99);
%     maskFrame = maskFrame .* frame;
% 
%     %récupération des coordonnées des coins de la zone blanche où se trouve la main
%     coordFrameCoinsMain = appliqueHomographie(inv(H),coinsMain);
%     coordFrameCoinsMain = uint32(passeEnCoordEucli(coordFrameCoinsMain));
% 
%     %deuxième masque
%     %plus petit rectangle englobant de la zone blanche où se trouve la main
%     [xmin, xmax, ymin, ymax] = calculeMinMax(coordFrameCoinsMain');
%     maskMain = maskFrame(ymin:ymax,xmin:xmax,:);
%     [R,G,B,Y,CR] = composantesColorimetriques(maskMain);
%     maskMain = double(((CR > 0)| (B<95) | (G<115)) .* (B>0) .* (G>0) ); 
%     %>0 pour retirer les pixels noirs du maskMain
% 
%     %masque total
%     maskFrame = maskRGB([xmin xmax ymin ymax],maskMain,maskFrame);
%     maskFrame = double(maskFrame(:,:,:)>0);
    
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
    [R,G,B,Y,CR] = composantesColorimetriques(maskBipBip);
    maskBipBip = double((R>10).* (G>10) .* (B>10)); 

    %masque total
    maskFrame = maskRGB([xmin,xmax,ymin,ymax],maskBipBip,maskFrame);
    maskFrame = double(maskFrame(:,:,:)>0);
    
    %projection du décor ==================================================
    dimDesert = size(desert);
    coinsDesert = [0 0;dimDesert(2)-1 0;dimDesert(2)-1 dimDesert(1)-1;0 dimDesert(1)-1];
    H = determineH(coinsFrame,coinsDesert);
    frameApresProjection = projection(frame,desert,H,coinsFrame);
    frameApresProjection = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    
    %projection de coyote =================================================
    dimCoyote = size(coy);
    coinsCoyote = [0 0;dimCoyote(2)-1 0;dimCoyote(2)-1 dimCoyote(1)-1;0 dimCoyote(1)-1];
    H = determineH(coinsQuad,coinsCoyote);
    frameApresProjection = projection(frameApresProjection,coy,H,coinsQuad);
    frameFinal = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    
    %insertion 3d =========================================================
    coins2d = [686 410;1337 235;1430 581;629 766;919 473;725 695];
    coins3d = [0 0 0;1 0 0;1 1 0;0 1 0;0.38 0.875 0.2;0.125 0.875 0];
    P = determineP(coins3d,coins2d);
    modele = scene3d(numFrame,5,P,0.1);
    frame3d = dessineScene3d(frameFinal, modele, [255 0 255]);
    figure,imshow(uint8(frame3d))
    
    %writeVideo(v, uint8(frame3d));
%end

%close(v);