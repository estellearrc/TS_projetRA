function maskFrame = masqueSansProjection(frame,maskFrame,fonctionFiltre,zone)
    maskFrame = maskFrame .* frame;
    if(numel(zone)==0)
        [R,G,B,Y,CR] = composantesColorimetriques(maskFrame);
    else
        xmin = zone(1);
        xmax = zone(2);
        ymin = zone(3);
        ymax = zone(4);
        maskZoneInsertion = maskFrame(ymin:ymax,xmin:xmax,:);
        [R,G,B,Y,CR] = composantesColorimetriques(maskZoneInsertion);
    end
    maskZoneInsertion = fonctionFiltre(R,G,B,Y,CR);
    maskFrame = maskRGB(zone,maskZoneInsertion,maskFrame);
end