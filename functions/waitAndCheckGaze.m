function ex_flag = waitAndCheckGaze(scr, visual, const, fixPos, dur)
%
% check if gaze position is maintained at 'fixPos'
% for a given duration 'dur'
%

startT = GetSecs;
ex_flag = 1;
cxm = fixPos(1);
cym = fixPos(2);
while GetSecs-startT<dur
    [x,y] = getCoord(scr, const);   % get eye position
    % check if fixation is maintained within a circular area
    if sqrt((mean(x)-cxm)^2+(mean(y)-cym)^2)>visual.fixCkRad
        ex_flag = 0;     % fixation break
        break;
    end
end
        