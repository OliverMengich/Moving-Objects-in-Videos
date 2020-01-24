videoreader = vision.VideoFileReader('Busy_Traffic.mp4');
%display = vision.VideoPlayer;

%% Loop till I reach end of video
%while ~isDone(videoreader)
    
  %  image = step(reader);
    
 %   step(display, image);
%end
%release(reader);
%release(display);
%% Create video player

videoPlayer = vision.VideoPlayer;
fgPlayer = vision.VideoPlayer;

%% Create Foreground Detector (Background Subtraction)

foregroundDetector = vision.ForegroundDetector('NumGaussians',3,'NumTrainingFrames',50);
% Run on first 75 frames to learn background

for i = 1:75
    videoFrame = step(videoreader);
    foreground = step(foregroundDetector,videoFrame);
end

figure; imshow(videoFrame);title('InputFrame');
figure; imshow(foreground);title('Foreground');

%% Perfom image morphology to filter out the foreground
cleanforeground = imopen(foreground,strel('Disk',1));
figure;
subplot(1,2,1); imshow(foreground);title('Origin Foreground');
subplot(1,2,2); imshow(cleanforeground);title('Clean foreground');
%% Create blob analysis object
% blob analysis object further filters the detected foreground by rejecting
% blobs higher than 150 pixels
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort',true,...
'AreaOutputPort',false,'CentroidOutputPort',false,...
'MinimumBlobArea',150);

 %% Loop through video
 
 while ~isDone(videoreader)
  %% get next frame
  videoFrame = step(videoreader);
  %% video processing code goes here
  foreground = step(foregroundDetector,videoFrame);
  cleanforeground = imopen(foreground,strel('Disk',1));
  %% detect connected components with specified minimum area and compute their bounding boxes
  bbox=  step(blobAnalysis,cleanforeground);
  
  % Draw bounding boxes around the detected cars
  result = insertShape(videoFrame,'rectangle',bbox,'Color','green');
  
  % Display number of objects found
  numCars =  size(bbox,1);
     text = sprintf('Detected Cars = %d',numCars);
     result = insertText(result,[10,10],numCars,'BoxOpacity',1,'FontSize',14);
    % end of video
    %% display output
    step(videoPlayer,result);
    step(fgPlayer,cleanforeground);
    
 end
 %% release video reader and writer
 
 release(videoPlayer);
 release(videoreader);
 delete(videoPlayer);
