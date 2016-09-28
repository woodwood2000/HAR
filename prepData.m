clear all
close all
%clc
%projectDir =  'G:\ActionDataColection\ActionData\0716';
projectDir =  'G:\HAR';
%projectDir = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)';
%projectDir = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/HAR(20160727)';
cd(projectDir);
%DataDir='./SensorData_labeled/Tan/';
DataDir = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\';
%DataDir='/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)/SensorData_labeled/Tan/';
filetype='.csv';
%filetype='.xls';
files = dir([DataDir '*' filetype]);
%files = dir('.\SensorData_labled\Tan\*.xls');
file_num = size(files,1);
%DataIdx=1:file_num;
%DataIdx=1:3; % Just for testing
%DataIdx=1:2; % Just for testing
DataIdx=1:3; % Just for testing

%%%%%%% Action Type %%%%%%%%%%%%%%%%%%
Action_name = cell(1,8);
Action_name(1) = {'Lying'};
Action_name(2) = {'Lie-to-sit'};
Action_name(3) = {'Sit-to-lie'};
Action_name(4) = {'Sitting'};
Action_name(5) = {'Sit-to-stand'};
Action_name(6) = {'Stand-to-sit'};
Action_name(7) = {'Standing'};
Action_name(8) = {'Walking'};
 

%%%%%%% Load Data %%%%%%%%%%%%%%%%%%%%%
win = 30;
gap = 15;

%index = 1;
%for k=1:length(DataIdx)
%conf = cell(2,1);
conf = cell(1,1);
for cross_k=1:2
    disp(sprintf('Cross Validation : %d', cross_k));
    
    % cross_k is the Index for testing

    TrainSet = [];
    TestSet = []; 
    Samples = [];
    label_file = [];
    data_file = [];
    
    %%%%%%%%% Add Features %%%%%%%%%%%%%
    %%
    for data_j=1:length(DataIdx)
        %label_file=[DataDir num2str(DataIdx(i)) filetype];
        data_file=[DataDir num2str(DataIdx(data_j)) '.txt'];
        %mp4_file=[DataDir num2str(DataIdx(data_j)) '.mp4'];
        label_file_new = [DataDir num2str(DataIdx(data_j)) '_new' filetype];% new label file
        label_file_new2 = [DataDir num2str(DataIdx(data_j)) '_new2' filetype];% new label file
        
        fprintf('open ''%s''\n', label_file_new);
        %fprintf('open "%s"\n', mp4_file);
        
%         Samples = SegData(data_file,win,gap,'fft');
        Samples = SegData(data_file,win,gap);
        
        % Save Samples in txt
        if 0
            fidSamp = fopen('samplesSegment_offline32_1.txt','wt');
            for i = 1:length(Samples)
                tmp = Samples{i}.Data;
                for j = 1:size(tmp,1)
                    for k = 1:size(tmp,2)
                        fprintf(fidSamp,'%f',tmp(j,k));
                        fprintf(fidSamp,'%c','  ');
                    end
                    fprintf(fidSamp,'%c\n','');
                end
                fprintf(fidSamp,'%c\n','');
                fprintf(fidSamp,'%c\n','');
            end
            fclose(fidSamp);
            save Samples2 Samples
        end
        
% 		clusterNum = 5;
% 		centroid = calcuCentroid(win,gap,clusterNum,projectDir,DataDir);
%         Samples = SegData(data_file,win,gap,'k-means',centroid);
        
        % Create the label file %        
        tmp_label_file = [];
        for i = 1:length(Samples)
            tmp_label_file = [tmp_label_file; Samples{i}.Time Samples{i}.Speed];            
        end
        dlmwrite(label_file_new, tmp_label_file);
        
        % Read the label file
        fprintf('Read "%s"\n', label_file_new2);
        A = dlmread(label_file_new2);
        label_mat = A(:,3);
        for i = 1:length(Samples) 
            if label_mat(i) > 0
                Samples{i}.Label = label_mat(i);
            else
                Samples{i} = [];
            end
        end
        Samples(cellfun('isempty',Samples)) = []; % Remove the Samples whose labels are zeros        
        
       fprintf('cd "%s"\n', DataDir);
       
       if 0 % Show the trajectory of the user
           showTrajectory(Samples, Action_name);
       end

        if data_j~= cross_k % Training DataSet            
            TrainSet = [TrainSet Samples];
        else % Testing DataSet
            TestSet = [TestSet Samples];
        end
 
        % Whetehr there are some Samples which PF are empty 
        for i = 1:length(Samples)
            if isempty(Samples{i}.PF)
                i
            end
        end
        
    end
    
    if 0
        drawLocation(TrainSet);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% Algorithms %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%
    %%%   1. NB      %%%%%
    %%%%%%%%%%%%%%%%
    if 0
        conf{1} = [];
        conf{1}.trainSet = TrainSet;
        conf{1}.testSet = TestSet;
        
        for i = 1:size(conf,1)
            curExp.trainSet = conf{i}.trainSet;
            curExp.testSet = conf{i}.testSet;
            disp('Training and Testing NB');
            outputNB{i,cross_k} = TrainTestSplit('nb', curExp);
        end
    end
    
    %%%%%%%%%%%%%%%%
    %%%% 2. HMM  %%%%%
    %%%%%%%%%%%%%%%%
    if 0
        conf{1} = [];
        conf{1}.trainSet = TrainSet;
        conf{1}.testSet = TestSet;
        conf{1}.try_HMM = 2; %differebt initial values
        conf{1}.M = 2; %Number of mixtures (array)
        conf{1}.Q = 4; %Number of states (array)
        conf{1}.MAX_ITER = 5;%Max Iteration for HMM
        conf{1}.cov_type = 'diag';
        
        conf{2} = [];
        conf{2}.trainSet = TrainSet;
        conf{2}.testSet = TestSet;
        conf{2}.try_HMM = 2; %differebt initial values
        conf{2}.M = 3; %Number of mixtures (array)
        conf{2}.Q = 5; %Number of states (array)
        conf{2}.MAX_ITER = 5;%Max Iteration for HMM
        conf{2}.cov_type = 'diag';
        
        for i = 1:size(conf,1)
            disp('Training and Testing HMM');
            curExp.trainSet = conf{i}.trainSet;
            curExp.testSet = conf{i}.testSet;
            curExp.try_HMM = conf{i}.M;
            curExp.M = conf{i}.M;
            curExp.Q = conf{i}.Q;
            curExp.MAX_ITER = conf{i}.MAX_ITER;
            curExp.cov_type = conf{i}.cov_type;
        outputHMM{i,cross_k} = TrainTestSplit('hmm', curExp);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%% 3. Random Forest %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%
    if 1
        conf{1} = [];
        conf{1}.trainSet = TrainSet;
        conf{1}.testSet = TestSet;
        conf{1}.nTrees = 20; % #trees in forest
        
        for i = 1:size(conf,1)
            curExp.trainSet = conf{i}.trainSet;
            curExp.testSet = conf{i}.testSet;
            curExp.nTrees = conf{i}.nTrees;
            outputRF{i,cross_k} = TrainTestSplit('rf', curExp);            
        end        
    end

end

%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%
%%

if (exist('outputNB'))
    for i = 1:size(outputNB,1)
        res.statNB{i} = calcExtendedResult('nb', outputNB(i,:));
    end
end

if (exist('outputHMM'))
    for i =1:size(outputHMM,1)
        res.statHMM{i} = calcExtendedResult('hmm', outputHMM(i,:));
    end
end

if (exist('outputRF'))
    for i =1:size(outputRF,1)
        res.statRF{i} = calcExtendedResult('rf', outputRF(i,:));
    end
end