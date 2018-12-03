function coins = genereCoins(img)
    dim = size(img);
    coins = [1 1;dim(2) 1;dim(2) dim(1);1 dim(1)];
end