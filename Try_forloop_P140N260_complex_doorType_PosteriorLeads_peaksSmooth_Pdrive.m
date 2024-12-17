clear all; clc; 
%% part1: data importing and to sqeeze EEG.data dimentions. 
 subjects = [2,3,4,5]; %% subject numbers
 doortype = {'low', 'normal', 'high'};
 allP140ValuesSmooth = [];
 allN260ValuesSmooth = [];
 
for subject = subjects
    for doorIdx = 1:3  
    setname = strcat(['sub' num2str(subject) '_practice_filtered_' doortype{doorIdx}  '_Lights_ON_bad_epochs_removal.set']); %% filename of set file
    setpath = 'P:\Sheng_Wang\exp2\data\eeglab_practice\epochs_LightsOn\'; %% filepath of set files 
    EEG = pop_loadset('filename',setname,'filepath',setpath); %% load the data
    EEG = eeg_checkset(EEG);
    EEG_avg(subject,:,:) = squeeze(mean(EEG.data,3)); %% EEG_avg dimension: channel*time*trial → subj*channel*time
    
    
    
    %%part2: select the specific channel and calculate group-level ERP at this specific electrode
    electrode = 64; % select the specific channel
    % define peak latencies.
    searchP140Post = 140;
    searchN260Post = 260;
    
    figure;
    mean_data = squeeze(EEG_avg(subject,electrode,:));  %% select the data according to the above selected electrode and the specific subject number 
    plot(EEG.times, mean_data,'k','linewidth', 1.5); %% plot the waveforms
    axis([-500 1000 -5 5]);  %% define the region to display
    title(['Group-level at the specific electrode' num2str(electrode), ' sub' num2str(subject), doortype{doorIdx}],'fontsize',16); %% specify the figure name
    xlabel('Latency (ms)','fontsize',16); %% name of X axis
    ylabel('Amplitude (uV)','fontsize',16);  %% name of Y axis

    
    
    %%part3: to detect and pick up peaks amplitude within this study dataset
    y = mean_data; % signal and data
    t = EEG.times; % Time Vector
    t_window_P140 = [searchP140Post-50, searchP140Post+50]; %Time window for P132
    t_window_N260 = [searchN260Post-50, searchN260Post+50]; %Time window for N256
    
    idx_P140 = find((t>= t_window_P140(1)) & (t<=t_window_P140(2))); % Indices Corresponding To Time Window 
    idx_N260 = find((t>= t_window_N260(1)) & (t<=t_window_N260(2))); % Indices Corresponding To Time Window 

    
    [P140Values, P140locs] = max(y(idx_P140)); % Find PeakValues In Time Window. Because findpeaks function requires idx as the parameter rather than times.
    adjP140locs = P140locs + idx_P140(1)-1; % Adjust 'locs' To Correct For Offset.  
    P140ValuesSmooth = mean(y(adjP140locs-3:adjP140locs+3)); % extract three sampling points before and after the specific peak and then calculate mean of these 7 data points. 
    allP140ValuesSmooth = [allP140ValuesSmooth, P140ValuesSmooth];
    
    [N260Values, N260locs] = min(y(idx_N260)); % Find PeakValues In Time Window. Because findpeaks function requires idx as the parameter rather than times.
    adjN260locs = N260locs + idx_N260(1)-1; % Adjust 'locs' To Correct For Offset.  
    N260ValuesSmooth = mean(y(adjN260locs-3:adjN260locs+3)); % extract three sampling points before and after the specific peak and then calculate mean of these 7 data points. 
    allN260ValuesSmooth = [allN260ValuesSmooth, N260ValuesSmooth];
    
    figure
    plot(t,y)
    hold on
    plot(t(adjP140locs), P140Values, '^r')     %plot(t(adjN1locs), N1Values, '^r') 
    plot(t(adjN260locs), N260Values, 'vb')
    title(['On the specific electrode' num2str(electrode) ' P140N260 detection ', 'sub' num2str(subject), doortype{doorIdx}],'fontsize',16); %% specify the figure name
    xlabel('Latency (ms)','fontsize',16); %% name of X axis
    ylabel('Amplitude (uV)','fontsize',16);  %% name of Y axis
    hold off
    grid
    
    
    end
end
 

%%part4: reshape one array to a matrix and name its columns and rows. 
matrix_allP140Values_lownormalhigh_By_subjects = reshape (allP140ValuesSmooth, [3 4])
matrix_allN260Values_lownormalhigh_By_subjects = reshape (allN260ValuesSmooth, [3 4])
matrix_allP140Values_lownormalhigh_By_subjects_3columns = matrix_allP140Values_lownormalhigh_By_subjects'
matrix_allN260Values_lownormalhigh_By_subjects_3columns = matrix_allN260Values_lownormalhigh_By_subjects'


labelCondition = {'low'; 'normal'; 'high'};
labelsubjects = {'sub2'; 'sub3'; 'sub4'; 'sub5'};

table_allP140Values_lownormalhigh_By_subjects = array2table(matrix_allP140Values_lownormalhigh_By_subjects_3columns, 'RowNames', labelsubjects, 'VariableNames', labelCondition);
table_allN260Values_lownormalhigh_By_subjects = array2table(matrix_allN260Values_lownormalhigh_By_subjects_3columns, 'RowNames', labelsubjects, 'VariableNames', labelCondition);

writetable (table_allP140Values_lownormalhigh_By_subjects, ['Electrode' num2str(electrode) ' P140_lownormalhigh.csv'])
writetable (table_allN260Values_lownormalhigh_By_subjects, ['Electrode' num2str(electrode) ' N260_lownormalhigh.csv'])

save(['Group_level_ERP' num2str(electrode) '.mat'],'EEG_avg');  %% save the data of subjects
    
%%part5: add another code line to save data table into a tsv. file for
%%fitting with SPSS importing. So easy!


