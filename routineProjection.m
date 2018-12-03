function [frame,H] = routineProjection(img,coinsImg,frame,coinsFrame,coinsZoneInsertion)
    H = determineH(coinsZoneInsertion,coinsImg);
    frame = projection(frame,img,H,coinsFrame);
end