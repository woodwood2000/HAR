function output = TrainTestClassify(modelName, curExp)

% This function trains and tests a model for a given collection of training
% and test data. 
%
% Models should be placed in a directory named modelName, the directory
% should contain a modelNameTrain and modelNameTest file.

% Training (learn parameters)
%tic;
disp('Training');
modelTrain = strcat(modelName, 'TrainClassify'); % create train functionname e.g. hmmTrain
output.training.learnedParams = feval(modelTrain, curExp);
%output.training.learnedParams = eval(modelTrain, curExp);
%output.training.elapsedTime = toc;

% Testing (infer labels on testdata)
%tic;
disp('Testing');
modelTest = strcat(modelName, 'TestClassify'); % create test functionname e.g. hmmTest
output.testing = feval(modelTest, curExp, output.training.learnedParams);
%output.testing = eval(modelTest, curExp, output.training.learnedParams);
%output.testing.elapsedTime = toc;