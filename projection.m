function frame = projection(frame,img,H,coinsQuadrangle)
    dim1 = size(img);
    dim2 = size(frame);
    h1 = dim1(1);
    w1 = dim1(2);
    h2 = dim2(1);
    w2 = dim2(2);
    
    %travail en coordonn�es homog�nes
    coordIniRect = genereCoordHomo(coinsQuadrangle);
    coordFin = appliqueHomographie(H,coordIniRect);
    
    %travail en coordonn�es euclidiennes
    coordFin = passeEnCoordEucli(coordFin);
    coordIniRect = passeEnCoordEucli(coordIniRect);
    ind = filtreCoord(coordFin,dim1);
    coordFin= calculeCoordCorrespondantes(ind,coordFin);
    coordIni = calculeCoordCorrespondantes(ind,coordIniRect);
    IR = interpolationBilineaireIntensite(dim1,img,coordFin,0);
    IG = interpolationBilineaireIntensite(dim1,img,coordFin,h1*w1);
    IB = interpolationBilineaireIntensite(dim1,img,coordFin,2*h1*w1);
    I = [IR IG IB];
    X = coordIni(1,:);
    Y = coordIni(2,:);
    pos2 = Y +(X-1)*h2;
    frame([pos2 pos2+w2*h2 pos2+2*w2*h2]) = I;
end
function intensiteInterpolee = interpolationBilineaireIntensite(dim,img,coord,decalage)
    X = coord(1,:);
    Y = coord(2,:);
    voisinsExcesX = ceil(X);
    voisinsExcesY = ceil(Y);
    voisinsDefautX = floor(X);
    voisinsDefautY = floor(Y);
    alpha = X - voisinsDefautX;
    beta = Y - voisinsDefautY;
    coefs = [(1-alpha).*(1-beta);alpha.*(1-beta);alpha.*beta;(1-alpha).*beta];
    IHG = img(voisinsDefautY+(voisinsDefautX - 1)*dim(1)+decalage);
    IHD = img(voisinsDefautY+(voisinsExcesX - 1)*dim(1)+decalage);
    IBD = img(voisinsExcesY+(voisinsExcesX - 1)*dim(1)+decalage);
    IBG = img(voisinsExcesY+(voisinsDefautX - 1)*dim(1)+decalage);
    I = [IHG;IHD;IBD;IBG];
    I = I .* coefs;
    intensiteInterpolee = I(1,:) + I(2,:) + I(3,:) + I(4,:);
end
function coordFin = appliqueHomographie(H,coordHomo)
%applique l'homographie aux coordonn�es homog�nes coordHomo et renvoie les coordonn�es
%homog�nes correspondantes
    coordFin = H * coordHomo; %coordonn�es du plus petit rectangle englobant le quadrangle
end
function newCoord = calculeCoordCorrespondantes(ind,coord)
%calcule les coordonn�es euclidiennes de coord correspondant aux indices ind
    X = coord(1,:);
    Y = coord(2,:);
    newCoord = [X(ind);Y(ind)];
end
function ind = filtreCoord(coord,dim)
%coord = coordonn�es euclidiennes, renvoie les indices des points dont les coordonn�es
%correspondent � un point image par l'homographie, donc � un point de
%l'image d'arriv�e de dimensions dim = x*y
    X = coord(1,:);
    Y = coord(2,:);
    ind = find((X>=1).*(X<=dim(2)).*(Y>=1).*(Y<=dim(1)));
end
function coordHomo = genereCoordHomo(coinsQuadrangle) 
%g�n�re les coord homog�nes du plus petit rectangle englobant le quadrangle
    xmin = min(coinsQuadrangle(:,1));
    xmax = max(coinsQuadrangle(:,1));
    ymin = min(coinsQuadrangle(:,2));
    ymax = max(coinsQuadrangle(:,2));
    [X,Y,S] = meshgrid(xmin:xmax,ymin:ymax,1);
    %S = ones(ymax-ymin+1,xmax-xmin+1);
    X = reshape(X,1,(xmax-xmin+1)*(ymax-ymin+1));
    Y= reshape(Y,1,(xmax-xmin+1)*(ymax-ymin+1));
    S = reshape(S,1,(xmax-xmin+1)*(ymax-ymin+1));
    coordHomo = passeEnCoordHomo([X;Y],S);
end
function coordHomo = passeEnCoordHomo(coordEucli,S) 
%coordEucli est une matrice [X;Y] o� X et Y sont 2 vecteurs lignes
    coordHomo = [ coordEucli .* [S;S] ;S];
end
function coordEucli = passeEnCoordEucli(coordHomo)
%coordHomo est une matrice [X;Y;S]
    S = coordHomo(3,:);
    coordNormalisees = coordHomo ./ [S;S;S];
    coordEucli = coordNormalisees(1:2,:);
end