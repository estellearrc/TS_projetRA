function coordFin = appliqueHomographie(H,coordHomo)
%applique l'homographie aux coordonnées homogènes coordHomo et renvoie les coordonnées
%homogènes correspondantes
    coordFin = H * coordHomo; %coordonnées du plus petit rectangle englobant le quadrangle
end