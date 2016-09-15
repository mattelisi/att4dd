function [x,y] =getCoord(wPtr,const)
%
% collect real or mouse-simulated eye position data
%

if const.TEST
    [x,y]=GetMouse(wPtr.main); % gaze position simulate by mouse position
else
    evt = Eyelink('newestfloatsample');
    x = evt.gx(const.recEye);
    y = evt.gy(const.recEye);
    
    if isempty(x)
        x = -1;
        y = -1;
    end
end