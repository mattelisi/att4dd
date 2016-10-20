function [design] = genDesign(scr,as)
%
% infinite regress - 4dd pre vs post cueing
% 
% Matteo Lisi, 2016
% HHH, 2016 - modified code to add location response

ppd = va2pix(1,scr);

%% target parameters

% spatial
design.ecc = [8  10  12];     % eccentricity of the trajectory midpoint (degree of visual angle)
design.locationAngle = 40;       % angle of each target locations relative to the horizontla midline
design.tarFreq = 0.1;            % wavelength (sort of..) of the top noise functions
design.octaves = 3;              % number of noise layers
design.sigma = 0.2;              % sigma of the gaussian envelope (sigma = FWHM / 2.35)
design.constrast = 1;            % gabor's contrast [0 - 1]

% motion & temporal
design.envelope_speed = 10;      % degree/sec. (2.6*2)/1.8
design.drifting_speed = 8;       % (cycles of the carrier)/sec.
% design.control_speed = 1.5;      
design.trajectoryLength = 4;    % degree of visual angle

design.fixDur = 0.400;          % minimum fixation duration [s]
design.fixDuJ = 0.200;          % additional fixation duration jitter [s]
design.motionType = 'triangular';   % allowed: triangular, sinusoidal
design.cueDuration = 1;         % cue duration in sec
design.cueDurationPost = 0.200; % post cue duration in sec
design.isi = 0.2;               % target - cue interval in sec

% conditions 
design.conditions = [1 -1];      % -1=CW ; 1 CCW; 0=control
design.cue = [1 2];              % 1= pre-cue; 2=post-cue
design.location = [1 2 3 4];     % cued location [1 2 3 4] = [NW NE SW SE]
%design.alpha_values = 0:10:(360-10); % possible physical orientations values
design.alpha_values = [45 -45]; % possible physical orientations values alpha +-45? 

% method 
design.alpha_initial = [60];     % initial point of before adjustments
design.alpha_step = 1;

design.rep =  1; 
                                
%% other parameter
% design.fixoffset = ppd*[0, 0]; % from screen center
% design.fixJtStd = 0;

% task structure
design.nTrialsInBlock = 48; % 480? = length(design.ecc)*length(design.conditions)*length(design.cue)*length(design.location)*length(design.alpha_values)
design.nTrlsBreak = 2000;    % number of trials between breaks, within a block
design.iti = 0.2;
design.totSession = 1;

% timing
design.preRelease = scr.fd/3;           % must be half or less of the monitor refresh interval
design.fixDur = 0.400;                  % minimum fixation duration [s]
design.fixDuJ = 0.200;                  % additional fixation duration jitter [s]
design.maxRT  = 10;

%% trials list
t = 0;
for alpha = design.alpha_values
for tarFreq = design.tarFreq
for contrast = design.constrast
for sigma = design.sigma
for env_speed = design.envelope_speed
for drift_speed = design.drifting_speed
for cond = design.conditions
for trajLength = design.trajectoryLength
for ecc = design.ecc
for rep = 1:design.rep    
for cue = design.cue
for location = design.location
    
    t = t+1;
    
    % set trajectory orientations
    for p=1:4 % first assign random orientations (limiting angles for location response)
        if p == 1
            eval(['trial(t).alpha_',num2str(p),'= round(rand(1)*90);']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        elseif p == 2
            eval(['trial(t).alpha_',num2str(p),'= 180 - round(rand(1)*90);']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        elseif p == 3
            eval(['trial(t).alpha_',num2str(p),'= 360 - round(rand(1)*90);']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        elseif p == 4
            eval(['trial(t).alpha_',num2str(p),'= 180 + round(rand(1)*90);']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        end
    end
    for p=1:4 % then assign alpha for cued location based on quadrant (limiting angles for location response)
        if p == location && p == 1
            eval(['trial(t).alpha_',num2str(p),'= alpha;']);
            eval(['trial(t).cond_',num2str(p),'= cond;']);
        elseif p == location && p == 2
            eval(['trial(t).alpha_',num2str(p),'= 180 - alpha;']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        elseif p == location && p == 3
            eval(['trial(t).alpha_',num2str(p),'= 360 - alpha;']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        elseif p == location && p == 4
            eval(['trial(t).alpha_',num2str(p),'= 180 + alpha;']);
            eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
        end
    end
%     for p=1:4 % OLD CODE FOR TRAJECTORY ORIENTATIONS
%         if p==location
%             eval(['trial(t).alpha_',num2str(p),'= alpha;']);
%             eval(['trial(t).cond_',num2str(p),'= cond;']);
%         else
%             eval(['trial(t).alpha_',num2str(p),'= rand(1)*360;']);
%             eval(['trial(t).cond_',num2str(p),'= sign(randn(1));']);
%         end
%     end
      
    trial(t).alpha = alpha; % this is the orientation angle of the cued location
                            % the remaining orientations are extracted randomly each trial from U(0, 360)
    trial(t).cue = cue;
    trial(t).location = location;

    trial(t).tarFreq = tarFreq * ppd;    % in trial list the measures are in pixels
    trial(t).sigma = sigma * ppd;        % 
    
    trial(t).contrast = contrast;
    trial(t).env_speed = env_speed;
    trial(t).drift_speed = drift_speed;
    trial(t).trajLength = trajLength;
    %trial(t).initPos = initPos;
    trial(t).ecc = ecc; 
    %trial(t).ecc = design.ecc(1) + rand * (design.ecc(2)-design.ecc(1)); % TO SELECT ECC FROM A RANGE OF VALUES
    trial(t).cond = cond;

    trial(t).fixDur = round((design.fixDur + design.fixDuJ*rand)/scr.fd)*scr.fd;
    trial(t).fixLoc = [scr.centerX scr.centerY]; %+ design.fixoffset + round(randn(1,2)*design.fixJtStd*ppd);
    
end
end
end
end
end
end
end
end
end
end
end
end

design.totTrials = t;

% select trial for session
as = mod(as,design.totSession); 
if as==0; as=design.totSession; end

design.actualSession = as;

sessIndex = (repmat(1:design.totSession,1,ceil(design.totTrials/design.totSession)));
trial = trial(sessIndex==as);

% random order
r = randperm(length(trial));
trial = trial(r);

% generate blocks
design.nBlocks = 2;
design.b(1).trial = trial;
design.blockOrder = 1;

design.nBlocks = length(trial)/design.nTrialsInBlock;
design.blockOrder = 1:design.nBlocks;

b=1; beginB=b; endB=design.nTrialsInBlock;

for i = 1:design.nBlocks
    design.b(i).trial = trial(beginB:endB);
    beginB  = beginB + design.nTrialsInBlock;
    endB    = endB   + design.nTrialsInBlock;
end

