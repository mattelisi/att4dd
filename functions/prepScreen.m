function scr = prepScreen(const)
%
% apparent motion - saccade task v1
%
% Matteo Lisi, 2013
%

scr.subDist = 50;   % subject distance (cm) - 120 for projector
scr.colDept = 32;
scr.width   = 400;  % monitor width (mm) (435 desk monitor) - 1375 for projector

% If there are multiple displays guess that one without the menu bar is the best choice.  Dislay 0 has the menu bar.
scr.allScreens = Screen('Screens');
scr.expScreen  = max(scr.allScreens);

% get rid of PsychtoolBox Welcome screen
Screen('Preference','VisualDebugLevel',3);
% skip sync tests if testing code
if const.TEST == 1;
    Screen('Preference','SkipSyncTests', 1);
end

% set resolution
%if ~const.saveMovie;
%Screen('Resolution', scr.expScreen, 1024, 768);
%end

% Open a window.  Note the new argument to OpenWindow with value 2, specifying the number of buffers to the onscreen window.
imagingMode = kPsychNeed32BPCFloat;
[scr.main,scr.rect] = Screen('OpenWindow',scr.expScreen, [0.5 0.5 0.5],[],scr.colDept,2,0,2,imagingMode);

% get information about  screen
[scr.xres, scr.yres]    = Screen('WindowSize', scr.main);       % heigth and width of screen [pix]

% determine th main window's center
[scr.centerX, scr.centerY] = WindowCenter(scr.main);

% refresh duration
scr.fd = Screen('GetFlipInterval',scr.main);    % frame duration [s]

% Give the display a moment to recover from the change of display mode when
% opening a window. It takes some monitors and LCD scan converters a few seconds to resync.
WaitSecs(2);