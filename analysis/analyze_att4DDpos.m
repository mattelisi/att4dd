%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORT AND ANALYZE ATTENTION DOUBLE-DRIFT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HHH OCT 2016
%
% Process all subject data and save into workspaces for later analyses
% Run preliminary analyses and variable checks

clc; clear all; close all

% CREATE LIST OF ALL DIRECTORIES AND IDS
cd('txtfiles');
allFiles = dir;

% FROM FILE NAME, DETERMINE SUBJECT ID FROM FIRST 2 DIGITS, & SESSION NUMBER FROM LAST 2 DIGITs
idsTemp = {};
idTable = {};
for i = 1:length(allFiles);
    idsTemp{i} = (allFiles(i,1).name);
end

naR = strmatch('.', idsTemp); % identify and remove non folders
for i = 1:length(naR)
    idsTemp{1,naR(i)} = 0;
end

curr = 0;
for i = 1:length(idsTemp)
    if idsTemp{i}~=0
        curr = curr+1;
        idTable{curr} = idsTemp{i};
    else
    end
end
nfiles = length(idTable);
idTable = idTable'; % transpose to use unique

% give unique id numbers and version number
for i = 1:nfiles;  
    idTable{i,2} = idTable{i,1}(1:2); % subject id
    idTable{i,3} = idTable{i,1}(5:6); % subject session number
    idTable{i,4} = idTable{i,1}(3:4); % subject initials
end

% step through each folder and get data
bigD = {};
ids = cell2mat(idTable(:,2));
sess = cell2mat(idTable(:,3));
nSess = length(ids); % total number of sessions
idTxtAll = unique(idTable(:,1));
idSub = unique(idTable(:,2));

for thisSess = 1:nSess;
    
    thisID = idTxtAll(thisSess);
    idTxt = cell2mat(idTxtAll(thisSess));
    idTxt2 = cell2mat(idTable(thisSess,2));
    idNum = str2double(ids(thisSess,:))+100;
    sessNum = str2double(sess(thisSess,:));
    bigD{thisSess,1} = idNum;
    bigD{thisSess,2} = sessNum;
    
    % load data file
    txtdata = load(char(thisID));
    numTrials = size(txtdata,1);
    numCols = size(txtdata,2); % number of columns in data file
    D1 = zeros(numTrials,numCols+2); % number of columns must equal datafile +2
    D1(:,1) = idNum; % add column of id numbers
    D1(:,2) = sessNum; % add column of block numbers
    D1(:,3:numCols+2) = txtdata;
    bigD{thisSess,3} = D1;
    
    % load mat file
    cd('../matfiles');
    M1 = load(char(strcat(thisID,'.mat')));
    bigD{thisSess,4} = M1;
    cd('../txtfiles');
    
end
cd('..');

%%% PUT ALL DATA INTO ONE FILE FOR ANALYSES
nSess = size(bigD,1);
allD = [];
for i = 1:nSess
    temp = bigD{i,3};
    allD = vertcat(allD,temp);
end

%%% SAVE EVERYTHING
save('bigD', 'bigD');
save('idTable', 'idTable');
save('allD', 'allD');

% save as excel
csvwrite('allData.csv', allD)
% rcnt = size(allD,1); % number of rows in master data file
% excelDims = ['A2:AZ',num2str(rcnt+1)]; % range of cells in excel file - CHANGE COLUMN AS NEEDED
% sxl = xlswrite('allData.xls', trackLabels); % write labels to excel file
% sxl = xlswrite('allData.xls', allD,excelDims); % write data to excel file




%% %% %% %% %% %% %% %% %% %% %% %%   ANALYZE DATA AND MAKE SOME FIGURES    %% %% %% %% %% %% %% %% %% %% %%

%%% Load data and note labels
clear all; clc; close all;
load('allD.mat'); % load master data file
load('bigD.mat'); % load original data file      
load('idTable.mat'); % load ids
idTableLabels = {'filename','id','session','initials'};
bigDLabels = {'id','session','data_txt','data_mat'};
allDLabels = {'id','session','3=block','4=trial','5=alpha','6=env_speed','7=drift_speed','8=trajLength',...
    '9=cue','10=location','11=cond','12=alpha_1','13=alpha_2','14=alpha_3','15=alpha_4','16=ecc',...
    '17=c1','18=c2','19=c3','20=c4','21=xStart','22=yStart','23=xEnd','24=yEnd','25=xResp','26=yResp','27=tResp'};

%%% CREATE USEFUL VARIABLES
ids = unique(allD(:,1));
n = length(ids);
condAlpha = unique(allD(:,5));  % unique number of trajectory angles
condCue = unique(allD(:,9));    % 1=pre-1obj 2=post-4obj
condLoc = unique(allD(:,10));   % target trajectory quadrant location (NW NE SW SE)
condDD = unique(allD(:,11));    % direction of drift
condEcc = unique(allD(:,16));   % different eccentricity conditions

nAlpha = length(condAlpha);     % n of different trajectory angles
nEcc = length(condEcc);         % n of different eccentricities
numTotTr = size(allD,1);        % total number of trials collected

pxlDegree = 29.2483; % 29.2483 from visual.ppd = number of pixels equal to 1-dva

%%% COMPUTE THE ERROR ALONG EACH AXIS (Xprobe - Xresp, Yprobe - Yresp)
locData = zeros(numTotTr,5);
for i = 1:numTotTr
    locData(i,1) = allD(i,23) - allD(i,25); % x-error
    locData(i,2) = allD(i,24) - allD(i,26); % y-error
    distErr = pdist([allD(i,23),allD(i,24); allD(i,25),allD(i,26)]); % localization error = sqrt( ( ( allD(i,23)-allD(i,25) )^2 ) + ((allD(i,24) - allD(i,26))^2) )
    locData(i,3) = distErr; % absolute distance error
    locData(i,4) = 0; 
    locData(i,5) = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    SUMMARY CHARTS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                   
%%% CHECK NUMBER OF TRIALS PER SUBJECT
figure;
hold all;
[numEls]=grpstats(allD(:,5),allD(:,1),'numel');
plot((1:n)',numEls,'*');
set(gca,'xtick',1:n,'XTickLabel',ids); % label the x-axis
xlim([0.5 n+.5]);
ylim([0 1000]);
xlabel('Subject id')
ylabel('Number of trials completed')
title('Number of trials completed for each subject');
set(gcf,'color','w')
hold off;


%%% CHECK NUMBER OF TRIALS PER CONDITION
figure;
hold all;
for i=1:length(condCue)
    rows=find(allD(:,25)>0 & allD(:,26)>0 & allD(:,9)==condCue(i));
    [numEls]=grpstats(locData(rows,3),allD(rows,16),'numel');
    plot((1:nEcc)',numEls,'*-');
end
set(gca,'xtick',1:nEcc,'XTickLabel',condEcc); % label the x-axis
xlim([0.5 nEcc+.5]);
ylim([0 100]);
xlabel('Eccentricity')
ylabel('Number of trials completed')
title('Number of trials per condition');
lt = legend('1-object','4-object','Location','SW');
set(lt,'FontSize',14,'FontName','Arial');set(gcf,'color','w')
hold off;



%% % FIG 1. Localization error - ABSOLUTE ERROR by degree ecc
figure;
hold all
for i=1:length(condCue)
    rows=find(allD(:,25)>0 & allD(:,26)>0 & allD(:,9)==condCue(i));
    DS=grpstats(locData(rows,3),allD(rows,16), .05);
end

ylim([0 90]);
% ADD degree scale
[AX,H1,H2] = plotyy(0,0,0,0,'plot');
set(AX(1),'ylim',[0 140])
set(AX(2),'ylim',[0 140/pxlDegree])
ydeg = [0:20/pxlDegree:140/pxlDegree];
ydegLabel = str2num(num2str(ydeg, 2));
set(AX(1), 'xtick', [], 'YTick', [0:20:140],'YColor','k','FontSize',12,'FontName','Helvetica')
set(AX(2), 'xtick', [], 'YTick', ydeg,'YColor','k','YTickLabel',ydegLabel,'FontSize',12,'FontName','Helvetica')
set(get(AX(2),'YLabel'),'String','Degrees visual angle','FontSize',14,'Color','k','FontName','Helvetica')
xlim([.5 nEcc+.5]);
set(gca,'xtick',[1:nEcc],'XTickLabel',condEcc,'FontSize',14); % label the x-axis
xlabel('Eccentricity','FontSize',14,'FontName','Arial');
ylabel('Localization error (pixels)','FontSize',14,'FontName','Arial')
titleTxt=['Absolute localization error (n=',num2str(n),')'];
title(titleTxt);
lt = legend('1-object','4-object','Location','SW');
set(lt,'FontSize',14,'FontName','Arial');
set(gcf,'color','w')
hold off






%% SAVE FIGURES AS PNG (for draft papers and ppt)
cd('figures');
figure(1);saveas(gcf,'Fig1-subjectTrials.png');
figure(2);saveas(gcf,'Fig2-condTrials.png');
figure(3);saveas(gcf,'Fig3-locError.png');
% figure(4);saveas(gcf,'Fig4-percentTrialsCorrect.png');
% figure(5);saveas(gcf,'Fig5-locError.png');
% figure(6);saveas(gcf,'Fig6-ANOVA.png');
% figure(7);saveas(gcf,'Fig7-ANOVA.png');
% figure(8);saveas(gcf,'Fig8-ANOVA.png');
% figure(9);saveas(gcf,'Fig9-something.png');
cd('..');





%% SOME ANALYSES

% ANOVA on localization error
varNames = {'eccentricity', 'nTargets'};
[Pr,Tr,Statsr] = anovan(locData(:,3),[allD(:,16),allD(:,9)],'VarNames',varNames,'model','interaction');

%ANOVA on localization error: subject=random variable
varNames = {'subject','eccentricity', 'nTargets'};
[PrR,TrR,StatsrR] = anovan(locData(:,3),[allD(:,1),allD(:,16),allD(:,9)],'VarNames',varNames,'random',1,'model','interaction');


