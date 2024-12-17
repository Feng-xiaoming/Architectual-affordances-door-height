addpath 'P:\Sheng_Wang\tools\toolboxes\eeglab_current\eeglab2021.1'
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab to add bemobil pipeline to matlab path
addpath 'P:\Sheng_Wang\tools\toolboxes\eeglab_current\eeglab2021.1\plugins\bemobil-pipeline-master'

studyFolder                         = 'P:\Sheng_Wang\exp2\data\';

subjects = [2];

% names of the columns - 'nr' column is just the numerical IDs of subjects
%                         do not change the name of this column
subjectInfo.cols = {'nr',   'age',  'sex',  'handedness'};
subjectInfo.data = { 2,	    22,	   'M',	    'R'; ...
                    };

% general metadata shared across all modalities
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
generalInfo = [];

% required for dataset_description.json
generalInfo.dataset_description.Name                = 'EEG data set for a architectural affordances task';
generalInfo.dataset_description.BIDSVersion         = 'unofficial extension';

% optional for dataset_description.json
generalInfo.dataset_description.License             = 'n/a';
generalInfo.dataset_description.Authors             = {"Wang,S.", "Oliveira,G.S.", "Djebbara,Z", "Gramann, K."};
generalInfo.dataset_description.Acknowledgements    = 'n/a';
generalInfo.dataset_description.Funding             = {"China Scholarship Council"};
generalInfo.dataset_description.ReferencesAndLinks  = {"unpublished"};
generalInfo.dataset_description.DatasetDOI          = 'n/a';

% general information shared across modality specific json files 
generalInfo.InstitutionName                         = 'Technische Universitaet zu Berlin';
generalInfo.InstitutionalDepartmentName             = 'Biological Psychology and Neuroergonomics';
generalInfo.InstitutionAddress                      = 'Strasse des 17. Juni 135, 10623, Berlin, Germany';
generalInfo.TaskDescription                         = 'Participants immersed in 2d Unity rooms controled their walking by four arrow buttons.';
 

% information about the eeg recording system 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
eegInfo     = [];
eegInfo.coordsystem.EEGCoordinateSystem = 'Other'; 
eegInfo.coordsystem.EEGCoordinateUnits = 'mm'; 
eegInfo.coordsystem.EEGCoordinateSystemDescription = 'ALS with origin between ears, measured with Xensor.'; 


% participant information 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% here describe the fields in the participant file
% for numerical values  : 
%       subjectData.fields.[insert your field name here].Description    = 'describe what the field contains';
%       subjectData.fields.[insert your field name here].Unit           = 'write the unit of the quantity';
% for values with discrete levels :
%       subjectData.fields.[insert your field name here].Description    = 'describe what the field contains';
%       subjectData.fields.[insert your field name here].Levels.[insert the name of the first level] = 'describe what the level means';
%       subjectData.fields.[insert your field name here].Levels.[insert the name of the Nth level]   = 'describe what the level means';
%--------------------------------------------------------------------------
subjectInfo.fields.nr.Description       = 'numerical ID of the participant'; 
subjectInfo.fields.age.Description      = 'age of the participant'; 
subjectInfo.fields.age.Unit             = 'years'; 
subjectInfo.fields.sex.Description      = 'sex of the participant'; 
subjectInfo.fields.sex.Levels.M         = 'male'; 
subjectInfo.fields.sex.Levels.F         = 'female'; 
subjectInfo.fields.handedness.Description    = 'handedness of the participant';
subjectInfo.fields.handedness.Levels.R       = 'right-handed';
subjectInfo.fields.handedness.Levels.L       = 'left-handed';



% loop over participants
for subject = subjects
    
    config                        = [];                                 % reset for each loop
    config.bids_target_folder     = 'P:\Sheng_Wang\exp2\data\1_BIDS-data'; % required
    config.filename               = fullfile(['P:\Sheng_Wang\exp2\data\0_source-data\sub_' num2str(subject) '\sub_' num2str(subject) '_affordances.xdf']); % required
    config.subject                = subject;                            % required
    config.overwrite              = 'on';
    
    config.eeg.stream_name        = 'EEGStream';                      % required
    
    bemobil_xdf2bids(config, ...
        'general_metadata', generalInfo,...
        'participant_metadata', subjectInfo,...
        'eeg_metadata', eegInfo);
    
    % configuration for bemobil bids2set
    %----------------------------------------------------------------------
    config.study_folder             = studyFolder;
    config.session_names            = 'affordance';
    config.raw_EEGLAB_data_folder   = '2_raw-EEGLAB';
    config.other_data_types         = {};
    
    bemobil_bids2set(config);
end
                
