function [xResp, yResp] = drawRespTool(scr, t, visual, fcXY, slope, objx, objy)
% draws a radial response line from central fixation to endpoint of trajectory
% t indicates which is the target quadrant, from 1 to 4 in clockwise order (NW NE SW SE)

% if nargin <4
%     ll = 1000;
%     respColor = [0 0 0];
% end
ll = visual.respLL;
respColor = visual.respColor;
x_f = fcXY(1);
y_f = fcXY(2);

switch t
    case 1
        x_f = fcXY(1) - ll;
        y_f = fcXY(2) - abs(ll * slope);
    case 2
        x_f = fcXY(1) + ll;
        y_f = fcXY(2) - abs(ll * slope);
    case 3
        x_f = fcXY(1) - ll;
        y_f = fcXY(2) + abs(ll * slope);
    case 4
        x_f = fcXY(1) + ll;
        y_f = fcXY(2) + abs(ll * slope);
end

% COMPUTE NEAREST POINT ON LIMITED VECTOR TO MOVE SLIDING DOT ACROSS
xp = linspace(scr.centerX, x_f, 1000);
yp = linspace(scr.centerY, y_f, 1000);

[~,idx] = min((xp-objx).^2 + (yp-objy).^2);

xResp = xp(idx);
yResp = yp(idx);

Screen('DrawLine', scr.main, respColor, scr.centerX, scr.centerY, x_f, y_f , 3);
Screen('DrawDots', scr.main, [xResp; yResp], round(visual.tarSize/3), visual.respColor);