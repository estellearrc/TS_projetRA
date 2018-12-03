function [R,G,B,Y,CR] = composantesColorimetriques(mask)
    R = mask(:,:,1);
    G = mask(:,:,2);
    B = mask(:,:,3);
    Y = 0.299*R+0.587*G+0.114*B;
    CR = 0.713*(R-Y);
end