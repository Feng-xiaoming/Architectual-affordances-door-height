
% initialize EEGLAB
if ~exist('ALLEEG','var')
    eeglab;
end

% initialize FieldTrip
ft_defaults

% load configuration
affordancesDoorHeight_bemobil_config;

% enter all subjects to process here (you can split it up in more MATLAB instances if you have more CPU power and RAM)
subjects = [2];

% set to 1 if all files should be computed, independently of whether they are present on disk or not
force_recompute = 0;

%% processing loop

for subject = subjects
    
    %% prepare filepaths and check if already done
    disp(['Subject number ' num2str(subject)]);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = [];  CURRENTSET=[]; EEG=[]; EEG_interp_avref = []; EEG_single_subject_final = [];
    
    input_filepath = [bemobil_config.study_folder bemobil_config.raw_EEGLAB_data_folder bemobil_config.filename_prefix num2str(subject)];
    output_filepath = [bemobil_config.study_folder bemobil_config.single_subject_analysis_folder bemobil_config.filename_prefix num2str(subject)];
    
    try
        % load completely processed file
        EEG_single_subject_final = pop_loadset('filename', [ bemobil_config.filename_prefix num2str(subject)...
            '_' bemobil_config.single_subject_cleaned_ICA_filename], 'filepath', output_filepath);
    catch
        disp('...failed. Computing now.')
    end
    
    if ~force_recompute && exist('EEG_single_subject_final','var') && ~isempty(EEG_single_subject_final)
        clear EEG_single_subject_final
        disp('Subject is completely preprocessed already.')
        continue
    end
    
    %% load data that is provided by the BIDS importer
    % make sure the data is stored in double precision, large datafiles are supported, and no memory mapped objects are
    % used but data is processed locally
    try
        pop_editoptions( 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0);
    catch
        warning('Could NOT edit EEGLAB memory options!!');
    end
    
    % load files that were created from xdf to BIDS to EEGLAB
    EEG = pop_loadset('filename',[ bemobil_config.filename_prefix num2str(subject) '_' bemobil_config.merged_filename],'filepath',input_filepath);
    
    %% individual EEG processing to remove non-exp segments
    % it is stongly recommended to remove these because they may contain strong artifacts that confuse channel detection
    % and AMICA
    %% individual EEG processing to remove non-exp segments and correct marker errors + insert new markers for epoching
    
    
    
    
    
    % get event list and latency list from files
    allEvents = {EEG.event.type}';
    allLatencies = {EEG.event.latency}';
    
    % find the events for block starts
    % startevents = allEvents(find(cellfun('length',regexp(allEvents,'trial:start;trialNo:')) == 1));
    
    %% find the training start event
    target_training_start = regexp(allEvents,'training:start');
    find_index_target_training_start = find(cellfun('length',target_training_start)==1);
    startevents_training_start = allEvents(find_index_target_training_start);
    
    %% find the trainind end event
    target_training_end = regexp(allEvents,'training:end');
    find_index_target_training_end = find(cellfun('length',target_training_end)==1);
    endevents_training_end = allEvents(find_index_target_training_end);
    
    %% find the mandatoryBreak start event; 
    target_mandatoryBreak_start = regexp(allEvents,'mandatoryBreak:start');
    find_index_target_mandatoryBreak_start = find(cellfun('length',target_mandatoryBreak_start)==1);
    startevents_mandatoryBreak_start = allEvents(find_index_target_mandatoryBreak_start);
    
    %% find the mandatoryBreak end event; 
    target_mandatoryBreak_end = regexp(allEvents,'mandatoryBreak:end');
    find_index_target_mandatoryBreak_end = find(cellfun('length',target_mandatoryBreak_end)==1);
    endevents_mandatoryBreak_end = allEvents(find_index_target_mandatoryBreak_end);
    
    %% find the optionalBreak start event;
    target_optionalBreak_start = regexp(allEvents,'optionalBreak:start');
    find_index_target_optionalBreak_start = find(cellfun('length',target_optionalBreak_start)==1);
    startevents_optionalBreak_start = allEvents(find_index_target_optionalBreak_start);
    
    %% find the optionalBreak end event;
    target_optionalBreak_end = regexp(allEvents,'optionalBreak:end');
    find_index_target_optionalBreak_end = find(cellfun('length',target_optionalBreak_end)==1);
    endevents_optionalBreak_end = allEvents(find_index_target_optionalBreak_end);
    
    %% Find latency information for each index_start and index_end 
    startLatency_training_start = cell2mat(allLatencies(find_index_target_training_start));
    endLatency_training_end = cell2mat(allLatencies(find_index_target_training_end));
    startLatency_mandatoryBreak_start = cell2mat(allLatencies(find_index_target_mandatoryBreak_start));
    endLatency_mandatoryBreak_end  = cell2mat(allLatencies(find_index_target_mandatoryBreak_end));
    startLatency_optionalBreak_start = cell2mat(allLatencies(find_index_target_optionalBreak_start));
    endLatency_optionalBreak_end  = cell2mat(allLatencies(find_index_target_optionalBreak_end));
    
    %% start a new variable to contain the above three pairs of latency information, for the sake of the bellow function "eeg_eegrej"
    allStartLatency = [startLatency_training_start; startLatency_mandatoryBreak_start; startLatency_optionalBreak_start]
    allEndLatency = [endLatency_training_end; endLatency_mandatoryBreak_end; endLatency_optionalBreak_end]
    
    
%     % get latencies for those events
%     startlatencies = cell2mat(allLatencies(find(cellfun('length', regexp(allEvents,'trial:start;trialNo:')) == 1)));
%     target = regexp(allEvents,'trial:start;trialNo:');
%     
%     
%     % find the events for block ends
%     endevents = allEvents(find(cellfun('length', regexp(allEvents, 'trial:end;trialNo:')) == 1));
%     % get latencies for those events
%     endlatencies = cell2mat(allLatencies(find(cellfun('length', regexp(allEvents, 'trial:end;trialNo:')) == 1)));
%     % check if the training session was recorded and remove it if so
%     
%     % remove segments but leave a buffer of 1.5 sec before and after the events for timefreq analysis, and an additional 10 seconds for the end to allow epoching
%     latencies = [[1; endlatencies+10000] [startlatencies-1500; EEG.pnts]];
    
    EEG = eeg_eegrej(EEG, [allStartLatency, allEndLatency]);
    
    save('allevents.mat','allEvents')
    
    
    
    
    
    
    
    
    
    
    %% processing wrappers for basic processing and AMICA
    % do basic preprocessing, line noise removal, and channel interpolation
    [ALLEEG, EEG_preprocessed, CURRENTSET] = bemobil_process_all_EEG_preprocessing(subject, bemobil_config, ALLEEG, EEG, CURRENTSET, force_recompute);
    
    % start the processing pipeline for AMICA
    bemobil_process_all_AMICA(ALLEEG, EEG_preprocessed, CURRENTSET, subject, bemobil_config, force_recompute);
    
end

subjects
subject

disp('PROCESSING DONE! YOU CAN CLOSE THE WINDOW NOW!')
