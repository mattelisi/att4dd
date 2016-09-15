function [data] = runSingleTrial(td, scr, visual, const, design)
%
% perceptual task - noise patches (no eyetracking here)
%
% td = trial design
%
% Matteo Lisi, 2016
% 


%% TRIAL PREP.

% clear keyboard buffer
FlushEvents('KeyDown');

HideCursor;

% targets trajectories
[path_1, nFrames] = compPathPositions(td.alpha_1, td.trajLength, td.env_speed, scr.fd);
path_2 = compPathPositions(td.alpha_2, td.trajLength, td.env_speed, scr.fd);
path_3 = compPathPositions(td.alpha_3, td.trajLength, td.env_speed, scr.fd);
path_4 = compPathPositions(td.alpha_4, td.trajLength, td.env_speed, scr.fd);

cxm = td.fixLoc(1);
cym = td.fixLoc(2);

% Set the blend function for drawing the patches
Screen('BlendFunction', scr.main, GL_ONE, GL_ZERO);

% generate noise images
noiseArray = generateNoiseImage(design,nFrames,visual,td, scr.fd);
for p = 1:3
    noiseArray = cat(3, noiseArray, generateNoiseImage(design,nFrames,visual,td, scr.fd));
end

% cut out textures for each frame
motionTex = zeros(4, nFrames);
for p = 1:4
    m = framesIllusion(design, visual, td, nFrames, noiseArray(:,:,p), scr.fd);
    for i=1:nFrames
        motionTex(p, i)=Screen('MakeTexture', scr.main, m(:,:,i));
    end
end

cuedXY = eval(['visual.loc_',num2str(td.location)]);

% rect coordinates for texture drawing
rectAll = zeros(4,4,nFrames);
for p = 1:4
    eval(['rectAll(:,p,:) = transpose(detRect(round(visual.ppd*path_',num2str(p),'(:,1)) + visual.loc_',num2str(p),'(1), round(visual.ppd*path_',num2str(p),'(:,2)) + visual.loc_',num2str(p),'(2), visual.tarSize));']);
end

% texture orientation angles
angles = 90-[td.alpha_1, td.alpha_2, td.alpha_3, td.alpha_4] -[td.cond_1*90, td.cond_2*90, td.cond_3*90, td.cond_4*90];

% predefine time stamps
tBeg    = NaN;
tResp   = NaN;
tEnd    = NaN;

% flags/counters
ex_fg = 0;      % 0 = ongoing; 1 = response OK; 2 = fix break; 3 = too slow

% draw fixation stimulus
drawFixation(visual.fixCol,td.fixLoc,scr,visual);
tFix = Screen('Flip', scr.main,0);

if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(td.fixDur/scr.fd)); 
end

% tFlip = tFix + td.fixDur;
WaitSecs(td.fixDur - 2*design.preRelease); 
Screen('Flip', scr.main);

%% cue
if td.cue == 1
    % pre cue
    drawCue(scr, design, td.location);
    drawFixation(visual.fixCol,td.fixLoc,scr,visual);
    Screen('Flip', scr.main);
    WaitSecs(design.cueDuration);
else
    % uninformative pre cue
    for i=1:4; drawCue(scr, design, i, 10); end
    drawFixation(visual.fixCol,td.fixLoc,scr,visual);
    Screen('Flip', scr.main);
    WaitSecs(design.cueDuration);
end
if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.cueDuration/scr.fd)); end

% blank
drawFixation(visual.fixCol,td.fixLoc,scr,visual);
tFlip = Screen('Flip', scr.main);
if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.isi/scr.fd)); end
tFlip = tFlip + design.isi;
WaitSecs(design.isi);


%% show stimuli
for i = 1:nFrames
    Screen('DrawTextures', scr.main, motionTex(:,i), [], squeeze(rectAll(:,:,i)), angles);
    drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual);
    
    [x,y] = getCoord(scr, const);   % eye position check
    
    % check if fixation is maintained
    if sqrt((mean(x)-cxm)^2+(mean(y)-cym)^2)>visual.fixCkRad    % check fixation in a circular area
        
        ex_fg = 2;     % fixation break
        
        % blank screen after fixation break
        drawFixation(visual.fixCol,td.fixLoc,scr,visual);
        Screen(scr.main,'Flip');
        break
        
    end
    
    tFlip = Screen('Flip', scr.main, tFlip + scr.fd);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
end

if ex_fg~=2 % proceed to response only if fixation was not broken
    
    %% post cue
     if td.cue == 2
         drawCue(scr, design, td.location);
         drawFixation(visual.fixCol,td.fixLoc,scr,visual);
         Screen('Flip', scr.main);
         if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.cueDuration/scr.fd)); end
         WaitSecs(design.cueDuration);
     end
    
    % blank
    Screen('Flip', scr.main);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.isi/scr.fd)); end
    WaitSecs(design.isi);
    
    %% collect response
    
    % Change the blend function to draw an antialiased shape
    Screen('BlendFunction', scr.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    point = rand*2*pi;
    %lastPoint = deg2rad(GetMouseWheel)+point;
    [mx ,my] = pol2cart(point,1);
    [px ,py] = pol2cart(point,60);
    [sx ,sy] = pol2cart(point,-60);
    drawArrow([sx+cxm(1) -sy+cym(1)],[px+cxm(1) ,-py+cym(1)],20,scr,60,4);
    %drawProbeCue(60,cuedXY,scr,visual);
    drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual);
    SetMouse(round(scr.centerX+visual.ppd*mx), round(scr.centerY-visual.ppd*my), scr.main); % set mouse
    HideCursor;
    tHClk = Screen('Flip',scr.main);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
    click = false;
    while ~click
        [mx,my,buttons] = GetMouse(scr.main);
        [lastPoint,~] = cart2pol(mx-scr.centerX, scr.centerY-my);
        %[~,~,buttons] = GetMouse(scr.main);
        %lastPoint = deg2rad(GetMouseWheel)+lastPoint;
        [px ,py] = pol2cart(lastPoint,60);
        [sx ,sy] = pol2cart(lastPoint,-60);
        drawArrow([sx+cxm(1) -sy+cym(1)],[px+cxm(1) ,-py+cym(1)],20,scr,60,4);
        drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual);
        %drawCue(scr, design, td.location, 10);
        %drawProbeCue(60,cuedXY,scr,visual);
        Screen('Flip',scr.main);
        if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
        if any(buttons)
            tResp = GetSecs; click = true; resp = lastPoint;
            %if const.TEST; fprintf(1,'\n RESPONSE ANGLE = %.2f \n',rad2deg(resp)); end % debug
        end
    end
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.4/scr.fd)); end
    Screen('Flip',scr.main);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(1/scr.fd)); end
    ex_fg = 1;
    
end

%% trial end

switch ex_fg
    
    case 2
        data = 'fixBreak';

    case 1
        
        WaitSecs(0.2);
        if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.2/scr.fd)); end

        % collect trial information
        trialData = sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%i\t%i\t%i\t%.2f\t%.2f\t%.2f\t%.2f',[td.alpha td.env_speed td.drift_speed td.trajLength td.cue td.location td.cond td.alpha_1 td.alpha_2 td.alpha_3 td.alpha_4]);
        
        % determine presentation times relative to 1st frame of motion
        timeData = sprintf('%i\t%i\t%i\t%i\t%i',round(1000*([tFix tBeg tResp tEnd]-tBeg)));
        
        % determine response data
        respData = sprintf('%.2f\t%i',resp, round(1000*(tResp - tHClk)));
        
        % collect data for tab [6 x trialData, 5 x timeData, 1 x respData]
        data = sprintf('%s\t%s\t%s',trialData, timeData, respData);
        
end


% close active textures
Screen('Close', motionTex(:));
WaitSecs(0.2);

