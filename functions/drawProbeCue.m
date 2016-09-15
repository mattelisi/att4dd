function drawProbeCue(col,loc,scr,visual)
%
%

if length(loc)==2
    loc=[loc loc];
end
pu = round(visual.ppd*6);
Screen(scr.main,'FrameOval',col,loc+[-pu -pu pu pu],1);

