function drawCue(scr, design, t, ll)
% t indicate which is the target quadrant, from 1 to 4 in clockwise order
if nargin <4
    ll=40;
end
x_f = cosd(design.locationAngle);
y_f = sind(design.locationAngle);
switch t
    case 1
        x_f = scr.centerX -round(cosd(design.locationAngle)*ll);
        y_f = scr.centerY -round(sind(design.locationAngle)*ll);
    case 2
        x_f = scr.centerX +round(cosd(design.locationAngle)*ll);
        y_f = scr.centerY -round(sind(design.locationAngle)*ll);
    case 3
        x_f = scr.centerX -round(cosd(design.locationAngle)*ll);
        y_f = scr.centerY +round(sind(design.locationAngle)*ll);
    case 4
        x_f = scr.centerX +round(cosd(design.locationAngle)*ll);
        y_f = scr.centerY +round(sind(design.locationAngle)*ll);
end
Screen('DrawLine', scr.main, 0, scr.centerX, scr.centerY, x_f, y_f , 3);
