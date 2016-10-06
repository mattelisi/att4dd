function [xResp, yResp] = drawRespTool3(scr, t, visual, fcXY, slope, objx, objy)
% draws a response line orthogonal to endpoint of trajectory
% t indicates which is the target quadrant, from 1 to 4 in clockwise order (NW NE SW SE)

x_f = fcXY(1);
y_f = fcXY(2);
x_f1 = 0;
y_f1 = 0;
x_f2 = 0;
y_f2 = 0;

% ll = round(visual.respLL);
respColor = visual.respColor;
% al = design.locationAngle;
m = -1/slope; % slope of orthogonal line

switch t
    case 1
        x_f1 = 0; % x_f - ll
        y_f1 = y_f - abs(m*x_f); % y_f - abs(m*ll)
        x_f2 = scr.centerX;
        y_f2 = y_f + abs(m*(scr.centerX - x_f));
    case 2
        x_f1 = scr.centerX;
        y_f1 = y_f + abs(m*(x_f - scr.centerX));
        x_f2 = x_f + abs(1/m*y_f); % x_f + ll
        y_f2 = 0; % y_f + (m*ll)
    case 3
        x_f1 = 0; % x_f - ll
        y_f1 = y_f + abs(m*x_f);
        x_f2 = scr.centerX;
        y_f2 = y_f - abs(m*(scr.centerX - x_f));
    case 4
        x_f1 = scr.centerX;
        y_f1 = y_f - abs(m*(x_f - scr.centerX));
        x_f2 = scr.xres; % x_f + ll
        y_f2 = y_f + abs(m*(scr.xres - x_f)); %y_f + abs(m*ll)
end

% COMPUTE NEAREST POINT ON LIMITED VECTOR TO MOVE SLIDING DOT ACROSS
xp = linspace(x_f1, x_f2, 1000);
yp = linspace(y_f1, y_f2, 1000);

[~,idx] = min((xp-objx).^2 + (yp-objy).^2);

xResp = xp(idx);
yResp = yp(idx);

Screen('DrawLine', scr.main, respColor, x_f1, y_f1, x_f2, y_f2 , 3);
Screen('DrawDots', scr.main, [xResp; yResp], round(visual.tarSize/3), visual.respColor);