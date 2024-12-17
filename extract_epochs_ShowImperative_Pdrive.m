%sub_1_doorTpe_ShowImperative_epochs_rejection_by_all_events_names
clear all; clc; 
addpath 'P:\Sheng_Wang\tools\toolboxes\eeglab_current\eeglab2021.1'
eeglab;

subjects = [2,3,4,5];
doortype = {'low', 'normal', 'high'};
ShowImperative = {'Go','NoGo'};

% add another for loop that loops over go and nogo
for subject = subjects
    % load the subject specific dataset
    EEG = pop_loadset('filename',['sub-' num2str(subject) '_cleaned_with_ICA.set'],'filepath',['P:\\Sheng_Wang\\exp2\\data\\5_single-subject-EEG-analysis\\sub-' num2str(subject) '\\']);
    EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',40,'plotfreqz',1);
        
    for door = doortype  
        for Imperative = ShowImperative

        % take all the events
        events = {EEG.event.type};
        % find all the door events
        trial_idcs = find(contains(events, ['doorType:' door{1}]) & contains(events, ['imperative:' Imperative{1}])); % modify this to also look for go or nogo
        % find all the gonogo events
        stimulusOnset_idcs = find(contains(events, ['ShowImperative:' Imperative{1}])); % to look for go or nogo
        % find the first ShowImperative event after every door event
        stimulusOnset_idcs = stimulusOnset_idcs(arrayfun(@(x) find(stimulusOnset_idcs > x,1), trial_idcs)) ;

        % add new events for epoching
        EEG_newevent = eeg_addnewevents(EEG, {[EEG.event(stimulusOnset_idcs).latency]}, {[door{1} ,'Imperative{1}']}); %%maybe I have to unde

        % epoch the data at the previously created events
        epoched_EEG = pop_epoch( EEG_newevent, {[door{1} , 'Imperative{1}']}, [-0.5 1.5]);
        epoched_EEG = pop_rmbase( epoched_EEG, [-200 0] ,[]);

        epoched_EEG = bemobil_reject_epochs(epoched_EEG,0.15,[1 1 1 1],0,0,0,0,1,1);  %epochs rejection

        % save the epoched EEG
        pop_saveset( epoched_EEG, 'filename',['sub' num2str(subject) '_practice_filtered_' door{1} '_' Imperative{1} '_bad_epochs_removal.set'],'filepath','P:\\Sheng_Wang\\exp2\\data\\eeglab_practice\\epochs_ShowImperative\\'); % save as pathway
        
        close all
        end
    end
end