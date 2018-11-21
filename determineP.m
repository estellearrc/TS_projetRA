function P = determineP(ptsEsp1,ptsEsp2) %on a besoin de 6 couples de points (xa*s,ya*s,s) --> (xb,yb,zb,1)
    [A,b] = constructAb(ptsEsp1,ptsEsp2);
    P = ((A')*A) \ ((A')*b); %P est un vecteur colonne
    P = [P' 1]; %transformation en vecteur ligne
    P=reshape(P,4,3)'; %il faut transposer car Matlab parcourt les matrice colonne par colonne en mémoire et non ligne par ligne !!!!!
end
function [A,b] = constructAb(ptsEsp1,ptsEsp2)
    A = zeros(12,11);
    b=[];
    for k = 1:6
        x1 = ptsEsp1(k,1);
        y1 = ptsEsp1(k,2);
        z1 = ptsEsp1(k,3);
        x2 = ptsEsp2(k,1);
        y2 = ptsEsp2(k,2);
        b = [b;x2;y2];
        A(2*k-1,:) = [x1 y1 z1 1 0 0 0 0 -x2*x1 -x2*y1 -x2*z1];
        A(2*k,:) = [0 0 0 0 x1 y1 z1 1 -y2*x1 -y2*y1 -y2*z1];
    end
end