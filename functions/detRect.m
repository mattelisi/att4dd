function rect = detRect(x, y, size)
%
% squared rect of a given size (size) at a given position [x, y]
%
% Matteo Lisi, 2013
%

% rect = [left,top,right,bottom]

if ~iscolumn(x); x = x'; end
if ~iscolumn(y); y = y'; end
rect = [([x y] - size) ([x y]+size)];