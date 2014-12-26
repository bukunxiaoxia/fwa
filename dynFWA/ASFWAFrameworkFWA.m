function [fidFitnessASFWAModStep100, timeRun,CFExplosionAmplitudeArray] = ASFWAFrameworkFWA(ParamsFunc)

tic
global CurrentEvatime;
CurrentEvatime = 0;

ParamsAlgorithm.FireworkNumber = 5;
ParamsAlgorithm.Coef_Spark_Num = 150;
ParamsAlgorithm.Max_Sparks_Num = 0.8*150;
ParamsAlgorithm.Min_Sparks_Num = 0.04*150;


global ParamsASFWA;
ParamsASFWA.CFExplosionAmplitude = (ParamsFunc.UpperBound - ParamsFunc.LowerBound);% 独立烟花的个数有关，每个独立计算
ParamsASFWA.CFExplosionAmplitudeUpdateThreshold = 0;
ParamsASFWA.UpCoef = 1.2;
ParamsASFWA.LowCoef = 0.9;
ParamsASFWA.Coef_Explosion_Amplitude = 40;

% data record
FitnessEvaluationBestArray = zeros(1,ParamsFunc.FunctionEvaluations);
FitnessIteration = zeros(round(ParamsFunc.FunctionEvaluations/(ParamsAlgorithm.Coef_Spark_Num)),1);
CFExplosionAmplitudeArray = zeros(1,round(ParamsFunc.FunctionEvaluations/(ParamsAlgorithm.Coef_Spark_Num)));

% Algorithm starts!!!
% Initialization
FireworksMatrix = repmat(ParamsFunc.LowerInit, ParamsAlgorithm.FireworkNumber, ParamsFunc.Dim) + rand(ParamsAlgorithm.FireworkNumber, ParamsFunc.Dim).* repmat(ParamsFunc.UpperInit - ParamsFunc.LowerInit, ParamsAlgorithm.FireworkNumber, ParamsFunc.Dim);
FireworksFitness = zeros(1,ParamsAlgorithm.FireworkNumber);

% evaluate the first firework, update the FitnessEvaluationBestArray
FireworksFitness(1) = feval(ParamsFunc.FevalName,FireworksMatrix(1,:)',ParamsFunc.FuncId);
% PositionIterationBestArray(1,1,:) = FireworksMatrix(1,:);
CurrentEvatime = CurrentEvatime + 1;
FitnessEvaluationBestArray(CurrentEvatime) = FireworksFitness(1);

% evaluate the other fireworks
for i = 2 : ParamsAlgorithm.FireworkNumber
    FireworksFitness(i) = feval(ParamsFunc.FevalName,FireworksMatrix(i,:)',ParamsFunc.FuncId);
%     PositionIterationBestArray(i,1,:) = FireworksMatrix(i,:);
    if(FireworksFitness(i)<FitnessEvaluationBestArray(CurrentEvatime))
        FitnessEvaluationBestArray(CurrentEvatime+1) = FireworksFitness(i);
    else
        FitnessEvaluationBestArray(CurrentEvatime+1) = FitnessEvaluationBestArray(CurrentEvatime);
    end
    CurrentEvatime = CurrentEvatime + 1;
end

CurrentIteration = 0;
while CurrentEvatime < ParamsFunc.FunctionEvaluations
    CurrentIteration = CurrentIteration + 1;
    FitnessIteration(CurrentIteration) = FireworksFitness(1);
    
    if CurrentIteration > 1
        if FitnessIteration(CurrentIteration-1) - FitnessIteration(CurrentIteration)>0
            ParamsASFWA.CFExplosionAmplitude = ParamsASFWA.CFExplosionAmplitude * ParamsASFWA.UpCoef;
        else
            ParamsASFWA.CFExplosionAmplitude = ParamsASFWA.CFExplosionAmplitude * ParamsASFWA.LowCoef;
        end

%         if(ParamsASFWA.CFExplosionAmplitude<ParamsASFWA.CFValueRestartThreshold && rand < ParamsASFWA.CFProbabilityRestart)
%             ParamsASFWA.CFExplosionAmplitude = ParamsFunc.UpperInit - ParamsFunc.LowerInit;
%             FireworksMatrix = repmat(ParamsFunc.LowerInit, ParamsAlgorithm.FireworkNumber, ParamsFunc.Dim) + rand(ParamsAlgorithm.FireworkNumber, ParamsFunc.Dim).* repmat(ParamsFunc.UpperInit - ParamsFunc.LowerInit, ParamsAlgorithm.FireworkNumber, ParamsFunc.Dim);
%             FireworksFitness = feval(ParamsFunc.FevalName,FireworksMatrix',ParamsFunc.FuncId);
%         end
        
    end
    [FireworksMatrix, FireworksFitness, FitnessEvaluationBestArray] = SparksGenerateAndSelectionRemoveGaussian(FireworksMatrix,FireworksFitness,FitnessEvaluationBestArray,ParamsAlgorithm,ParamsFunc); 
    CFExplosionAmplitudeArray(CurrentIteration) = ParamsASFWA.CFExplosionAmplitude;
end
timeRun = toc;
fprintf(' \n Best fitness for FWA: %.10f, runtime: %g, dim %d', FitnessEvaluationBestArray(ParamsFunc.FunctionEvaluations), timeRun,ParamsFunc.Dim);
fidFitnessASFWAModStep100 = zeros(1,ParamsFunc.FitnessMaxEvaMod100);
for i = 1 :ParamsFunc.FitnessMaxEvaMod100
    fidFitnessASFWAModStep100(i) = FitnessEvaluationBestArray(i*ParamsFunc.FitnessSaveModStep);
end



