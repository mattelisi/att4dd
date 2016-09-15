function cor = checkFix(scr, visual, const, fixPos)
%
%   Check fixation
%
%   Matteo Lisi, 2012
%

timeout = 2.00; % maximum fixation check time
tCorMin = 0.20; % minimum correct fixation time



cxm = fixPos(1);
cym = fixPos(2);

drawFixation(visual.fixCkCol+20,fixPos(1:2),scr,visual);
Screen('Flip', scr.main);

Eyelink('message', 'EVENT_FixationCheck');

tstart=GetSecs;
cor=0; corStart=0; tCor=0;
t=tstart;
while ((t-tstart) < timeout && tCor<=tCorMin)
    [x,y] = getCoord(scr, const);
    
    if sqrt(mean(x-cxm)^2+mean(y-cym)^2)<visual.fixCkRad
        cor = 1;
    else
        cor = 0;
    end

	if cor == 1 && corStart == 0
		tCorStart = GetSecs; 
		corStart = 1;
	elseif cor == 1 && corStart == 1
		tCor = GetSecs-tCorStart;
	else
		corStart = 0;
	end
	
	t=GetSecs;
end
Eyelink('command','draw_cross %d %d', cxm, cym);
