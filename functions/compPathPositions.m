function [tarPos, tarfra] = compPathPositions (angle,pathlength,speed,fd)

% compute trajectory

% old, for periodical stimulus
%timeIndex = linspace(0, 1, round(duration/scr.fd));
%tarRad = (pathlength/2) * sawtooth(2*pi*timeIndex, 0.5);  % target radius for each frame
%tarRad(end) = [];
%tarAng = repmat(deg2rad(90 + td.alpha), 1, length(tarRad));

duration = pathlength / speed;       % sec
tarRad = linspace(-pathlength/2, pathlength/2, round(duration/fd));
tarAng = repmat(deg2rad(angle), 1, length(tarRad));
[x, y] = pol2cart(tarAng, tarRad);  % x-y coord. of the envelope for each frame
tarPos = [x' -y'];

% number of frames for a single cycle
tarfra = length(tarRad);
