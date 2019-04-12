1) Start a new match file with the 'New match file' button
2) Click "Add experiment" to load the Fall.mat file output by suite2p.
This will be the experiment that all others will be aligned to.
3) Click "Add experiment" to load the Fall.mat file from another
experiment which you expect to have the same cells in it.
4) When the control point selection tool opens click some matching cells
or other landmarks in the left (baseline experiment) and right
(experiment you are adding) windows.
5) Once you've clicked cells/landmarks which cover the whole field of
view close the control point selection tool.
6) You'll then see a comparison of the rois from the 2 sessions.
7) Repeat steps 3 - 5 to add all experiments where you want to
longitudinally track cells.
8) Set the ROI overlap threshold and click 'Auto detect' to find
potential matches over all experiments.
9) Click 'Show all' to show putative matches over all sessions.
10) Click validate and follow instructions in figure window to confirm
cell by cell that the cells which have been matched over the sessions
look the same as each other. 'ROI surround pixels' sets how much of the
field of view surrounding the roi is show to help check it is the same
cell.
11) Click 'Show valid' to show all of the cells you have visually
inspected.
12) Click 'Save match file' to save what you have done. The saved file
can be reloaded to work more on,
13) The same file an be loaded into matlab and has a field
'roiMatchData.allSessionMapping' which contains a matrix where rows are
longitudinally identified cells and columns are sessions/separate
experiments. 
14) The cell ID numbers in roiMatchData.allSessionMapping refer to the
cells output by suite2p which have been classified as valid in the
suite2p gui (found in Fall.iscell). i.e. cell ID number 8 in
roiMatchData.allSessionMapping is the 8th valid cell output by suite2p
