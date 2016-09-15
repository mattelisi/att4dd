%% high level function

click = false;
wheelMov = [];
while ~click
    [~,~,buttons] = GetMouse;
    wheelMov = [wheelMov,GetMouseWheel];
    if any(buttons)
        click = true;
    end
end


%% low level test

mousedices=GetMouseIndices;
numMice = length(mousedices);
if numMice == 0
    error('GetMouseWheel could not find any mice connected to your computer');
end

allHidDevices=PsychHID('Devices');
for i=1:numMice
    b=allHidDevices(mousedices(i)).wheels;
    if ~IsOSX
        % On Non-OS/X we can't detect .wheels yet, so fake
        % 1 wheel for each detected mouse and hope for the best:
        b = 1;
    end
    
    if any(b > 0) && isempty(strfind(lower(allHidDevices(mousedices(i)).product), 'trackpad'))
        wheelMouseIndex = mousedices(i);
        break;
    end
end

mouseIndex = wheelMouseIndex;

% this will go on until a rotation of the wheel is detected
wheelDelta = 0;
while wheelDelta == 0
    rep = PsychHID('GetReport', mouseIndex, 1, 0, 10);
    while ~isempty(rep)
        wheely = rep(end);
        switch wheely
            case 1,
                wheelDelta = wheelDelta + 1;
            case 255,
                wheelDelta = wheelDelta - 1;
        end
        [rep, err] = PsychHID('GetReport', mouseIndex, 1, 0, 4);
        if err.n
            fprintf('GetMouseWheel: GetReport error 0x%s. %s: %s\n', hexstr(err.n), err.name, err.description);
        end
    end
    % WaitSecs(0.1); don't change anything..
end