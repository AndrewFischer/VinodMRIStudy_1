% Turn off warning sign!
Screen('Preference','VisualDebugLevel', 0);

KbName('UnifyKeyNames');

subject = input('Please enter a subject number ', 's');

% Setup key mapping:
space=KbName('SPACE');
esc=KbName('ESCAPE');
right=KbName('RightArrow');
left=KbName('LeftArrow');
up=KbName('UpArrow');
down=KbName('DownArrow');
shift=KbName('RightShift');
colorPicker=KbName('c');

% Show start up screen
I = imread('startupScreen.bmp');

[window, ~] = Screen('OpenWindow', 0, [0 0 0], [],32,2);

our_texture = Screen('MakeTexture', window, I);

Screen('DrawTexture', window, our_texture, [], []);

Screen('Flip',window);

abortit = 0;
[keyIsDown, ~, keyCode] = KbCheck(-1);
while abortit == 0
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(space))
        abortit = 1;
    end
end

% Play movie
%moviename = 'C:/Users/3D_User/Documents/MATLAB/MRI_Study/Videos/Leoine-2B_default.mp4';
%PlayMoviesDemo(moviename);

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
btn_down = imread('button_down.bmp');

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
            Screen('DrawTexture', window, button_up_texture, [], []); 
            buttonDown = true;
        else
            Screen('DrawTexture', window, button_down_texture, [], []);
            buttonDown = false;
        end
        
        pointerCentre = cursorVPosition;

        Screen('FillPoly', window ,[255 0 0], [arrowHPosition pointerCentre; arrowHPosition + 35 pointerCentre + 10; arrowHPosition + 20 pointerCentre + 30],5);
        
        Screen('FillPoly', window ,[255 0 0], [arrowHPosition + 27 pointerCentre + 15; arrowHPosition + 40 pointerCentre + 25; arrowHPosition + 36 pointerCentre + 31; arrowHPosition + 22 pointerCentre + 20],5);

        Screen('Flip',window);

        RPE = 6 + round((cursorVPosition - cursorVOffset) / rectangleHeight);
    else
        pause(0.001);
    end
    mouse.mouseMove(600, cursorVPosition);
end
%WaitSecs(3);
Screen('CloseAll');
