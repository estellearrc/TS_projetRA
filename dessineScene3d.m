function frame3d = dessineScene3d(frame, scene3d, couleur)
    cR = couleur(1);
    cG = couleur(2);
    cB = couleur(3);
    X = scene3d(1,:);
    Y = scene3d(2,:);
    pos = Y +(X-1)*1080;
    rouge = cR*ones(size(pos));
    vert = cG*ones(size(pos));
    bleu = cB*ones(size(pos));
    frame([pos pos+1080*1920 pos+2*1080*1920]) = [rouge vert bleu];
    frame3d = frame;
end