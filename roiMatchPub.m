function varargout = roiMatchPub(varargin)
% ROIMATCHPUB MATLAB code for roiMatchPub.fig
%      ROIMATCHPUB, by itself, creates a new ROIMATCHPUB or raises the existing
%      singleton*.
%
%      H = ROIMATCHPUB returns the handle to a new ROIMATCHPUB or the handle to
%      the existing singleton*.
%
%      ROIMATCHPUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIMATCHPUB.M with the given input arguments.
%
%      ROIMATCHPUB('Property','Value',...) creates a new ROIMATCHPUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roiMatchPub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roiMatchPub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roiMatchPub

% Last Modified by GUIDE v2.5 11-Apr-2019 17:33:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @roiMatchPub_OpeningFcn, ...
    'gui_OutputFcn',  @roiMatchPub_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before roiMatchPub is made visible.
function roiMatchPub_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roiMatchPub (see VARARGIN)

% Choose default command line output for roiMatchPub
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roiMatchPub wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global roiMatchGlobal;
% clear any current data
roiMatchGlobal.data = [];
roiMatchGlobal.data.rois = {};
roiMatchGlobal.data.mapping = [];
roiMatchGlobal.data.comparisonMatrix = [];
roiMatchGlobal.data.allRois = [];
updateGUI(handles)

function updateGUI(handles)
global roiMatchGlobal;
global dataGUIGlobal;
% update lists
set(handles.listROIs,'String',roiMatchGlobal.data.allRois)
set(handles.listROIs2,'String',roiMatchGlobal.data.allRois)


% --- Outputs from this function are returned to the command line.
function varargout = roiMatchPub_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnNew.
function btnNew_Callback(hObject, eventdata, handles)
% hObject    handle to btnNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global roiMatchGlobal;
% clear any current data
roiMatchGlobal.data = [];
roiMatchGlobal.data.rois = {};
roiMatchGlobal.data.mapping = [];
roiMatchGlobal.data.comparisonMatrix = [];
roiMatchGlobal.data.allRois = [];
updateGUI(handles)


% --- Executes on button press in btnAddFromDataBrowse.
function btnAddFromDataBrowse_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
[FileName,PathName] = uigetfile('*Fall*');
Fall = load(fullfile(PathName,FileName));
cd(PathName);
% load numpy file containing cell classification
cellValid = Fall.iscell(:,1);
% make masks of cells (for longitidinal tracking etc)
cellIDMap = zeros(size(Fall.ops.meanImg));
validCellList = find(cellValid(:,1)==1);
for iCell = 1:length(validCellList)
    cellID = validCellList(iCell);
    % roiPix = sub2ind(size(cellMask),Fall.stat{cellID}.ypix+int64(Fall.ops.yrange(1))-1,Fall.stat{cellID}.xpix+int64(Fall.ops.xrange(1))-1);
    roiPix = sub2ind(size(cellIDMap),Fall.stat{cellID}.ypix+1,Fall.stat{cellID}.xpix+1);
    cellIDMap(roiPix) = iCell;
end
figure;
meanFrame = Fall.ops.meanImg;
B = bwboundaries(cellIDMap);
imagesc(imadjust(int16(meanFrame)));
colormap gray;
hold on
visboundaries(B)

newRoiID = length(roiMatchGlobal.data.rois)+1;

roiMatchGlobal.data.allRois{newRoiID} = fullfile(PathName,FileName);
roiMatchGlobal.data.rois{newRoiID}.cellCount = sum(cellValid);
roiMatchGlobal.data.rois{newRoiID}.meanFrame = Fall.ops.meanImg;

% every experiment needs an associated matrix which defines if it has been
% compared to another experiment already
if ~isempty(roiMatchGlobal.data.comparisonMatrix)
    % add a row and a column and set intersect comparison to 1
    % row
    roiMatchGlobal.data.comparisonMatrix(end+1,:) = 0;  % [roiMatchGlobal.data.comparisonMatrix;zeros(1,size(roiMatchGlobal.data.comparisonMatrix,2)+1
    % column
    roiMatchGlobal.data.comparisonMatrix(:,end+1) = 0;  % [roiMatchGlobal.data.comparisonMatrix;zeros(1,size(roiMatchGlobal.data.comparisonMatrix,2)+1
    roiMatchGlobal.data.comparisonMatrix(end,end) = 1;
else
    roiMatchGlobal.data.comparisonMatrix = 1;
end

% if it's the first experiment then use it as the comparison point
if newRoiID == 1
    roiMatchGlobal.data.refImage = roiMatchGlobal.data.rois{newRoiID}.meanFrame;
    roiMatchGlobal.data.rois{newRoiID}.meanFrameRegistered = roiMatchGlobal.data.rois{newRoiID}.meanFrame;
    roiMatchGlobal.data.rois{newRoiID}.roiMapRegistered = cellIDMap;
else
    % register mean frame + roi map to reference
    moving = imadjusta(roiMatchGlobal.data.rois{newRoiID}.meanFrame);
    fixed = imadjusta(roiMatchGlobal.data.refImage);
    while(true)
    [moving_out,fixed_out] = cpselect(moving,fixed,'Wait',true);
    if size(moving_out,1)>6
        break
    else
        msgbox('Choose at least 6 control points');
    end
    end
    roiMatchGlobal.data.rois{newRoiID}.trans.moving_out = moving_out;
    roiMatchGlobal.data.rois{newRoiID}.trans.fixed_out  = fixed_out;
    t_concord = fitgeotrans(moving_out,fixed_out,'projective');
    ref = imref2d(size(fixed));
    roiMatchGlobal.data.rois{newRoiID}.meanFrameRegistered = imwarp(moving,t_concord,'OutputView',ref);
    roiMatchGlobal.data.rois{newRoiID}.roiMapRegistered = imwarp(cellIDMap,t_concord,'OutputView',ref,'Interp','nearest','SmoothEdges',false);
    figure;
    subplot(1,2,1);
    imagesc(imfuse(roiMatchGlobal.data.rois{newRoiID}.meanFrameRegistered,roiMatchGlobal.data.rois{1}.meanFrameRegistered));
    axis square;xticks([]);yticks([]);
    subplot(1,2,2);
    imagesc(imfuse(roiMatchGlobal.data.rois{newRoiID}.roiMapRegistered>0,roiMatchGlobal.data.rois{1}.roiMapRegistered>0));
    axis square;xticks([]);yticks([]);
end
updateGUI(handles)

% --- Executes on selection change in listROIs.
function listROIs_Callback(hObject, eventdata, handles)
% hObject    handle to listROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listROIs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listROIs


% --- Executes during object creation, after setting all properties.
function listROIs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listROIs2.
function listROIs2_Callback(hObject, eventdata, handles)
% hObject    handle to listROIs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listROIs2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listROIs2


% --- Executes during object creation, after setting all properties.
function listROIs2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listROIs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRemove.
function btnRemove_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
% load currently selected roi
currentAnimalID = handles.listROIs.Value;
expToKeep = setdiff(1:length(roiMatchGlobal.data.allRois),currentAnimalID);
roiMatchGlobal.data.rois = roiMatchGlobal.data.rois(expToKeep);
roiMatchGlobal.data.allRois = roiMatchGlobal.data.allRois(expToKeep);
roiMatchGlobal.data.comparisonMatrix = roiMatchGlobal.data.comparisonMatrix(expToKeep,expToKeep);
% update lists
updateGUI(handles);
handles.listROIs.Value = 1;
handles.listROIs2.Value = 1;


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
[FileName,PathName] = uiputfile('*.mat');
cd(PathName);
roiMatchData = roiMatchGlobal.data;
save(fullfile(PathName,FileName),'roiMatchData');

% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
[FileName,PathName] = uigetfile('*.mat');
cd(PathName);
load(fullfile(PathName,FileName));
roiMatchGlobal.data = roiMatchData;
updateGUI(handles);
handles.listROIs.Value = 1;
handles.listROIs2.Value = 1;

% --- Executes on button press in btnCompare.
function btnCompare_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
exp1 = handles.listROIs.Value;
exp2 = handles.listROIs2.Value;
figure;
subplot(2,2,1);
imagesc(imadjusta(roiMatchGlobal.data.rois{exp1}.meanFrameRegistered));
axis equal;xticks([]);yticks([]);
colormap gray
title('Experiment 1')
subplot(2,2,2);
imagesc(imadjusta(roiMatchGlobal.data.rois{exp2}.meanFrameRegistered));
axis equal;xticks([]);yticks([]);
title('Experiment 2')
subplot(2,2,3);
imagesc(imfuse(imadjusta(roiMatchGlobal.data.rois{exp1}.meanFrameRegistered),imadjusta(roiMatchGlobal.data.rois{exp2}.meanFrameRegistered)));
axis equal;xticks([]);yticks([]);
title('Fused images')
subplot(2,2,4);
imagesc(imfuse(roiMatchGlobal.data.rois{exp1}.roiMapRegistered>0,roiMatchGlobal.data.rois{exp2}.roiMapRegistered>0));
axis equal;xticks([]);yticks([]);
title('White = overlapping rois')

% --- Executes on button press in btnAuto.
function btnAuto_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
allPerms = nchoosek(1:length(roiMatchGlobal.data.rois),2);
allOverlaps = [];
overlapThreshold = str2num(handles.editOverlapThreshold.String);
roiMatchGlobal.data.mapping = zeros(1,length(roiMatchGlobal.data.rois));
% set all rois from all experiments as unanalysed
allCellCount = 0;
figure
tic
for iExp1 = 1:length(roiMatchGlobal.data.rois)
    exp1CellIDMap = roiMatchGlobal.data.rois{iExp1}.roiMapRegistered;
    roiMatchGlobal.data.rois{iExp1}.committed(1:roiMatchGlobal.data.rois{iExp1}.cellCount)=0;
    for iCell = 1:roiMatchGlobal.data.rois{iExp1}.cellCount
        allCellCount = allCellCount + 1;
        for iExp2 = setdiff(1:length(roiMatchGlobal.data.rois),iExp1)
            exp2CellIDMap = roiMatchGlobal.data.rois{iExp2}.roiMapRegistered;
            cellPix1 = find(exp1CellIDMap(:)==iCell);
            exp2PixVals = exp2CellIDMap(cellPix1);
            % find the most numerous pix value in exp2
            mostSimilarIdx = mode(exp2PixVals);
            if mostSimilarIdx~=0
                % find all pix of that roi
                cellPix2 = find(exp2CellIDMap(:)==mostSimilarIdx);
                % find proportion overlap as function of larger cell
                overlapFrac = length(intersect(cellPix1,cellPix2))/max([length(cellPix1),length(cellPix2)]);
                allOverlaps(end+1) = overlapFrac;
                % debug
                %imagesc(imfuse(exp1CellIDMap==iCell,exp2CellIDMap==mostSimilarIdx));
                % add it as a match
                if overlapFrac>=overlapThreshold
                    roiMatchGlobal.data.mapping(allCellCount,iExp1)=iCell;
                    roiMatchGlobal.data.mapping(allCellCount,iExp2)=mostSimilarIdx;
                end
            end
        end
        
    end
end
% check 'reuse' of cells
hist(allOverlaps);
% cycle through mappings committing each cell to a longitudinal group
roiMatchGlobal.data.allSessionMapping = [];
matchMap = zeros(size(roiMatchGlobal.data.refImage));
for iRow = 1:size(roiMatchGlobal.data.mapping,1)
    % check if cell is detected in all 3 sessions
    putativeMap = roiMatchGlobal.data.mapping(iRow,:);
    if sum(putativeMap~=0)==length(roiMatchGlobal.data.rois);
        % there's something at each time
        % check each cell is available
        avail = zeros(1,length(roiMatchGlobal.data.rois));
        for iExp = 1:length(roiMatchGlobal.data.rois)
            avail = roiMatchGlobal.data.rois{iExp}.committed(putativeMap(iExp));
        end
        if sum(avail) == 0
            % all cells available
            for iExp = 1:length(roiMatchGlobal.data.rois)
                roiMatchGlobal.data.rois{iExp}.committed(putativeMap(iExp)) = 1;
                matchPix = bwperim(roiMatchGlobal.data.rois{iExp}.roiMapRegistered==putativeMap(iExp));
                matchMap(matchPix==1)=iExp;
            end
            roiMatchGlobal.data.allSessionMapping(end+1,:) = putativeMap;
            % display outlines of the matches
            
        end
    end
end
imagesc(matchMap);colormap(hot);
disp(['Total longitudinal ROIs = ',num2str(size(roiMatchGlobal.data.allSessionMapping,1))]);
% display all rois longitudinally as images
compositeROIs = [];
for iRoi = 1:size(roiMatchGlobal.data.allSessionMapping,1)
    cellIDs = roiMatchGlobal.data.allSessionMapping(iRoi,:);
    roiColumn = [];
    for iExp = 1:length(roiMatchGlobal.data.rois)
        roiBounds = bwboundaries(roiMatchGlobal.data.rois{iExp}.roiMapRegistered==cellIDs(iExp));
        Top = min(roiBounds{1}(:,1));
        Bottom = max(roiBounds{1}(:,1));
        Left = min(roiBounds{1}(:,2));
        Right = max(roiBounds{1}(:,2));
        cellImage = imresize(roiMatchGlobal.data.rois{iExp}.meanFrameRegistered(Top:Bottom,Left:Right),[20 20]);
        cellImage = imadjusta(cellImage);
        roiColumn = [roiColumn;ones(1,20);cellImage];
    end
    compositeROIs = [compositeROIs,ones(size(roiColumn,1),1),roiColumn];
end
figure
imagesc(compositeROIs);
title(['Total longitudinal overlapping ROIs = ',num2str(size(roiMatchGlobal.data.allSessionMapping,1)),' (Pan across using hand tool)']);
axis equal;
box off;
colormap gray
ylim([1 size(compositeROIs,1)]);
xlim([1 210]);
axis equal;
axis off

toc;

function editOverlapThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editOverlapThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOverlapThreshold as text
%        str2double(get(hObject,'String')) returns contents of editOverlapThreshold as a double


% --- Executes during object creation, after setting all properties.
function editOverlapThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOverlapThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnValidate.
function btnValidate_Callback(hObject, eventdata, handles)
% display all rois longitudinally as images
global roiMatchGlobal;
surroundPix = str2num(handles.editSurroundPix.String);
compositeROIs = [];
resizedROISize = [100 100];
f = figure('units','normalized','outerposition',[0 0 0.5 1]);
for iRoi = 1:size(roiMatchGlobal.data.allSessionMapping,1)
    cellIDs = roiMatchGlobal.data.allSessionMapping(iRoi,:);
    roiColumn = [];
    roiColumnOutline = [];
    for iExp = 1:length(roiMatchGlobal.data.rois)
        roiBounds = bwboundaries(roiMatchGlobal.data.rois{iExp}.roiMapRegistered==cellIDs(iExp));
        imageSize = size(roiMatchGlobal.data.rois{iExp}.roiMapRegistered);
        Top = min(roiBounds{1}(:,1))-surroundPix;
        Bottom = max(roiBounds{1}(:,1))+surroundPix;
        Left = min(roiBounds{1}(:,2))-surroundPix;
        Right = max(roiBounds{1}(:,2))+surroundPix;
        % check if roi border is larger than image
        topPad = 0;
        bottomPad = 0;
        leftPad = 0;
        rightPad = 0;
        if Top < 1
            topPad = Top*-1;
            Top = 1;
        end
        if Bottom > imageSize(1)
            bottomPad = Bottom - imageSize(1);
            Bottom = imageSize(1);
        end
        if Left < 1
            leftPad = Left * -1;
            Left = 1;
        end
        if Right > imageSize(2)
            rightPad = Right - imageSize(2);
            Right = imageSize(2);
        end
        cellImageRaw = roiMatchGlobal.data.rois{iExp}.meanFrameRegistered(Top:Bottom,Left:Right);
        roiImageRaw = roiMatchGlobal.data.rois{iExp}.roiMapRegistered(Top:Bottom,Left:Right);
        
        % add padding if needed
        medVal = nanmedian(cellImageRaw(:));
        if topPad
            cellImageRaw = [nan(topPad,size(cellImageRaw,2));cellImageRaw];
            roiImageRaw = [nan(topPad,size(roiImageRaw,2));roiImageRaw];
        end
        if bottomPad
            cellImageRaw = [cellImageRaw;nan(bottomPad,size(cellImageRaw,2))];
            roiImageRaw = [roiImageRaw;nan(bottomPad,size(roiImageRaw,2))];
        end
        if leftPad
            cellImageRaw = [nan(size(cellImageRaw,1),leftPad),cellImageRaw];
            roiImageRaw = [nan(size(roiImageRaw,1),leftPad),roiImageRaw];
        end
        if rightPad
            cellImageRaw = [cellImageRaw,nan(size(cellImageRaw,1),rightPad)];
            roiImageRaw = [roiImageRaw,nan(size(roiImageRaw,1),rightPad)];
        end
        
        cellImageRaw(isnan(cellImageRaw(:)))=medVal;
        
        cellImage = imresize(cellImageRaw,resizedROISize);
        cellImage = imadjusta(cellImage);
        roiImage = imresize(roiImageRaw,resizedROISize,'nearest');
        matchPix = bwperim(roiImage==cellIDs(iExp));
        roiColumnOutline = [roiColumnOutline;zeros(1,resizedROISize(1));matchPix==1];
        roiColumn = [roiColumn;ones(1,resizedROISize(1));cellImage];
        
    end
    % display and confirm etc
    dispImage = repmat(roiColumn,[1,1,3]);
    outlineDisp = roiColumn;
    outlineDisp(roiColumnOutline==1) = 1;
    dispImage(:,:,1)=outlineDisp;
    imagesc(dispImage);
    axis equal;
    box off;
    colormap gray
    ylim([1 size(roiColumn,1)]);
    xlim([1 20]);
    axis equal;
    axis off
    title(['Keep (space) Discard (z) Stop (escape) (',num2str(iRoi),'/',num2str(size(roiMatchGlobal.data.allSessionMapping,1)),')']);
    while (f.isvalid)
        disp(['Keep (space) Discard (z) Stop (escape) (',num2str(iRoi),'/',num2str(size(roiMatchGlobal.data.allSessionMapping,1)),')']);
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        switch currkey
            case 'escape'
                f.delete;
                return;
            case 'space'
                roisToKeep(iRoi) = 1;
                break;
            case 'z'
                roisToKeep(iRoi) = 0;
                break;
            otherwise
                title(['Unknown key command - Keep (space) Discard (z) Stop (escape) (',num2str(iRoi),'/',num2str(size(roiMatchGlobal.data.allSessionMapping,1)),')']);
        end
    end      
end
if f.isvalid;f.delete;end;
roiMatchGlobal.data.allSessionMapping=roiMatchGlobal.data.allSessionMapping(logical(roisToKeep),:);
disp(['Total longitudinal ROIs = ',num2str(size(roiMatchGlobal.data.allSessionMapping,1))]);

% --- Executes on button press in btnShowAll.
function btnShowAll_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
compositeROIs = [];
for iRoi = 1:size(roiMatchGlobal.data.allSessionMapping,1)
    cellIDs = roiMatchGlobal.data.allSessionMapping(iRoi,:);
    roiColumn = [];
    for iExp = 1:length(roiMatchGlobal.data.rois)
        roiBounds = bwboundaries(roiMatchGlobal.data.rois{iExp}.roiMapRegistered==cellIDs(iExp));
        Top = min(roiBounds{1}(:,1));
        Bottom = max(roiBounds{1}(:,1));
        Left = min(roiBounds{1}(:,2));
        Right = max(roiBounds{1}(:,2));
        cellImage = imresize(roiMatchGlobal.data.rois{iExp}.meanFrameRegistered(Top:Bottom,Left:Right),[20 20]);
        cellImage = imadjusta(cellImage);
        roiColumn = [roiColumn;ones(1,20);cellImage];
    end
    compositeROIs = [compositeROIs,ones(size(roiColumn,1),1),roiColumn];
end
figure
imagesc(compositeROIs);
axis equal;
box off;
colormap gray
ylim([1 size(compositeROIs,1)]);
xlim([1 210]);
axis equal;
axis off
title(['Number of rois = ',num2str(size(roiMatchGlobal.data.allSessionMapping,1)),' - rows are experiments - pan with hand tool']);



function editSurroundPix_Callback(hObject, eventdata, handles)
% hObject    handle to editSurroundPix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSurroundPix as text
%        str2double(get(hObject,'String')) returns contents of editSurroundPix as a double


% --- Executes during object creation, after setting all properties.
function editSurroundPix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurroundPix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnShowValid.
function btnShowValid_Callback(hObject, eventdata, handles)
global roiMatchGlobal;
compositeROIs = [];
for iRoi = 1:size(roiMatchGlobal.data.allSessionMapping,1)
    
    cellIDs = roiMatchGlobal.data.allSessionMapping(iRoi,:);
    roiColumn = [];
    for iExp = 1:length(roiMatchGlobal.data.rois)
        roiBounds = bwboundaries(roiMatchGlobal.data.rois{iExp}.roiMapRegistered==cellIDs(iExp));
        Top = min(roiBounds{1}(:,1));
        Bottom = max(roiBounds{1}(:,1));
        Left = min(roiBounds{1}(:,2));
        Right = max(roiBounds{1}(:,2));
        cellImage = imresize(roiMatchGlobal.data.rois{iExp}.meanFrameRegistered(Top:Bottom,Left:Right),[20 20]);
        cellImage = imadjusta(cellImage);
        roiColumn = [roiColumn;ones(1,20);cellImage];
    end
    compositeROIs = [compositeROIs,ones(size(roiColumn,1),1),roiColumn];
end
figure
imagesc(compositeROIs);
axis equal;
box off;
colormap gray
ylim([1 size(compositeROIs,1)]);
xlim([1 210]);
axis equal;
axis off
title(['Number of rois = ',num2str(size(roiMatchGlobal.data.allSessionMapping,1))]);

function [I2] = imadjusta(I)
I2 = I - min(I(:));
I2 = I2/max(I2(:));
I2 = imadjust(I2);


% --- Executes on button press in btnHelp.
function btnHelp_Callback(hObject, eventdata, handles)
edit RoiMatchHelp.m;
