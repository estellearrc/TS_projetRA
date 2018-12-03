function maskFrame = masqueAvecProjection(frame,maskImg,maskFrame,coinsZoneFlitre,coinsZoneInsertion,fonctionFiltre)
%fonctions anonymes : carre = @(x) x.^2;
    %premier masque
    coinsImg = genereCoins(maskImg);
    coinsFrame = genereCoins(maskFrame);
    [maskFrame,H] = routineProjection(maskImg,coinsImg,maskFrame,coinsFrame,coinsZoneInsertion);
    maskFrame = double(maskFrame(:,:,:)>=0.99);

    
    %récupération des coordonnées des coins de la zone blanche où se trouve la main
    coordFrameCoinsMain = appliqueHomographie(inv(H),coinsZoneFlitre);
    coordFrameCoinsMain = uint32(passeEnCoordEucli(coordFrameCoinsMain));

    %deuxième masque
    %plus petit rectangle englobant de la zone blanche où se trouve la main
    [xmin,xmax,ymin,ymax] = calculeMinMax(coordFrameCoinsMain');
    zone = [xmin,xmax,ymin,ymax];
    
    maskFrame = masqueSansProjection(frame,maskFrame,fonctionFiltre,zone);
    maskFrame = double(maskFrame(:,:,:)>0);
end