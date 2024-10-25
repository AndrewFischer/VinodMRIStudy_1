%%MRI_Videos_AF()
% 
%% Development / Production Settings
% Setting devmode to 1 speeds things up, enables keyboard...
% For production, set devMode = 0.
devMode = 0;   

% Production code should pass the timing tests. 
% Turning warnings off is not acceptable for a real experiment
Screen('Preference','VisualDebugLevel', 1);  %0 turns off all in-experment warnings. 
%Screen('Preference', 'SkipSyncTests', 1);   %Turn off warnings so this will run on a mac. 

%%Initialization Section
% Set up constants:
maxResponseSecs = 4; %Wait no more than 5 seconds for a response.
maxRestSecs = 12;   %maxium rest time, if response time is zero. 
maxMovieDuration = 4; %Stop playing movies after 4 seconds. 
%The rest block is 10 seconds - respTime.  Dev mode cuts that down to 1s. 

%%Allocate timing crtical items to reduce delay. 
%Initialize Trial Timing Variables.
%We use GetSecs for accurate trial timing. The absolute value of 
%GetSecs is platform dependant.  However the delta values are accurate.
%So we have to get the time as the start of an event and the end. 
GetSecs();      %pre-load mex file.
trialStartTime = 0; %Time at start of trial loop
respStartTime = 0;  %Time at start of response window 
firstRespTime = 0;  %Time of first response
secondRespTime = 0; %Time of second (click button) response
respEndTime = 0;    %Time at end of response window
respDuration = 0;   %Time spent in response blocks
movieStartTime = 0; %Begin playing movie time


%AF Read in static images. 
btn_up = imread('button_up.bmp');
btn_down = imread('button_down2.bmp');
borgImage = imread('Borg.jpg');
% Pre-load the rest block fixation point.
fixationPointImg = imread('fixation_cross.png','png');

%% Response Device Setup
KbName('UnifyKeyNames');    %This is for cross-platform compatibility. 
% Setup key mapping:
space = KbName('SPACE');
esc = KbName('ESCAPE');
up = KbName('UpArrow');
down = KbName('DownArrow');
triggerKey = KbName('t');    % CurDes932 Scanner Trigger 
redButton = KbName('r');    % CurDes932 red button
greenButton = KbName('g');  % CurDes932 green button
blueButton = KbName('b');
yellowButton = KbName('y');

%On Linux you MUST use GetKeyboardIndices to identify the 932.  Otherwise
% we might use the wrong device. 
% On windows all keyboards appear as a single device.
% if you port to linux use
% [keyboardIndices, productNames, allInfos] = GetKeyboardIndices([productName][, serialNumber][, locationID])
% to find and use the 932

deviceIndex932 = [];  %index of the CurDes932 interface box.

%% Setup video files
subject = input('Please enter a subject number ', 's');

% Set the path to the "Videos" folder
folderPath = fullfile(pwd, 'Videos');  % 'pwd' returns the current folder path

% Code from Joe Butler to shuffle the videos:
% Get the list of all .mp4 files in the "Videos" folder and shuffle them
fileList = dir(fullfile(folderPath, '*.mp4'));

% Extract the names and store them in a cell array
videoFiles = {fileList.name};     

% Shuffle the video files
shuffledOrder = randperm(length(videoFiles));  

% create new variable with shuffled videls
shuffledVideos = videoFiles(shuffledOrder); 

%Preallocate arrays to reduce overhead in trial loop.
RPE = zeros(length(shuffledVideos),'int16');
ResponseTime = zeros(length(shuffledVideos));
ClickTime = zeros(length(shuffledVideos));
RestDuration = zeros(length(shuffledVideos));

%% End Init Block
%% *** SHOW START UP SCREEN AND WAIT FOR Scanner Trigger ***
% Scanner trigger is 't' key. Space works for testing. 
try
    I = imread('startupScreen.bmp');
    [window, ~] = Screen('OpenWindow', 0, [0 0 0], [],32,2);
    our_texture = Screen('MakeTexture', window, I);
    Screen('DrawTexture', window, our_texture, [], []);
    HideCursor;
    Screen('Flip',window);

    % Wait for the MRI Scanner trigger, a 't' keypress
    % See
    % https://github.com/Psychtoolbox-3/Psychtoolbox-3/blob/master/Psychtoolbox/PsychDocumentation/KbQueue.html
    % 
    keysOfInterest=zeros(1,256);
    keysOfInterest(triggerKey)=1;
    if(devMode == 1)
        keysOfInterest(space) = 1;
    end
    KbQueueCreate(deviceIndex932, keysOfInterest);
    KbQueueStart(deviceIndex932);

    timeSecs = KbQueueWait(deviceIndex932); 

    KbQueueRelease(deviceIndex932);   
catch
  ListenChar(0);
  psychrethrow(psychlasterror);
  Screen('CloseAll');
end
Screen('Close',our_texture);   %AF Clean up startup screen. 

%Use the window we already have open
%This fixed a 'flashing' bug 
[w,h] = Screen('WindowSize',window);    %Get screen dimensions.

% Make the static textures. This should be outside of the trial loop. 
button_up_texture = Screen('MakeTexture', window, btn_up);
button_down_texture = Screen('MakeTexture', window,btn_down);
fixation_texture = Screen('MakeTexture', window, fixationPointImg);
borgTexture = Screen('MakeTexture', window, borgImage);

trialStartTime = GetSecs();  %Time at start of trial loop.
%% Trial Loop    
for trial = 1:length(shuffledVideos) %this uses number of videos to define n trials
    HideCursor;

% Play movie

% Get the full path of the video file using trial no from shuffled videos
   trialVideoFile = fullfile(folderPath, shuffledVideos{trial});

% Play the movie.
try
    % Open the movie file
    movie = Screen('OpenMovie', window, trialVideoFile);

    % Start playing the movie
    Screen('PlayMovie', movie, 1);
    movieStartTime = GetSecs();
    % Playback loop 
    while movieStartTime + 4 > GetSecs() % Play 4 sec or end of movie
        % Get the next frame of the movie
        tex = Screen('GetMovieImage', window, movie);

        % If the texture is a valid texture, draw it on the screen
        if tex > 0
            Screen('DrawTexture', window, tex);
            Screen('Flip', window);
            Screen('Close', tex);  % Release texture to save memory
        else
            break;  % Exit if there are no more frames
        end
    end

    % Stop playing the movie
    Screen('PlayMovie', movie, 0);

    % Close the movie
    Screen('CloseMovie', movie);

catch exception
    ListenChar(0);
    Screen('CloseAll')
    disp('Error occurred while playing the movie:');
    disp(exception.message);
end  % play movie end

    % SELECT VALUE FROM RPE SCALE

    HideCursor;
    Screen('DrawTexture', window, borgTexture, [], []); 
    Screen('Flip',window);      

    abortit = 0;
    cursorVPosition = h/2; % Half way up the screen. AF use hight, not a fixed  number. 
    respStartTime = GetSecs();
    %AF kbCheck may occassionally miss a button press in the scanner. 
    while abortit == 0
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown == 1 && keyCode(space))
            abortit = 1;
        end
        if (keyIsDown == 1 && keyCode(down) && (cursorVPosition < (h - 40)))
            cursorVPosition = cursorVPosition + 5;
        end
        if (keyIsDown == 1 && keyCode(up) && (cursorVPosition > 40))
            cursorVPosition = cursorVPosition - 5;
        end
      
        % Draw pointers to show selection...
        rectangleStart = 73;
        if ((cursorVPosition > 50) && (cursorVPosition < (h - 65)))
            rectangleHeight = 74;
            cursorVOffset = 60;
            Screen('DrawTexture', window, borgTexture, [], []);
            %Screen('FrameRect', window, [0 255 0],[350 rectangleStart + rectangleHeight *(round((cursorVPosition-cursorVOffset) / rectangleHeight)) - 40 1550 rectangleStart + rectangleHeight*(round((cursorVPosition-cursorVOffset) / rectangleHeight)) + 40],5);
            
            pointerCentre = rectangleStart + rectangleHeight *(round((cursorVPosition-cursorVOffset) / rectangleHeight));
            Screen('FillPoly', window ,[255 0 0], [340 pointerCentre - 30; 340 pointerCentre + 30; 390 pointerCentre],5);
            Screen('FillPoly', window ,[255 0 0], [940 pointerCentre - 30; 940 pointerCentre + 30; 890 pointerCentre],5);
    
            HideCursor;
    
            Screen('Flip',window);
    
            RPE(trial) = 6 + round((cursorVPosition - cursorVOffset) / rectangleHeight);
        else
            pause(0.001);
        end
        if((GetSecs() - (respStartTime + maxResponseSecs)) > 0)  %check response timeout
                abortit = 1;
        end

    end
    firstRespTime = GetSecs();
    ResponseTime(trial) = firstRespTime - respStartTime;
    % SUBJECT MUST NOW CLICK the BUTTON
    abortit = 0;
    cursorVPosition = 0;
    buttonDown = false;
    
    % Put the cursor in the middle third of the screen but above or below the button. 
    while ( (cursorVPosition == 0) || (cursorVPosition > ((h/2)-100)) && (cursorVPosition < ((h/2)+100)))
        cursorVPosition = (h/3) + randi(h/3);   %anywhere in the middle third of the screen. 
    end
    
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    while abortit == 0
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown == 1 && keyCode(space) && (buttonDown == true))
            abortit = 1;
        end
        if (keyIsDown == 1 && keyCode(down) && (cursorVPosition < h-50))
            cursorVPosition = cursorVPosition + 5;
        end
        if (keyIsDown == 1 && keyCode(up) && (cursorVPosition > 50))
            cursorVPosition = cursorVPosition - 5;
        end
    
        % Draw pointers to show selection...
        rectangleStart = 73;
        arrowHPosition = w/2;
    
        if ((cursorVPosition > 50) && (cursorVPosition < (h - 65)))
            rectangleHeight = 74;
            cursorVOffset = 60;
    
            if (cursorVPosition > (h/2 - 100) ) && (cursorVPosition < (h/2)+100 )
                Screen('DrawTexture', window, button_down_texture, [], []); 
                buttonDown = true;
            else
                Screen('DrawTexture', window, button_up_texture , [], []);
                buttonDown = false;
            end
            
            pointerCentre = cursorVPosition;
    
            Screen('FillPoly', window ,[255 0 0], [arrowHPosition pointerCentre; arrowHPosition + 35 pointerCentre + 10; arrowHPosition + 20 pointerCentre + 30],5);
            
            Screen('FillPoly', window ,[255 0 0], [arrowHPosition + 27 pointerCentre + 15; arrowHPosition + 40 pointerCentre + 25; arrowHPosition + 36 pointerCentre + 31; arrowHPosition + 22 pointerCentre + 20],5);
    
            HideCursor; 
            Screen('Flip',window);
                  
        else
            pause(0.001);
        end
        if (GetSecs() > firstRespTime + maxResponseSecs)  %Timeout?
            break
        end
    end
   respEndTime = GetSecs();   
   respDuration = respEndTime - respStartTime;   %duration in seconds. 
   ClickTime(trial) = respEndTime - firstRespTime; %RT for 'click button'
   %TBD - save off the times.

   %Each trial loop  ends on a rest block. 
  
   Screen('DrawTexture', window, fixation_texture, [], []) 
   Screen('Flip',window);
   if(devMode == 1)   %If we are in dev mode only wait 1 second. 
       waitDuration = 1;
   else
      waitDuration =  maxRestSecs - respDuration;   
      if(waitDuration < 0 ) %sanity check. 
          waitDuration = 0;
      end
   end
   RestDuration(trial) = waitDuration;
   WaitSecs(waitDuration); %Use waitsecs, not pause. Pause can be interrupted.

 end
Screen('CloseAll');

loggedData = table(videoFiles,RPE,ResponseTime, ClickTime,RestDuration);
theName = strcat("Ratings",subject,".csv");
writetable(loggedData,theName);
%writematrix(RPE_ratings,theName,"WriteMode","append");
