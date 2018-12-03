close all
clear all

load('a.mat', 'C');

%Récupération des différentes vidéos utiles
video = VideoReader('vid_in2.mp4');
nbFramesVideo = video.NumberOfFrames;
bipbip = VideoReader('bipbip_frames2_png/video_bipbip.avi');
nbFramesBipbip = bipbip.NumberOfFrames;
coyote = VideoReader('coyote_frames_png/video_coyote.avi');
nbFramesCoyote = coyote.NumberOfFrames;
desert= double(imread('desert5.jpg'));
compteur = 1;

v = VideoWriter('video_finale.avi');
open(v);

for i = 1:nbFramesVideo
    numFrame = i;
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
    maskFrame = maskFrame .* frame;
    maskFrame = masqueSansProjection(maskFrame,filtreBras,[]);
    
    %masque main ==========================================================
    %premier masque
    maskImg = zeros(100,100,3);%petite image avec que des 1 de taille 100x100
    maskImg(15:66,76:100,:) = ones(52,25,3);
    filtreMain = @(R,G,B,Y,CR) ((CR > 0) | (B<95) | (G<115)) .* (B>0) .* (G>0);
    maskFrame = masqueAvecProjection(frame,maskImg,maskFrame,coinsMain,coinsQuad,filtreMain);
    
    %masque bipbip ========================================================
    [xmin,xmax,ymin,ymax] = calculeMinMax(coinsCactus);
    maskFrame(ymin+4:ymax,xmin+4:xmax,:) = ones(ymax-ymin+1-4,xmax-xmin+1-4,3);
    maskBipBip = ones(100,100,3);%petite image avec que des 1 de taille 100x100
    filtreBipBip = @(R,G,B,Y,CR) (R>10).* (G>10) .* (B>10);
    maskFrame = masqueAvecProjection(frame,maskBipBip,maskFrame,coinsCactus,coinsCactus,filtreBipBip);
        
    %projection du décor ==================================================
    coinsDesert = genereCoins(desert);
    frameApresProjection = routineProjection(desert,coinsDesert,frame,coinsFrame,coinsFrame);
    frameApresProjection = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    
    %projection de coyote =================================================
    coinsCoyote = genereCoins(coy);
    frameApresProjection = routineProjection(coy,coinsCoyote,frameApresProjection,coinsFrame,coinsQuad);
    frameFinal = (1-maskFrame).*frameApresProjection + maskFrame .*frame;
    
    %insertion 3d =========================================================
    coins2d = [686 410;1337 235;1430 581;629 766;919 473;725 695];
    coins3d = [0 0 0;1 0 0;1 1 0;0 1 0;0.38 0.875 0.2;0.125 0.875 0];
    P = determineP(coins3d,coins2d);
    if(mod(numFrame,8)==0)
        compteur = compteur + 1;
    end
    modele = scene3d(numFrame,5,P,0.1,compteur);
    frame3d = dessineScene3d(frameFinal, modele, [255 0 255]);
    %figure,imshow(uint8(frame3d))
    
    writeVideo(v, uint8(frame3d));
end

close(v);