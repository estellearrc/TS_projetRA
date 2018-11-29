function [xmin,xmax,ymin,ymax] = calculeMinMax(coord)
%coord euclidiennes
    xmin = min(coord(:,1));
    xmax = max(coord(:,1));
    ymin = min(coord(:,2));
    ymax = max(coord(:,2));
end