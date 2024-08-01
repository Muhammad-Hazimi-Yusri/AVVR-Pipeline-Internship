    % Script file to plot and evaluate the performance of the algorithms for 
    % different rooms
    
    addpath RIRs
    addpath Unity-ogg-files\
    addpath 'RIRs' 'IoSR Toolbox' 'octave'
    
    Rooms = {'BBC_LR', 'BBC_UL', 'Courtyard', 'DWRC', 'Kitchen', 'Studio1'};
    Methods = {'recorded', 'sirr', 'rsao_SigTmix', 'combined'};
    earlyt_vec = [ 0.01, 0.01, 0.08, 0.03, 0.04, 0.01];
    % This is the early part of RIR chosen to calculate the correlation between
    % the recorded and regenerated RIRs. This is different for each room.
    tlen_vec = [0.1, 0.1, 0.5, 0.2, 0.3, 0.1] ;
    % Since the whole recorded RIR is too long and almost zero after a short
    % time we only choose the length containing energy. This is different for
    % each room
    
    Nr = length(Rooms); % Number of Rooms
    Nmethods = length(Methods); % Number of methods including the ground truth
    Octave_bands = 9;
    Nmetric = 4;
    
    for r = 3:5 %1:Nr
          
        earlyt = earlyt_vec(r); tlen = tlen_vec(r);
        % Determining the size of metrics
        RT = zeros(Octave_bands,Nmethods); EDT = zeros(Octave_bands,Nmethods);
        DRR = zeros(Octave_bands,Nmethods); C50 = zeros(Octave_bands,Nmethods); 
        Cfs = zeros(Nmethods, Octave_bands);
    
        room_name = cell2mat(Rooms(r));
        [rir_gt, fs] = audioread([room_name '_BFormat.wav']);
        assignin('base', [room_name '_recorded'], rir_gt(:,1));
    
        audiowrite('rir_record.wav',rir_gt(:,1)./2,fs);
        % To evaluate the metrics using irStats function in IoSR Toolbox
        % Matlab files/IoSR Toolbox/+iosr/+acoustics/irStats.m
        [RT(:,1), DRR(:,1), C50(:,1), Cfs(1,:), EDT(:,1)] = ...
                iosr.acoustics.irStats('rir_record.wav','spec', 'full');
    
        result = eval(['plot(' [room_name '_recorded'] ');']);
        xlabel ({'Time [s]'},'FontSize',12);
        ylim([-1 1]);
        xlabel ({'Time [s]'},'FontSize',12); 
        ylabel({'Amplitude'},'FontSize',12);
        title('Original RIR','FontSize',12); 
        clear rir_gt
        
    
    
        for m = 2:Nmethods % Starts from the 2nd as the ground truth (recorded)
            % signal is already evaluated
            method_name = cell2mat(Methods(m));
            [rir, fs] = audioread([room_name '_' method_name '_rir.ogg']);        
            assignin('base', [room_name '_' method_name], rir(:,1)./max(rir(:,1)));
            
            audiowrite('rir_regenerate.wav',rir(:,1)./2,fs);
            [RT(:,m), DRR(:,m), C50(:,m), Cfs(m,:), EDT(:,m)] = ...
                iosr.acoustics.irStats('rir_regenerate.wav','spec', 'full');
            % iosr.acoustics.irStats('rir_record.wav','graph', true, 'spec', 'full');
            % To plot the EDT & RT60 curves in octave bands
            
    
            figure; gt_plot = eval(['plot(' [room_name '_recorded'] ');']);
            hold on; method_plot = eval(['plot(' [room_name '_' method_name] ');']);
            xlabel ({'Time [s]'},'FontSize',12); 
            ylim([-1 1]); grid on;
            xlabel ({'Time [s]'},'FontSize',12); 
            ylabel({'Amplitude'},'FontSize',12);
            title([room_name '-' method_name],'FontSize',12);
    
        end
        
        Results = [RT, DRR, C50, EDT];
        Full_freq = reshape(Results,[Octave_bands,Nmethods,Nmetric]);
        % Tensor Matrix of size N_Octave_bands x Nmethods x Nmetrics
        assignin('base', [room_name '_full_freq_results'], Full_freq);
        mean_results = squeeze(mean(Full_freq,1)); 
        % Matrix of size Nmethods x Nmetrics
        assignin('base', [room_name '_avrg_results'], mean_results);

    end
