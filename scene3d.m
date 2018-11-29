function modele = scene3d(numFrame,epaisseur,P,amplitudeMaxMvt)
    amplitudeMvt = amplitudeMaxMvt * (20 - mod(numFrame,21))/20; %mise à l'échelle
    amplitudeMvtOppose = amplitudeMaxMvt - amplitudeMvt; 
    if(mod(numFrame,41) <= 20)
        points3dCoins = [[0;0;0+amplitudeMvt;1] [0;0;1+amplitudeMvt;1] [1;0;0+amplitudeMvtOppose;1] [1;0;1+amplitudeMvtOppose;1] [1;1;0+amplitudeMvtOppose;1] [1;1;1+amplitudeMvtOppose;1] [0;1;0+amplitudeMvt;1] [0;1;1+amplitudeMvt;1]];
    else
        points3dCoins = [[0;0;0+amplitudeMvtOppose;1] [0;0;1+amplitudeMvtOppose;1] [1;0;0+amplitudeMvt;1] [1;0;1+amplitudeMvt;1] [1;1;0+amplitudeMvt;1] [1;1;1+amplitudeMvt;1] [0;1;0+amplitudeMvtOppose;1] [0;1;1+amplitudeMvtOppose;1]];
    end
    points3dBarreaux = extremitesBarreaux(points3dCoins,5);
    vectCoins = appliqueHomographie(P,points3dCoins);
    vectBarreaux = appliqueHomographie(P,points3dBarreaux);
    points2dCoins = int32(passeEnCoordEucli(vectCoins));
    points2dBarreaux = int32(passeEnCoordEucli(vectBarreaux));
    enveloppeCage = construitPaveDroit(points2dCoins(:,1),points2dCoins(:,2),points2dCoins(:,3),points2dCoins(:,4),points2dCoins(:,5),points2dCoins(:,6),points2dCoins(:,7),points2dCoins(:,8),epaisseur);
    barreaux = construitBarreaux(points2dBarreaux,epaisseur);
    modele = [enveloppeCage barreaux];
end
function segment = construitSegment(pointHaut2d, pointBas2d,epaisseur)
%algorithme de construction de segment = [X;Y] de Bresenham
    xh = pointHaut2d(1,1);
    yh = pointHaut2d(2,1);
    xb = pointBas2d(1,1);
    yb = pointBas2d(2,1);
    if(yh < yb)
        xh = pointBas2d(1,1);
        yh = pointBas2d(2,1);
        xb = pointHaut2d(1,1);
        yb = pointHaut2d(2,1);
    end
    dx = abs(xh - xb);
    dy = abs(yh - yb);
    if(dx >= dy) %pente entre 0 et 1 en valeur absolue
        dp = 2 * dy - dx; % Valeur initiale de dp
        deltaE = 2 * dy;
        deltaNE = 2 * (dy - dx);
    else %pente > 1 en valeur absolue
        dp = 2 * dx - dy; % Valeur initiale de dp
        deltaE = 2 * dx;
        deltaNE = 2 * (dx - dy);
    end
    x = xb;
    y = yb;
    X = x;
    Y = y;
    while (y < yh) %on parcourt le segment du point bas vers le point haut
        if (dp <= 0) %On choisit le point tel que y_p+1 = y_p
            dp = dp + deltaE; %Nouveau dp
            if(xh >= xb && dx >= dy) %pente entre 0 et 1
                x = x + 1; %Calcul de x_p+1 
            else if(dx < dy) %pente > 1 en valeur absolue
                y = y + 1;
                else if(xh < xb && dx >= dy) %pente entre 0 et -1
                    x = x - 1;
                    end
                end
            end
        else %On choisit le point tel que y_p+1 = y_p + 1
            dp = dp + deltaNE; %Nouveau dp
            if(xh >= xb) %pente positive
                x = x + 1; %Calcul de x_p+1
            else %pente négative
                x = x - 1;
            end
            y = y + 1; %Calcul de y_p+1
        end
        X = [X x];
        Y = [Y y];
        if(epaisseur > 1)
            [X,Y] = epaissirTrait(X,Y,x,y,epaisseur);
        end
    end
    segment = [X; Y];
end
function [X,Y] = epaissirTrait(X,Y,x,y,epaisseur)
    for i = 2:epaisseur
        if(mod(i,2) == 0)
            X = [X x+1];
            Y = [Y y];
            x = x + 1;
        else
            X = [X x];
            Y = [Y y+1];
            y = y + 1;
        end
    end
end
function rect = construitRectangle(point1,point2,point3,point4,epaisseur)
    rect = [construitSegment(point1,point2,epaisseur) construitSegment(point2,point3,epaisseur) construitSegment(point3,point4,epaisseur) construitSegment(point4,point1,epaisseur)];
end
function pave = construitPaveDroit(point1,point2,point3,point4,point5,point6,point7,point8,epaisseur)
    rectFloor = construitRectangle(point1,point3,point5,point7,epaisseur);
    rectCeil = construitRectangle(point2,point4,point6,point8,epaisseur);
    areteVerticale1 = construitSegment(point1, point2,epaisseur);
    areteVerticale2 = construitSegment(point3, point4,epaisseur);
    areteVerticale3 = construitSegment(point5, point6,epaisseur);
    areteVerticale4 = construitSegment(point7, point8,epaisseur);
    pave = [rectFloor rectCeil areteVerticale1 areteVerticale2 areteVerticale3 areteVerticale4];
end
function barreaux = extremitesBarreaux(points8,nbBarreauxParFace)
%points8 = [X; Y; Z; 1] où size(X) = [1 8]
    X = [];
    Y = [];
    Z = [];
    for i = 0:3 %on parcourt les 8 points pour les 4 faces verticales
        %on récupère les 4 points d'une même face
        pointBas1 = points8(:,1 + 2*i);
        pointHaut1 = points8(:,2 + 2*i);
        if(i == 3)
            pointBas2 = points8(:,1);
            pointHaut2 = points8(:,2);
        else
            pointBas2 = points8(:,3 + 2*i);
            pointHaut2 = points8(:,4 + 2*i);
        end
        %calcul des coordonnées des barreaux indépendamment de la face sur
        %laquelle on se trouve pour pouvoir appliquer n'importe quel
        %mouvement à la cage
        %concernant les x
        xBas1 = pointBas1(1);
        xBas2 = pointBas2(1);
        xHaut1 = pointHaut1(1);
        xHaut2 = pointHaut2(1);
        espacementBarreauBasX = abs(xBas1 - xBas2)/(nbBarreauxParFace +1);
        espacementBarreauHautX = abs(xHaut1 - xHaut2)/(nbBarreauxParFace +1);
        %concernant les y
        yBas1 = pointBas1(2);
        yBas2 = pointBas2(2);
        yHaut1 = pointHaut1(2);
        yHaut2 = pointHaut2(2);
        espacementBarreauBasY = abs(yBas1 - yBas2)/(nbBarreauxParFace +1);
        espacementBarreauHautY = abs(yHaut1 - yHaut2)/(nbBarreauxParFace +1);
        %concernant les z
        zBas1 = pointBas1(3);
        zBas2 = pointBas2(3);
        zHaut1 = pointHaut1(3);
        zHaut2 = pointHaut2(3);
        espacementBarreauBasZ = abs(zBas1 - zBas2)/(nbBarreauxParFace +1);
        espacementBarreauHautZ = abs(zHaut1 - zHaut2)/(nbBarreauxParFace +1);
        for k = 1:nbBarreauxParFace %pour chaque barreau, on ajoute les coordonnées de ses extrémités
            %concernant les x
            if(xBas1 < xBas2)
                X = [X xBas1+k*espacementBarreauBasX xHaut1+k*espacementBarreauHautX];
            else
                X = [X xBas1-k*espacementBarreauBasX xHaut1-k*espacementBarreauHautX];
            end
            %concernant les y
            if(yBas1 < yBas2)
                Y = [Y yBas1+k*espacementBarreauBasY yHaut1+k*espacementBarreauHautY];
            else
                Y = [Y yBas1-k*espacementBarreauBasY yHaut1-k*espacementBarreauHautY];
            end
            %concernant les z
            if(zBas1 < zBas2)
                Z = [Z zBas1+k*espacementBarreauBasZ zHaut1+k*espacementBarreauHautZ];
            else
                Z = [Z zBas1-k*espacementBarreauBasZ zHaut1-k*espacementBarreauHautZ];
            end
        end
    end
    barreaux = [X; Y; Z; ones(size(X))];
end
function barreaux = construitBarreaux(points2dBarreaux,epaisseur)
    dim = size(points2dBarreaux);
    barreaux = [];
    i = 1;
    while(i < dim(2))
        barreaux = [barreaux construitSegment(points2dBarreaux(:,i),points2dBarreaux(:,i+1),epaisseur)];
        i = i + 2;
    end
end
