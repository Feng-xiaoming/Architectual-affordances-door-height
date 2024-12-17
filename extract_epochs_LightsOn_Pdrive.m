%part0: P1N1_epoching_forAllSubjectsLoopAndDoorTypes
clear all; clc; 
addpath 'P:\Sheng_Wang\tools\toolboxes\eeglab_current\eeglab2021.1'
eeglab;

doortype = {'low', 'normal', 'high'};
subjects = [2];

% add another for loop that loops over go and nogo
for subject = subjects
    for door = doortype    
        % load the subject specific dataset
        EEG = pop_loadset('filename',['sub-' num2str(subject) '_cleaned_with_ICA.set'],'filepath',['P:\\Sheng_Wang\\exp2\\data\\5_single-subject-EEG-analysis\\sub-' num2str(subject) '\\']);
        EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',40,'plotfreqz',1);

        % take all the events
        events = {EEG.event.type};
        % find all the door events
        door_idcs = find(contains(events, ['doorType:' door{1}])); % modify this to also look for go or nogo
        % find all the light events
        light_idcs = find(contains(events, 'Lights:ON'));
        % find the first light event after every door event
        light_idcs = light_idcs(arrayfun(@(x) find(light_idcs > x,1), door_idcs)) ;
        % add new events for epoching
        EEG = eeg_addnewevents(EEG, {[EEG.event(light_idcs).latency]}, {[door{1} 'LightsOn']});

        % epoch the data at the previously created events
        epoched_EEG = pop_epoch( EEG, {[door{1} 'LightsOn']}, [-1 1]);
        epoched_EEG = pop_rmbase( epoched_EEG, [-200 0] ,[]);

        epoched_EEG = bemobil_reject_epochs(epoched_EEG,0.15,[1 1 1 1],0,0,0,0,1,1);  %epochs rejection

        % save the epoched EEG
        pop_saveset( epoched_EEG, 'filename',['sub' num2str(subject) '_practice_filtered_' door{1} '_Lights_ON_bad_epochs_removal.set'],'filepath','P:\\Sheng_Wang\\exp2\\data\\eeglab_practice\\epochs_LightsOn\\'); % save as pathway
        
        close all
    end
end