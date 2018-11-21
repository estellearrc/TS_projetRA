function modele = scene3d(numFrame)
    modele = construitSegment([0 0 1], [100 100 1]);
    
end
function segment = construitSegment(pointHaut, pointBas)
%algorithme de construction de segment = [X;Y] de Bresenham
    xh = pointHaut(1);
    yh = pointHaut(2);
    xb = pointBas(1);
    yb = pointBas(2);
    dx = xb - xh;
    dy = yb - yh;
    if(dx >= dy) %pente entre 0 et 1 en valeur absolue
        dp = 2 * dy - dx; % Valeur initiale de dp
        deltaE = 2 * dy;
        deltaNE = 2 * (dy - dx);
    else %pente > 1 en valeur absolue
        dp = 2 * dx - dy; % Valeur initiale de dp
        deltaE = 2 * dx;
        deltaNE = 2 * (dx - dy);
    end
    x = xh;
    y = yh;
    X = x;
    Y = y;
    while (x < xb) %on parcourt le segment du point haut vers le point bas
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
function carre = construitCarre(segment, position)
    
end
