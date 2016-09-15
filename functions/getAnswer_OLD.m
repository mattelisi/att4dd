%
% 'get answer' procedure
%
% return the angle in radians of the response (resp)
%
% Matteo Lisi 2013
%

% settings
distanceFromTarget = pi/4; % minimun distance from target position (tar) 
mouseWeight = scr.xres/2;

% display pointer at random position
not_set = true;
while not_set
    point = rand*2*pi;
    not_set = abs(point-tar) < distanceFromTarget;
end
drawPointer(point,scr,visual,design);
drawFixation(visual.white, visual.fgColor,visual.scrCenter,scr,visual);
Screen('Flip',scr.main);
% y = (scr.yres*point)/(2*pi);
SetMouse(scr.centerX, 1, scr.main); % set mouse
HideCursor;

% let the subjects adjust it until response
click = false;
xOLD = scr.centerX;
diff = 0;
while ~click
    
    [x,~,buttons] = GetMouse(scr.main);         HideCursor;
    diff = (2*pi*(x-xOLD))/mouseWeight;
    xOLD=x;
    point = point+diff;
  
    if x>3/4*scr.xres||x < 1/4*scr.xres 
        SetMouse(scr.centerX, 1, scr.main);     HideCursor;
        xOLD=scr.centerX;
    end
    
    if any(buttons)
        click = true;
        resp = mod(point,2*pi);
    end
    
    drawFixation(visual.white, visual.fgColor,visual.scrCenter,scr,visual);
    drawPointer(point,scr,visual,design);
    Screen('Flip',scr.main);
end

