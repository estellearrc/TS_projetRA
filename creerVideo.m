%function out = creerVideo(folderOfFrames,videoName,rate)
    folderOfFrames = 'bipbip_frames2_png';
    videoName = 'video_bipbip';
    rate = 0.5;
    ImFolder = folderOfFrames; %'bipbip_frames_png';
    pngFiles = dir(strcat(ImFolder,'\*.png'));
    VideoFile=strcat(ImFolder,'\',videoName); %video_bipbip
    writeObj = VideoWriter(VideoFile);
    fps= rate;
    writeObj.FrameRate = fps;
    open(writeObj);
    for t= 1:length(pngFiles)
        Frame=imread(strcat(ImFolder,'\',pngFiles(t).name));
        writeVideo(writeObj,Frame);
    end
    close(writeObj);
    out = true;
%end
