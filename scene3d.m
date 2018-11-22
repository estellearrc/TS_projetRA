function modele = scene3d(numFrame,P)
    pointBas3d = [0;0;0;1];
    pointHaut3d = [1;1;0;1];
    vectB = P * pointBas3d;
    vectH = P * pointHaut3d;
    pointHaut2d = int32(passeEnCoordEucli(vectH));
    pointBas2d = int32(passeEnCoordEucli(vectB));
    modele = construitSegment(pointHaut2d,pointBas2d);
end
function segment = construitSegment(pointHaut2d, pointBas2d)
%algorithme de construction de segment = [X;Y] de Bresenham
    xh = pointHaut2d(1);
    yh = pointHaut2d(2);
    xb = pointBas2d(1);
    yb = pointBas2d(2);
    dx = xh - xb;
    dy = yh - yb;
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
    while (x < xh) %on parcourt le segment du point bas vers le point haut
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
    end
    segment = [X; Y];
end
function rect = construitRectangle(point1,point2,point3,point4)
    rect = [construitSegment(point1,point2) construitSegment(point3,point2) construitSegment(point3,point4) construitSegment(point4,point1)];
end
function pave = construitPaveDroit(point1,point2,point3,point4,point5,point6,point7,point8)
    rectFloor = construitRectangle(point1,point2,point3,point4);
    rectCeil = construitRectangle(point5,point6,point7,point8);
    areteVerticale1 = construitSegment(point1, point5);
    areteVerticale2 = construitSegment(point2, point6);
    areteVerticale3 = construitSegment(point3, point7);
    areteVerticale4 = construitSegment(point4, point8);
    pave = [rectFloor rectCeil areteVerticale1 areteVerticale2 areteVerticale3 areteVerticale4];
end
