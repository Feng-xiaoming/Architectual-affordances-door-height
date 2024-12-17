clear all; clc; 
%% part1: data importing and to sqeeze EEG.data dimentions. 
 subjects = [2,3,4,5]; %% subject numbers
 doortype = {'low', 'normal', 'high'};
 allN140ValuesSmooth = [];
 allP260ValuesSmooth = [];
 
for subject = subjects
    for doorIdx = 1:3  
    setname = strcat(['sub' num2str(subject) '_practice_filtered_' doortype{doorIdx}  '_Lights_ON_bad_epochs_removal.set']); %% filename of set file
    setpath = 'P:\Sheng_Wang\exp2\data\eeglab_practice\epochs_LightsOn\'; %% filepath of set files 
    EEG = pop_loadset('filename',setname,'filepath',setpath); %% load the data
    EEG = eeg_checkset(EEG);
    EEG_avg(subject,:,:) = squeeze(mean(EEG.data,3)); %% EEG_avg dimension: channel*time*trial → subj*channel*time
    
    
    
    %%part2: select the specific channel and calculate group-level ERP at this specific electrode
    electrode = 16;   % select the specific channel
    % define peak latencies.
    searchN140Ante = 140;
    searchP260Ante = 260; 
    
    figure;
    mean_data = squeeze(EEG_avg(subject,electrode,:));  %% select the data according to the above selected electrode and the specific subject number 
    plot(EEG.times, mean_data,'k','linewidth', 1.5); %% plot the waveforms
    axis([-500 1000 -5 5]);  %% define the region to display
    title(['Group-level at the specific electrode' num2str(electrode), ' sub' num2str(subject), doortype{doorIdx}],'fontsize',16); %% specify the figure name
    xlabel('Latency (ms)','fontsize',16); %% name of X axis
    ylabel('Amplitude (uV)','fontsize',16);  %% name of Y axis

    
    
    %%part3: to detect and extract peaks amplitude within this study dataset
    y = mean_data; % signal and data
    t = EEG.times; % Time Vector
    t_window_N140 = [searchN140Ante-50, searchN140Ante+50]; %Time window for N132
    t_window_P260 = [searchP260Ante-50, searchP260Ante+50]; %Time window for P256
    
    idx_N140 = find((t>= t_window_N140(1)) & (t<=t_window_N140(2))); % Indices Corresponding To Time Window 
    idx_P260 = find((t>= t_window_P260(1)) & (t<=t_window_P260(2))); % Indices Corresponding To Time Window 
    
    [N140Values, N140locs] = min(y(idx_N140)); % Find PeakValues In Time Window. Because findpeaks function requires idx as the parameter rather than times.
    adjN140locs = N140locs + idx_N140(1)-1; % Adjust 'locs' To Correct For Offset.  
    N140ValuesSmooth = mean(y(adjN140locs-3:adjN140locs+3)); % extract three sampling points before and after the specific peak and then calculate mean of these 7 data points. 
    allN140ValuesSmooth = [allN140ValuesSmooth, N140ValuesSmooth]; 
    
    [P260Values, P260locs] = max(y(idx_P260)); % Find PeakValues In Time Window. Because findpeaks function requires idx as the parameter rather than times.
    adjP260locs = P260locs + idx_P260(1)-1; % Adjust 'locs' To Correct For Offset.  
    P260ValuesSmooth = mean(y(adjP260locs-3:adjP260locs+3)); % extract three sampling points before and after the specific peak and then calculate mean of these 7 data points. 
    allP260ValuesSmooth = [allP260ValuesSmooth, P260ValuesSmooth];
    
   
    
    
    figure
    plot(t,y)
    hold on

    plot(t(adjP260locs), P260Values, '^r')    
    plot(t(adjN140locs), N140Values, 'vb')     
    title(['On the specific electrode' num2str(electrode) ' N140P260 detection ', 'sub' num2str(subject), doortype{doorIdx}],'fontsize',16); %% specify the figure name
    xlabel('Latency (ms)','fontsize',16); %% name of X axis
    ylabel('Amplitude (uV)','fontsize',16);  %% name of Y axis
    hold off
    grid
    
    
    end
end
 

%%part4: reshape one array to a matrix and name its columns and rows. 
matrix_allN140Values_lownormalhigh_By_subjects = reshape (allN140ValuesSmooth, [3 4])
matrix_allP260Values_lownormalhigh_By_subjects = reshape (allP260ValuesSmooth, [3 4])
matrix_allN140Values_lownormalhigh_By_subjects_3columns = matrix_allN140Values_lownormalhigh_By_subjects'
matrix_allP260Values_lownormalhigh_By_subjects_3columns = matrix_allP260Values_lownormalhigh_By_subjects'

labelCondition = {'low'; 'normal'; 'high'};
labelsubjects = {'sub2'; 'sub3'; 'sub4'; 'sub5'};

table_allN140Values_lownormalhigh_By_subjects = array2table(matrix_allN140Values_lownormalhigh_By_subjects_3columns, 'RowNames', labelsubjects, 'VariableNames', labelCondition);
table_allP260Values_lownormalhigh_By_subjects = array2table(matrix_allP260Values_lownormalhigh_By_subjects_3columns, 'RowNames', labelsubjects, 'VariableNames', labelCondition);

writetable (table_allN140Values_lownormalhigh_By_subjects, ['Electrode' num2str(electrode) ' N140_lownormalhigh.csv'])
writetable (table_allP260Values_lownormalhigh_By_subjects, ['Electrode' num2str(electrode) ' P260_lownormalhigh.csv'])


save(['Group_level_ERP' num2str(electrode) '.mat'],'EEG_avg');  %% save the data of subjects
    
%%part5: add another code line to save data table into a tsv. file for
%%fitting with SPSS importing. So easy!


