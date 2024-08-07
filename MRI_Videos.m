%%MRI_Videos()
% AF note:  The next two lines are ok for development on my mac.
% Production code should pass the timing tests. 
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SkipSyncTests', 1)


Speed = randperm(4);

for i = 1:4
    while 1
        X = randperm(4);
        if (X(1) ~= Speed(end))
            break;
        end
    end  
    Speed = [Speed X];
end




KbName('UnifyKeyNames');

subject = input('Please enter a subject number ', 's');

% ***** WRITE DATA HEADING TO EXCEL FILE *****
writematrix(["FixationStart" "ClipStartTime" "ClipEndTime" "RPE" "RPE_EnterTime" "ButtonPressTime"],['Data/Subject' subject '.xls']);

% Setup key mapping:
space = KbName('SPACE');
esc = KbName('ESCAPE');
up = KbName('UpArrow');
down = KbName('DownArrow');
triggerKey = KbName('t');    %Scanner Trigger 
deviceIndex932 = []; %Consider using GetKeyboardIndices to identify the 932. 



% *** Show startup screen and wait for scanner trigger.  ***

try
    I = imread('startupScreen.bmp');
    screen = max(Screen('Screens'));
    [window, ~] = Screen('OpenWindow', screen, [0 0 0], [],32,2);
    our_texture = Screen('MakeTexture', window, I);
    Screen('DrawTexture', window, our_texture, [], []);
    HideCursor;
    Screen('Flip',window);

% Wait for the MRI Scanner trigger, a 't' keypress. Spacebar also works. 
    keysOfInterest=zeros(1,256);
    keysOfInterest(space) = 1;
    keysOfInterest(triggerKey)=1;
    KbQueueCreate(deviceIndex932, keysOfInterest);
    KbQueueStart(deviceIndex932);

    timeSecs = KbQueueWait(deviceIndex932);

    KbQueueRelease(deviceIndex932);
catch
  ListenChar(0);
  ShowCursor;
  psychrethrow(psychlasterror);
end





try

    trial = 1;

    while trial < 5
 
        switch subject
            case {"1","7","13","19"}
             pname =["HPK" "KW" "LEOINE"];
            case {"2","8","14","20"}
             pname =["HPK" "LEOINE" "KW"];
            case {"3","9","15","21"}
             pname = ["KW" "HPK" "LEOINE"];
            case {"4","10","16","22"}
             pname = ["KW" "LEOINE" "HPK"];
            case {"5","11","17","23"}
             pname = ["LEOINE" "HPK" "KW"];
            case {"6","12","18","24"}
             pname = ["LEOINE" "KW" "HPK"];
        end

        switch Speed(trial)
            case {1}
                speedname ='_8kph.mp4';
            case {2}
                speedname ='_10kph.mp4';
            case {3}
                speedname ='_12kph.mp4';
            case {4}
                speedname ='_14kph.mp4';
        end
        trial = trial + 1;
    
    %af Hard coding the path is not portable.
    %moviename = sprintf('%s%s%s', 'C:/Users/3D_User/Documents/MATLAB/MRI_Study/Videos/', pname(1), speedname);

        videosDirectory = strcat(pwd,'/Videos/'); 
        moviename = sprintf('%s%s%s',videosDirectory,pname(1),speedname);

    
        % Play video clip & return the start time of the video clip...
        [M2] = PlayMoviesDemo(moviename , 0, 0, 0, 4, -1, subject);
    
        % Get the time the clip finished, then add it to the Excel output!
        dt = datetime('now','TimeZone','local','Format','HH:mm:ss');
        M2 = [M2 string(dt)];

        [window, window_size] = Screen('OpenWindow', 0, [0 0 0], [],32,2);
    
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
    
        [keyIsDown, ~, keyCode] = KbCheck(-1);
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
    
        M2 = [M2 RPE];

        % Get the time the RPE was entered, then add it to the Excel output!
        dt = datetime('now','TimeZone','local','Format','HH:mm:ss');
        M2 = [M2 string(dt)];


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
  
                if (cursorVPosition > 535) && (cursorVPosition < 640)
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

        % Get the time the Button was clicked, then add time to the Excel output!
        dt = datetime('now','TimeZone','local','Format','HH:mm:ss');
        M2 = [M2 string(dt)];
            
        % ***** WRITE DATA TO EXCEL FILE *****
        writematrix(M2,['Data/Subject' subject '.xls'],'WriteMode','append');

    end
catch
  ListenChar(0);
  ShowCursor;
  psychrethrow(psychlasterror);
end
Screen('CloseAll');
