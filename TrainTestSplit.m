function output = TrainTestSplit(modelName, curExp)

% This function trains and tests a model for a given collection of training
% and test data. 
%
% Models should be placed in a directory named modelName, the directory
% should contain a modelNameTrain and modelNameTest file.

% Training (learn parameters)
%tic;
%disp('Training');
fprintf('\n%s: Training\n\n', modelName);
modelTrain = strcat(modelName, 'TrainSplit'); % create train functionname e.g. hmmTrain
output.training.learnedParams = feval(modelTrain, curExp);
%output.training.elapsedTime = toc;

% Testing (infer labels on testdata)
%tic;
%disp('Testing');
fprintf('\n%s: Testing\n\n', modelName);
modelTest = strcat(modelName, 'TestSplit'); % create test functionname e.g. hmmTest
output.testing = feval(modelTest, curExp, output.training.learnedParams);
%output.testing.elapsedTime = toc;