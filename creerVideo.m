%function video = creerVideo(folderOfFrames)
    %v = VideoReader('vid_in2.mp4');
    %nFrames = v.NumberOfFrames;

%     Folder = 'bipbip_frames_gif';
%     for iFrame = 1:nFrames
%       frames = read(v, iFrame);
%       imwrite(frames, fullfile(Folder, sprintf('%06d.jpeg', iFrame)));
%     end 
% 
%     FileList = dir(fullfile(Folder, '*.gif'));
% 
%     for iFile = 1:length(FileList)
%       aFile = fullfile(Folder, FileList(iFile).name);
%       img   = imread(aFile);
%     end

    ImFolder='bipbip_frames_gif';
    gifFile = dir(strcat(ImFolder,'\*.gif'));
    S = [gifFile(:).datenum];
    [~,S] = sort(S);
    gifFiles = gifFile(S);
    VideoFile=strcat(ImFolder,'\Video');
    writeObj = VideoWriter(VideoFile);
    fps= 10;
    writeObj.FrameRate = fps;
    open(writeObj);
    for t= 1:length(gifFiles)
        Frame=imread(strcat(ImFolder,'\',gifFiles(t).name));
        writeVideo(writeObj,Frame);
    end
    close(writeObj);
    %implay('Video.avi')
%end
