function [t] = PlayMoviesDemo(moviename, hdr, backgroundMaskOut, tolerance, pixelFormat, maxThreads, subject)

% This demo accepts a pattern for a valid moviename, e.g., moviename=`*.mpg`

theanswer = [];

esc=KbName('ESCAPE');
space=KbName('SPACE');

if nargin < 2 || isempty(hdr)
    hdr = 0;
end

% Initialize with unified keynames and normalized colorspace:
%PsychDefaultSetup(2);

try
    % Open onscreen window with black background:
    screen = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');

    % No special movieOptions by default:
    movieOptions = [];

    win = PsychImaging('OpenWindow', screen, [0, 0, 0]);
    %win = PsychImaging('OpenWindow', screen, 'AddTask', 'General' , 'UsePanelFitter' , [960 540],  'Aspect');
    [w, h] = Screen('WindowSize', win);


    %Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor(win);

    shader = [];

    % Use default pixelFormat if none specified:
    if nargin < 5
        pixelFormat = [];
    end

    % Use default maxThreads if none specified:
    if nargin < 6
        maxThreads = [];
    end

    % Initial display and sync to timestamp:
    Screen('Flip',win);
    iteration = 0;
    abortit = 0;

    % Use blocking wait for new frames by default:
    blocking = 1;

    % Default preload setting:
    preloadsecs = [];

    moviefiles(1).name = moviename;
    moviecount = 1;


    
    % Playbackrate defaults to 1:
    rate=1;

    % No mouse color prober/picker by default - Performance impact!
    colorprobe = 0;

    % Choose 16 pixel text size:
    Screen('TextSize', win, 32);

    % Endless loop, runs until ESC key pressed:
    %while (abortit<2)
        moviename = moviefiles(mod(iteration, moviecount)+1).name;
        iteration = iteration + 1;
        fprintf('ITER=%i::', iteration);

        % Show title while movie is loading/prerolling:
        %DrawFormattedText(win, ['Loading ...\n' moviename], 'center', 'center', 0, 40);
        Screen('Flip', win);

DrawFormattedText(win,'+','center','center',[255 255 255],[],[],[],[],[]);

HideCursor;
Screen('Flip',win);

% ***** RECORD THE TIME THAT THE FIXATION CROSS APPEARED *****
dt = datetime('now','TimeZone','local','Format','HH:mm:ss');
M1 = [string(dt)];

pause(4);
Screen('Close')

        % Open movie file and retrieve basic info about movie:
        [movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', win, moviename, [], preloadsecs, [], pixelFormat, maxThreads, movieOptions);
        %fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', moviename, movieduration, fps, imgw, imgh);

        dstRect = CenterRect((w / imgw) * [0, 0, imgw, imgh], Screen('Rect', win));

        i=0;

        % Start playback of movie. This will start
        % the realtime playback clock and playback of audio tracks, if any.
        % Play 'movie', at a playbackrate = 1, with endless loop=1 and
        % 1.0 == 100% audio volume.

% ***** RECORD TIME THAT THE VIDEO STARTED TO PLAY *****
dt = datetime('now','TimeZone','local','Format','HH:mm:ss');
M1 = [M1 string(dt)];

t = M1; % ***** RETURN THE TIME THAT THE VIDEO CLIP STARTED *****

        Screen('PlayMovie', movie, rate, 0, 1.0);

        t1 = GetSecs;

        % Infinite playback loop: Fetch video frames and display them...
        while 1
            % Check for abortion:
            abortit=0;
            [keyIsDown, ~, keyCode] = KbCheck(-1);
            if (keyIsDown==1 && keyCode(esc))
                % Set the abort-demo flag.
                abortit=2;
                break;
            end

            % Only perform video image fetch/drawing if playback is active
            % and the movie actually has a video track (imgw and imgh > 0):
            if ((abs(rate)>0) && (imgw>0) && (imgh>0))
                % Return next frame in movie, in sync with current playback
                % time and sound.
                % tex is either the positive texture handle or zero if no
                % new frame is ready yet in non-blocking mode (blocking == 0).
                % It is -1 if something went wrong and playback needs to be stopped:
                tex = Screen('GetMovieImage', win, movie, blocking);

                % Valid texture returned?
                if tex < 0
                    % No, and there won't be any in the future, due to some
                    % error. Abort playback loop:
                    break;
                end

                if tex == 0
                    % No new frame in polling wait (blocking == 0). Just sleep
                    % a bit and then retry.
                    WaitSecs('YieldSecs', 0.005);
                    continue;
                end

                % Draw the new texture immediately to screen:
                Screen('DrawTexture', win, tex, [], dstRect, [], [], [], [], shader);

                Screen('Flip', win, [], [], 1);

                % Release texture:
                Screen('Close', tex);
                
                % Framecounter:
                i=i+1;
                
            end

           
        end

        telapsed = GetSecs - t1;
        fprintf('Elapsed time %f seconds, for %i frames. Average framerate %f fps.\n', telapsed, i, i / telapsed);

        Screen('Flip', win);
        KbReleaseWait;

        % Done. Stop playback:
        Screen('PlayMovie', movie, 0);

        % Close movie object:
        Screen('CloseMovie', movie);
    %end

    % Show cursor again:
    %ShowCursor(win);

    % Close screens.
    %sca;

    % Done.
    return;
catch %#ok<*CTCH>
    % Error handling: Close all windows and movies, release all ressources.
    sca;
    rethrow(lasterror); %#ok<LERR>
end
