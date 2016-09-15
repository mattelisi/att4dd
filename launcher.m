%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Double-drift; attention task
%
% 4 stimuli; pre- vs post- cueing
%
% EYELINK
%
% Matteo Lisi, 2016
%

clear all;  clear mex;  clear functions;
addpath('functions/');

home;
tic;

% general parameters
const.TEST        = 1;      % 1 = test in dummy mode, 0 = test in eyelink mode
const.gammaLinear = 0;      % use monitor linearization
const.saveMovie   = 0;
const.nTrialMovie   = 10;

% const.gamma    = '../../gammaCalibration/EyelinkBoxcalData.mat';
% const.gammaRGB = '../../gammaCalibration/EyelinkBoxcalDataRGB.mat';

% participant ID
newFile = 0;

% fprintf(1,'\nPerceptual task, used to find perceived vertical (noise patches) (27/4/2016)\n');

while ~newFile
    [vpcode] = getVpCode;
    
    % create data file
    datFile = sprintf('%s.mat',vpcode);
    
    % dir names
    subDir=substr(vpcode, 0, 4);
    sessionDir=substr(vpcode, 5, 2);
    resdir=sprintf('data/%s/%s',subDir,sessionDir);
    
    if exist(resdir,'file')==7
        o = input('      This directory exists already. Should I continue/overwrite it [y / n]? ','s');
        if strcmp(o,'y')
            newFile = 1;
            % delete files to be overwritten?
            if exist([resdir,'/',datFile])>0;                    delete([resdir,'/',datFile]); end
            if exist([resdir,'/',sprintf('%s.edf',vpcode)])>0;   delete([resdir,'/',sprintf('%s.edf',vpcode)]); end
            if exist([resdir,'/',sprintf('%s',vpcode)])>0;       delete([resdir,'/',sprintf('%s',vpcode)]); end
        end
    else
        newFile = 1;
        mkdir(resdir);
    end
end

currentDir = cd;

% how many consecutive session?
nsess = 1; %getTaskInfo;

for sess = 1:nsess
    
    %if ~const.demo_static
        %cd(currentDir);
    
        % update session number e vpcode, create directory
        actualSess = str2double(sessionDir) + sess -1;
        actualSessStr = num2str(actualSess);
    
        if length(actualSessStr)==1
            actualSessStr = strcat('0',actualSessStr);
        end
    %else
    %    actualSess = 1;
    %end
    
    if sess > 1
        vpcode = sprintf('%s%s',subDir,actualSessStr);
    
        % create data file
        datFile = sprintf('%s.mat',vpcode);
    
        % dir names
        resdir=sprintf('data/%s/%s',subDir,actualSessStr);
    
        % control to avoid potential deleting of good data
        if exist(resdir,'file')==7
            o = input('      This directory exists already. Should I continue/overwrite it [y / n]? ','s');
            if strcmp(o,'y')
                newFile = 1;
                % delete files to be overwritten?
                if exist([resdir,'/',datFile])>0;                    delete([resdir,'/',datFile]); end
                if exist([resdir,'/',sprintf('%s.edf',vpcode)])>0;   delete([resdir,'/',sprintf('%s.edf',vpcode)]); end
                if exist([resdir,'/',sprintf('%s',vpcode)])>0;       delete([resdir,'/',sprintf('%s',vpcode)]); end
            end
        else
            newFile = 1;
            mkdir(resdir);
        end
    end
    
    % prepare screens
    scr = prepScreen(const);
    
    % generate design
    [design] = genDesign(scr, actualSess);
    
    % prepare stimuli
    visual = prepStim(scr, const, design);
    
    % prepare movie
    if const.saveMovie
        movieName = sprintf('%s.mp4',vpcode);
        % use GSstreamer
        Screen('Preference', 'DefaultVideocaptureEngine', 3)
        const.moviePtr = Screen('CreateMovie', scr.main, movieName, 1024, 768, 60, ':CodecSettings= EncodingQuality=1');
        visual.imageRect =  [(scr.centerX-512) (scr.centerY-384) (scr.centerX+512) (scr.centerY+384)];
    end
    
    as = mod(actualSess,design.totSession);
    if as==0; as=design.totSession; end
    
%     instrucyions screen
%     instructionsScreen = imread('instructionsScreen.bmp','BMP');
%     Screen('PutImage', scr.main, instructionsScreen);
%     Screen('Flip', scr.main);
%     SitNWait;

    % initialize eyelink-connection
    [el, err]=initEyelink(vpcode,visual,const,scr);
    if err==el.TERMINATE_KEY
        return
    end
    
    try
        % runtrials
        [design] = runTrials(design, vpcode,scr,visual,const, el);
    catch ERR_
        rethrow(ERR_);
    end
    
    % finalize
    if const.saveMovie
        Screen('FinalizeMovie', const.moviePtr);
    end
    
    % shut down everything
    reddUp;
    
    % save updated design information
    save(sprintf('%s.mat',vpcode),'design','visual','scr','const');
    
    % sposto i risultati nella cartella corrispondente
    movefile(datFile,resdir);
    movefile(vpcode,resdir);
    if ~const.TEST; movefile(sprintf('%s.edf',vpcode),resdir); end
    
    fprintf(1,'\nThis part of the experiment took %.0f min.',(toc)/60);
    fprintf(1,'\n\nOK!\n');
    
end



