% Turn off warning sign!

%two pieces of data output you'll want are as follows
% RPE_Ratings (should give you the RPES according to each video
% Shuffled Videos - this should give you the order the videos were played
% in.

%clear variables before starting script
clear all, close all, clc 

Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SkipSyncTests', 1) % from Joe - delete

KbName('UnifyKeyNames');

subject = input('Please enter a subject number ', 's');

% Operationalise variables


% Setup key mapping:
space = KbName('SPACE');
esc = KbName('ESCAPE');
up = KbName('UpArrow');
down = KbName('DownArrow');


% Define the path to the "Videos" folder
folderPath = fullfile(pwd, 'Videos');  % 'pwd' returns the current folder path




% Get the list of all .mp4 files in the "Videos" folder and shuffle them
fileList = dir(fullfile(folderPath, '*.mp4'));

% Extract the names and store them in a cell array
videoFiles = {fileList.name};     

% Shuffle the video files
shuffledOrder = randperm(length(videoFiles));  

% create new variable with shuffled videls
shuffledVideos = videoFiles(shuffledOrder); 




% *** SHOW START UP SCREEN AND WAIT FOR SPACEBAR TO BE PRESSED ***

I = imread('startupScreen.bmp');

% *** [window, ~] = Screen('OpenWindow', 0, [0 0 0], [],32,2);
[window, ~] = Screen('OpenWindow', 0, [0 0 0], [],32,2);

our_texture = Screen('MakeTexture', window, I);

Screen('DrawTexture', window, our_texture, [], []);
        
HideCursor;
Screen('Flip',window);


% wait for space bar press
% AF this will not work reliably in the scanner. 
abortit = 0;
[keyIsDown, ~, keyCode] = KbCheck(-1);
while abortit == 0
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(space))
        abortit = 1;
    end
end
Screen('CloseAll'); % added me

%trial look
 for trial = 1:length(shuffledVideos) %this uses number of videos to define n trials
    HideCursor;

% Play movie

% Get the full path of the video file using trial no from shuffled videos
trialVideoFile = fullfile(folderPath, shuffledVideos{trial});


% Open a screen window
[window, ~] = Screen('OpenWindow', 0, [0 0 0]);  % Open screen with black background

% this opens the stuff to play the movie.
try
    % Open the movie file
    movie = Screen('OpenMovie', window, trialVideoFile);

    % Start playing the movie
    Screen('PlayMovie', movie, 1);

    % Playback loop - I don't understand why they can interupt the movie
    % with a button press?
    while ~KbCheck  % Play until a key is pressed
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
    disp('Error occurred while playing the movie:');
    disp(exception.message);
end

% Screen('CloseAll'); % added me


% play movie end

    HideCursor;

    I = imread('Borg.jpg');
    
    our_texture = Screen('MakeTexture', window, I);
    
    Screen('DrawTexture', window, our_texture, [], []);
    
    Screen('Flip',window);
    
    import java.awt.Robot;
    mouse = Robot;
    mouse.mouseMove(0, 0);
    screenSize = get(0, 'screensize');
    mouse.mouseMove(screenSize(3)/3,screenSize(4)/2 );
    
    
    % SELECT VALUE FROM RPE SCALE
    abortit = 0;
    cursorVPosition = 1200/2; % Half way up the screen
    
    [keyIsDown, ~, keyCode] = KbCheck(-1);   %AF  this will not work reliably in the scanner. 
    while abortit == 0
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown == 1 && keyCode(space))
            abortit = 1;
        end
        if (keyIsDown == 1 && keyCode(down) && (cursorVPosition < 1150))
            cursorVPosition = cursorVPosition + 5;
        end
        if (keyIsDown == 1 && keyCode(up) && (cursorVPosition > 40))
            cursorVPosition = cursorVPosition - 5;
        end
    
        % Draw pointers to show selection...
        rectangleStart = 73;
        if ((cursorVPosition > 50) && (cursorVPosition < (1200 - 65)))
            rectangleHeight = 74;
            cursorVOffset = 60;
            Screen('DrawTexture', window, our_texture, [], []);
            %Screen('FrameRect', window, [0 255 0],[350 rectangleStart + rectangleHeight *(round((cursorVPosition-cursorVOffset) / rectangleHeight)) - 40 1550 rectangleStart + rectangleHeight*(round((cursorVPosition-cursorVOffset) / rectangleHeight)) + 40],5);
            
            pointerCentre = rectangleStart + rectangleHeight *(round((cursorVPosition-cursorVOffset) / rectangleHeight));
            Screen('FillPoly', window ,[255 0 0], [340 pointerCentre - 30; 340 pointerCentre + 30; 390 pointerCentre],5);
            Screen('FillPoly', window ,[255 0 0], [940 pointerCentre - 30; 940 pointerCentre + 30; 890 pointerCentre],5);
    
            HideCursor;
    
            Screen('Flip',window);
    
            RPE = 6 + round((cursorVPosition - cursorVOffset) / rectangleHeight);
        else
            pause(0.001);
        end
        mouse.mouseMove(600, cursorVPosition);
    end
    pause(1);
    
    % SUBJECT MUST NOW CLICK A BUTTON
    
    btn_up = imread('button_up.bmp');
    btn_down = imread('button_down2.bmp');
    
    button_up_texture = Screen('MakeTexture', window, btn_up);
    button_down_texture = Screen('MakeTexture', window,btn_down);
    
    abortit = 0;
    cursorVPosition = 0;
    buttonDown = false;
    
    while ((cursorVPosition == 0) || ((cursorVPosition > 450) && (cursorVPosition < 750)))
        cursorVPosition = 100 + randi(1000); % Half way up the screen
    end
    
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    while abortit == 0
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown == 1 && keyCode(space) && (buttonDown == true))
            abortit = 1;
        end
        if (keyIsDown == 1 && keyCode(down) && (cursorVPosition < 1150))
            cursorVPosition = cursorVPosition + 5;
        end
        if (keyIsDown == 1 && keyCode(up) && (cursorVPosition > 40))
            cursorVPosition = cursorVPosition - 5;
        end
    
        % Draw pointers to show selection...
        rectangleStart = 73;
        arrowHPosition = 950;
    
        if ((cursorVPosition > 50) && (cursorVPosition < (1200 - 65)))
            rectangleHeight = 74;
            cursorVOffset = 60;
    
            if (cursorVPosition > 535) && (cursorVPosition < 900)
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
    
            RPE = 6 + round((cursorVPosition - cursorVOffset) / rectangleHeight);
        else
            pause(0.001);
        end
        mouse.mouseMove(600, cursorVPosition);
    end


   RPE_ratings(trial) = RPE;
   trial = trial + 1; % increase trial number
end

%WaitSecs(3);
Screen('CloseAll');
