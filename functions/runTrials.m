function [design] = runTrials(design, datFile, scr, visual, const, el)
%
% perpceptual task noise
% (no eyetracking here)
%
% - manual adjustments
%

% hide cursor 
HideCursor;

% preload important functions
% NOTE: adjusting timer with GetSecsTest
% has become superfluous in OSX
Screen(scr.main, 'Flip');
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% create data fid
datFid = fopen(datFile, 'w');

% unify keynames for different operating systems
KbName('UnifyKeyNames');

Eyelink('StartRecording');

% determine recorded eye
if ~isfield(const,'recEye') && ~const.TEST
    evt = Eyelink('newestfloatsample');
    const.recEye = find(evt.gx ~= -32768);
    % eye_used = Eyelink('EyeAvailable'); % get tracked eye 

end

% first calibration
if ~const.TEST
    calibresult = EyelinkDoTrackerSetup(el);
    if calibresult==el.TERMINATE_KEY
        return
    end
end

for b = 1:design.nBlocks
    block = design.blockOrder(b); 

    if isfield(design.b(b),'train')
        ntTrain = length(design.b(b).train);
        ntTrial = length(design.b(b).trial);
    else
        ntTrain = 0;
        ntTrial = length(design.b(b).trial);
    end
    ntt = ntTrain + ntTrial;

    
    % instructions
    systemFont = 'Arial'; % 'Courier';
    systemFontSize = 19;
    GeneralInstructions = ['Block ',num2str(b),' of ',num2str(design.nBlocks),'. \n\n',...
        'Press any key to begin.'];
    Screen('TextSize', scr.main, systemFontSize);
    Screen('TextFont', scr.main, systemFont);
    Screen('FillRect', scr.main, visual.bgColor);
    
    DrawFormattedText(scr.main, GeneralInstructions, 'center', 'center', visual.fgColor,70);
    Screen('Flip', scr.main);
    
    SitNWait;
    
    % test trials
    t = 0;
    while t < ntt
        
        t = t + 1;
        trialDone = 0;
        if t <= ntTrain
            trial = t;
            if trial == 1
            end
            td = design.b(b).train(trial);
        else
            trial = t-ntTrain;
            td = design.b(b).trial(trial);
        end

        % clean operator screen
        Eyelink('command','clear_screen');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Eyelink Stuff
        if trial==1	|| ~mod(trial,design.nTrlsBreak)        % calibration
            strDisplay(sprintf('%i out of %i trials finished. Press any key to continue',trial-1,ntt),scr.centerX, scr.centerY,scr,visual);
            SitNWait;
            if ~const.TEST
                calibresult = EyelinkDoTrackerSetup(el);
                if calibresult==el.TERMINATE_KEY
                    return
                end
            end
        end

        if ~const.TEST
            if Eyelink('isconnected')==el.notconnected		% cancel if eyeLink is not connected
                return
            end
        end

        % This supplies a title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message ''Block %d of %d, Trial %d of %d''', b, design.nBlocks, trial, ntt-ntTrain);
        % this marks the start of the trial
        Eyelink('message', 'TRIALID %d', trial);

        ncheck = 0;
        fix    = 0;
        record = 0;
        while fix~=1 || ~record
            if ~record
                Eyelink('startrecording');	% start recording
                % You should always start recording 50-100 msec before required
                % otherwise you may lose a few msec of data
                WaitSecs(.1);
                if ~const.TEST
                    key=1;
                    while key~= 0
                        key = EyelinkGetKey(el);		% dump any pending local keys
                    end
                end

                err=Eyelink('checkrecording'); 	% check recording status
                if err==0
                    record = 1;
                    Eyelink('message', 'RECORD_START');
                else
                    record = 0;	% results in repetition of fixation check
                    Eyelink('message', 'RECORD_FAILURE');
                end
            end

            if fix~=1 && record
                
                Eyelink('command','clear_screen 0');
                cleanScr;
                WaitSecs(0.1);
                
                % CHECK FIXATION
                fix = checkFix(scr, visual, const, td.fixLoc);
                ncheck = ncheck + 1;
            end

            if fix~=1 && record
                % calibration, if maxCheck drift corrections did not succeed
                if ~const.TEST
                    calibresult = EyelinkDoTrackerSetup(el);
                    if calibresult==el.TERMINATE_KEY
                        return
                    end
                end
                record = 0;
            end
        end

        Eyelink('message', 'TRIAL_START %d', trial);
        Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW
        
% %         %%
% %         if trial==1	|| ~mod(trial,design.nTrlsBreak)        % 
% %             strDisplay(sprintf('%i out of %i trials finished. Press any key to continue',trial-1,ntt),scr.centerX, scr.centerY,scr,visual);
% %             Screen('Flip', scr.main);
% %             SitNWait;
% %         end
% % 
% %         %
% %         drawFixation(visual.fixCkCol,td.fixLoc,scr,visual);
% %         Screen('Flip', scr.main);
% %         WaitSecs(0.5);
        
        %% RUN SINGLE TRIAL
        
        [data] = runSingleTrial(td, scr, visual, const, design);
        dataStr = sprintf('%i\t%i\t%s\n',b,trial,data); % print data to string
        fprintf(1,dataStr);

        % go to next trial if fixation was not broken
        if strcmp(data,'fixBreak')
            trialDone = 0;
            feedback('Please maintain your gaze on the central fixation point.',td.fixLoc(1),td.fixLoc(2),scr,visual);
        else
            trialDone = 1;
            fprintf(datFid,dataStr);                    % write data to datFile
         
        end

        fprintf(1,'\nTrial %i done',t-ntTrain);

        if ~trialDone && (t-ntTrain)>0
            ntn = length(design.b(b).trial)+1;  % new trial number
            design.b(b).trial(ntn) = td;        % add trial at the end of the block
            ntt = ntt+1;

            fprintf(1,' ... trial added, now total of %i trials',ntt);
        end
        WaitSecs(design.iti);
        
        
        %% count trials for movie (if required)
        if const.saveMovie
            if trial > const.nTrialMovie
                return
            end
        end
        
    end
end

fclose(datFid); % close datFile

% end eye-movement recording
if ~const.TEST
    Screen(el.window,'FillRect',el.backgroundcolour);   % hide display
    Waitsecs(0.1);Eyelink('stoprecording');             % record additional 100 msec of data
end

Screen('FillRect', scr.main,visual.bgColor);
Screen(scr.main,'DrawText','Thanks, you have finished this part of the experiment.',100,100,visual.fgColor);
Screen(scr.main,'Flip');

Eyelink('command','clear_screen');
Eyelink('command', 'record_status_message ''ENDE''');

ShowCursor;

WaitSecs(1);
cleanScr;
