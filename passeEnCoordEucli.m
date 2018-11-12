function coordEucli = passeEnCoordEucli(coordHomo)
%coordHomo est une matrice [X;Y;S]
    S = coordHomo(3,:);
    coordNormalisees = coordHomo ./ [S;S;S];
    coordEucli = coordNormalisees(1:2,:);
end