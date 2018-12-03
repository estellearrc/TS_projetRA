function maskFrame = masqueAvecProjection(frame,maskImg,maskFrame,coinsZoneFiltre,coinsZoneInsertion,fonctionFiltre)
%fonctions anonymes : carre = @(x) x.^2;
    %premier masque
    coinsImg = genereCoins(maskImg);
    coinsFrame = genereCoins(maskFrame);
    [maskFrame,H] = routineProjection(maskImg,coinsImg,maskFrame,coinsFrame,coinsZoneInsertion);
    maskFrame = double(maskFrame(:,:,:)>=0.99);
    maskFrame = maskFrame .* frame;

    if(size(coinsZoneFiltre) ~= size(coinsZoneInsertion)) %si coinsZoneFlitre != coinsZoneInsertion
        %récupération des coordonnées des coins de la zone blanche où se trouve la main
        coinsZoneFiltre = appliqueHomographie(inv(H),coinsZoneFiltre);
        coinsZoneFiltre = uint32(passeEnCoordEucli(coinsZoneFiltre));
        coinsZoneFiltre = coinsZoneFiltre';

        %deuxième masque
        %plus petit rectangle englobant de la zone blanche où se trouve la main
    end
    [xmin,xmax,ymin,ymax] = calculeMinMax(coinsZoneFiltre);
    zone = [xmin,xmax,ymin,ymax];
    
    maskFrame = masqueSansProjection(maskFrame,fonctionFiltre,zone);
    maskFrame = double(maskFrame(:,:,:)>0);
end