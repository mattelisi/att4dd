function [xResp, yResp] = drawRespTool2(scr, t, visual, fcXY, slope, objx, objy)
% draws a response line from central meridian (vertical) to endpoint of trajectory
% t indicates which is the target quadrant, from 1 to 4 in clockwise order (NW NE SW SE)

ll = visual.respLL;
respColor = visual.respColor;
x_f = fcXY(1);
y_f = fcXY(2);

switch t
    case 1
        x_f = 0;
        y_f = fcXY(2);
    case 2
        x_f = scr.xres;
        y_f = fcXY(2);
    case 3
        x_f = 0;
        y_f = fcXY(2);
    case 4
        x_f = scr.xres;
        y_f = fcXY(2);
end

% COMPUTE NEAREST POINT ON LIMITED VECTOR TO MOVE SLIDING DOT ACROSS
xp = linspace(scr.centerX, x_f, ll);
yp = ones(1,ll)*y_f;

[~,idx] = min((xp-objx).^2 + (yp-objy).^2);

xResp = xp(idx);
yResp = yp(idx);

Screen('DrawLine', scr.main, respColor, scr.centerX, y_f, x_f, y_f , 3);
Screen('DrawDots', scr.main, [xResp; yResp], round(visual.tarSize/3), visual.respColor);