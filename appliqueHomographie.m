function coordFin = appliqueHomographie(H,coordHomo)
%applique l'homographie aux coordonn�es homog�nes coordHomo et renvoie les coordonn�es
%homog�nes correspondantes
    coordFin = H * coordHomo; %coordonn�es du plus petit rectangle englobant le quadrangle
end