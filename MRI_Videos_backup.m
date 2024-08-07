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
%I = imread('startupScreen.bmp');

%our_texture = Screen('MakeTexture', window, I);

%Screen('FrameRect', window, [0 255 0],[700 300 900 500],5);

%Screen('DrawTexture', window, our_texture, [0 0 1280 1200], [320 0 1280+320 1200]);

%Screen('Flip',window);


% Play movie
moviename = 'C:/Users/3D_User/Documents/MATLAB/MRI_Study/Videos/Leoine-2B_default.mp4';
PlayMoviesDemo(moviename);

[window, window_size] = Screen('OpenWindow', 0, [0 0 0], [0 0 1920 1200],32,2);

I = imread('Borg.jpg');

our_texture = Screen('MakeTexture', window, I);

Screen('FrameRect', window, [0 255 0],[700 300 900 500],5);

Screen('DrawTexture', window, our_texture, [0 0 1280 1200], [320 0 1280+320 1200]);

Screen('Flip',window);

import java.awt.Robot;
mouse = Robot;
mouse.mouseMove(0, 0);
screenSize = get(0, 'screensize');
mouse.mouseMove(screenSize(3)/3,screenSize(4)/2 );


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

    rectangleStart = 73;
    if ((cursorVPosition > 50) && (cursorVPosition < (1200 - 65)))
        rectangleHeight = 74;
        cursorVOffset = 60;
        Screen('DrawTexture', window, our_texture, [0 0 1280 1200], [320 0 1280+320 1200]);
        Screen('FrameRect', window, [0 255 0],[350 rectangleStart + rectangleHeight *(round((cursorVPosition-cursorVOffset) / rectangleHeight)) - 40 1550 rectangleStart + rectangleHeight*(round((cursorVPosition-cursorVOffset) / rectangleHeight)) + 40],5);
        Screen('Flip',window);

        RPE = 6 + round((cursorVPosition - cursorVOffset) / rectangleHeight);
    else
        pause(0.001);
    end
    mouse.mouseMove(600, cursorVPosition);
end

%WaitSecs(3);
Screen('CloseAll');
