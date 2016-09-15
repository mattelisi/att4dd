function drawArrow(start,head,headWidth,scr,color,lineWidth)
%
% draw a simple arrow from start (x,y) to head (x,y) with arrowhead placed
% at "head"
%
% headWidth is the width of the arrowhead (in pixels)
% lineDiwth (optional) is the line width
%
% Matteo Lisi, 2014
%

if nargin < 6
    lineWidth = 1;
end

ah = headWidth/2;

% x and y lengths
xl = (head(1) - start(1));
yl = (head(2) - start(2));
hy = (xl^2 + yl^2)^.5;

% calculate the cosine and sine
co =  xl / hy;
si =  yl / hy;

% compute arrowhead points for horizontal arrow, and rotate them
hp = [hy-ah, hy-ah; -0.8*ah, 0.8*ah];
hp = repmat(start',1,2) + [co,-si;si,co] * hp;

% faster, draw all lines at once
xy = [start(1),head(1),hp(1,1),head(1),hp(1,2),head(1);start(2),head(2),hp(2,1),head(2),hp(2,2),head(2)];
Screen('DrawLines', scr.main, xy, lineWidth, color, [], 1);

