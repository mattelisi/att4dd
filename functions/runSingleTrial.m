function [data] = runSingleTrial(td, scr, visual, const, design)
%
% perceptual task - noise patches (no eyetracking here)
%
% td = trial design
%
% Matteo Lisi, 2016
% MODIFIED BY HHH OCT 2016 to collect a localization response


%% TRIAL PREP.

% clear keyboard buffer
FlushEvents('KeyDown');

if const.TEST == 1;
    ShowCursor('CrossHair');
end

% target coordinates
dist_x = round(visual.ppd*(cosd(design.locationAngle)*td.ecc));
dist_y = round(visual.ppd*(sind(design.locationAngle)*td.ecc));
visual.loc_1 = [scr.centerX scr.centerY] + [-dist_x -dist_y];
visual.loc_2 = [scr.centerX scr.centerY] + [dist_x -dist_y];
visual.loc_3 = [scr.centerX scr.centerY] + [-dist_x dist_y];
visual.loc_4 = [scr.centerX scr.centerY] + [dist_x dist_y];

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

% determine final location of the cued target (necessary to draw response line)
% fcXY = eval(['path_', num2str(td.location),'(end,1:2);'])
fcXYstart = rectAll(1:2,td.location,1) + round(visual.tarSize); % start XY of target trajectory
fcXY = rectAll(1:2,td.location,nFrames) + round(visual.tarSize); % end XY of target trajectory

% compute the equations for the reponse-line
% slope = (cym - fcXY(2)) / (fcXY(1) - cxm);
slope = (fcXY(2) - fcXYstart(2)) / (fcXY(1) - fcXYstart(1));
%intcpt = fcXYstart(2) - (slope * fcXYstart(1));
rnum = Randi(50);
ll = round(visual.respLL/2) + rnum;
m = -1/slope; % slope of orthogonal line

x_f = fcXY(1);
y_f = fcXY(2);
x_f1 = 0; % response tool start
y_f1 = 0; % response tool start
x_f2 = 0; % response tool finish
y_f2 = 0; % response tool finish
x_m = 0; % mouse appearance location
y_m = 0; % mouse appearance location

if td.alpha > 0
    switch td.location
        case 1
            x_f1 = x_f - ll; 
            y_f1 = y_f - abs(m*(ll));
            x_f2 = x_f + ll;
            y_f2 = y_f + abs(m*(ll));
            x_m = round(x_f2);
            y_m = round(y_f2);
        case 2
            x_f1 = x_f - ll;
            y_f1 = y_f + abs(m*(ll));
            x_f2 = x_f + ll;
            y_f2 = y_f - abs(m*(ll));
            x_m = round(x_f1);
            y_m = round(y_f1);
        case 3
            x_f1 = x_f - ll;
            y_f1 = y_f + abs(m*(ll));
            x_f2 = x_f + ll;
            y_f2 = y_f - abs(m*(ll));
            x_m = round(x_f2);
            y_m = round(y_f2);
        case 4
            x_f1 = x_f - ll;
            y_f1 = y_f - abs(m*(ll));
            x_f2 = x_f + ll;
            y_f2 = y_f + abs(m*(ll)); 
            x_m = round(x_f1);
            y_m = round(y_f1);
    end
elseif td.alpha < 0
    switch td.location
        case 1
            x_f1 = x_f - ll; 
            y_f1 = y_f + abs(m*(ll)); 
            x_f2 = x_f + ll;
            y_f2 = y_f - abs(m*(ll));
            x_m = round(x_f1);
            y_m = round(y_f1);
        case 2
            x_f1 = x_f - ll;
            y_f1 = y_f - abs(m*(ll));
            x_f2 = x_f + ll; 
            y_f2 = y_f + abs(m*(ll));
            x_m = round(x_f2);
            y_m = round(y_f2);
        case 3
            x_f1 = x_f - ll;
            y_f1 = y_f - abs(m*(ll));
            x_f2 = x_f + ll;
            y_f2 = y_f + abs(m*(ll));
            x_m = round(x_f1);
            y_m = round(y_f1);
        case 4
            x_f1 = x_f - ll;
            y_f1 = y_f + abs(m*(ll));
            x_f2 = x_f + ll;
            y_f2 = y_f - abs(m*(ll));
            x_m = round(x_f2);
            y_m = round(y_f2);
    end
else
            x_f1 = 1;
            y_f1 = 1;
            x_f2 = 1;
            y_f2 = 1;
            x_m = 1;
            y_m = 1;
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

tBeg = GetSecs;

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
    
%     drawRespTool3(scr, td.location, td.alpha, visual, fcXY, slope, x_m, y_m); % JUST FOR TESTING
%     Screen('DrawLine', scr.main, [1 0 0 ], fcXYstart(1), fcXYstart(2), fcXY(1), fcXY(2) , 3); % JUST FOR TESTING (trajectory line)
    
    tFlip = Screen('Flip', scr.main, tFlip + scr.fd);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
end
% WaitSecs(.5); % JUST FOR TESTING

if ex_fg~=2 % proceed to response only if fixation was not broken
    
    %% post cue --- REMOVE THIS (POST CUE WILL ONLY BE RESPONSE TOOL)
    if td.cue == 2 || 1
        drawCue(scr, design, td.location);
        drawFixation(visual.fixCol,td.fixLoc,scr,visual);
        Screen('Flip', scr.main);
        if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.cueDuration/scr.fd)); end
        WaitSecs(design.cueDurationPost);
    end
    
    % blank screen before response tool appears
    Screen('Flip', scr.main);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.isi/scr.fd)); end
    WaitSecs(design.isi);
    
    %% collect response
    
    % Change the blend function to draw an antialiased shape
    Screen('BlendFunction', scr.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
       
    % code for making direction arrow response
    %point = rand*2*pi;
    %lastPoint = deg2rad(GetMouseWheel)+point;
    %[mx ,my] = pol2cart(point,1);
    %[px ,py] = pol2cart(point,60);
    %[sx ,sy] = pol2cart(point,-60);
    %drawArrow([sx+cxm(1) -sy+cym(1)],[px+cxm(1) ,-py+cym(1)],20,scr,60,4);
    %drawProbeCue(60,cuedXY,scr,visual);
    %drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual);
    %SetMouse(round(scr.centerX+visual.ppd*mx), round(scr.centerY-visual.ppd*my), scr.main); % set mouse
    SetMouse(x_m, y_m, scr.main); % set mouse
   
    if const.TEST == 0;
        HideCursor;
    end
 
    tHClk = Screen('Flip',scr.main);
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
    click = false;
        
    % RESPONSE SCREEN draw line through x-endpoint of target trajectory (observer adjusts perceived y-endpoint)
    % Screen('DrawLine', scr.main, [1 0 0], cxm, cym, cuedXY(1), cuedXY(2), 2);
    drawRespTool3(scr, td.location, td.alpha, visual, fcXY, slope, x_m, y_m, rnum); % RESPONSE TOOL ORTHOGONAL
    
    while ~click
        [mx,my,buttons] = GetMouse(scr.main);
        %[lastPoint,~] = cart2pol(mx-scr.centerX, scr.centerY-my);
        %[~,~,buttons] = GetMouse(scr.main);
        %lastPoint = deg2rad(GetMouseWheel)+lastPoint;
        %[px ,py] = pol2cart(lastPoint,60);
        %[sx ,sy] = pol2cart(lastPoint,-60);
        %drawArrow([sx+cxm(1) -sy+cym(1)],[px+cxm(1) ,-py+cym(1)],20,scr,60,4);
        %drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual);
        
        % ADD RESPONSE TOOL (SLIDER TO MARK LOCATION)
        [xResp, yResp] = drawRespTool3(scr, td.location, td.alpha, visual, fcXY, slope, mx, my, rnum); % RESPONSE SLIDER TOOL ORTHOGONAL
        %[xResp, yResp] = drawRespTool2(scr, td.location, visual, fcXY, slope, mx, my); % RESPONSE SLIDER TOOL HORIZONTAL
        
        lastPoint = [xResp, yResp];
        
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

tEnd = GetSecs;

switch ex_fg
    
    case 2
        data = 'fixBreak';
        
    case 1
        
        WaitSecs(0.2);
        if const.saveMovie; Screen('AddFrameToMovie',scr.main,visual.imageRect,'frontBuffer',const.moviePtr,round(0.2/scr.fd)); end
        
        % collect trial information
        trialData = sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%i\t%i\t%i\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f',...
            [td.alpha td.env_speed td.drift_speed td.trajLength td.cue td.location td.cond td.alpha_1 td.alpha_2 td.alpha_3 td.alpha_4 td.ecc]);
        
        % determine presentation times relative to 1st frame of motion
        timeData = sprintf('%i\t%i\t%i\t%i\t%i',round(1000*([tFix tBeg tResp tEnd]-tBeg)));
        
        % determine response data
        respData = sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%i\t%.2f\t%.2f\t%.2f\t%.2f',...
            fcXYstart,fcXY,resp,round(1000*(tResp - tHClk)),x_f1,y_f1,x_f2,y_f2);
        
        % collect data for tab [6 x trialData, 5 x timeData, 1 x respData]
        data = sprintf('%s\t%s\t%s',trialData, timeData, respData);
        
end

% close active textures
Screen('Close', motionTex(:));
WaitSecs(0.2);
