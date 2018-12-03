function mask3d = maskRGB(zone,mask2d,mask3d)
    if(numel(zone)==0)
        mask3d(:,:,1) = mask2d; 
        mask3d(:,:,2) = mask2d;
        mask3d(:,:,3) = mask2d;
    else
        xmin = zone(1);
        xmax = zone(2);
        ymin = zone(3);
        ymax = zone(4);
        mask3d(ymin:ymax,xmin:xmax,1) = mask2d; 
        mask3d(ymin:ymax,xmin:xmax,2) = mask2d;
        mask3d(ymin:ymax,xmin:xmax,3) = mask2d;
    end
end