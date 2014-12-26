%%
% Author: zheng shaoqiu, qiu11340203@163.com

%%
clear;clc;
format long;

% rand('seed', 1227); 
% normrnd('seed',1227);
FunctionDimArray = ones(1,28)*30;
Reptime = 51;

ParamsFunc.FunctionEvaluations = 300000;
ParamsFunc.FitnessSaveModStep  = 100;
ParamsFunc.FitnessMaxEvaMod100 = ParamsFunc.FunctionEvaluations/ParamsFunc.FitnessSaveModStep;

for func_id = 28:-1:28
    ParamsFunc.Dim = FunctionDimArray(func_id);
    ParamsFunc.FuncId = func_id;
    ParamsFunc.LowerBound   = -100;        
    ParamsFunc.UpperBound   =  100;      
    ParamsFunc.LowerInit    = -100;          
    ParamsFunc.UpperInit    =  100;
    ParamsFunc.FevalName = 'cec13_func';
    % save file
    FileSaveFolder  = '.\result\';
    if ~isdir(FileSaveFolder) 
        mkdir(FileSaveFolder);
    end
    FitnessASFWA    = zeros(Reptime, ParamsFunc.FitnessMaxEvaMod100);
    TimeASFWA = zeros(1,Reptime);
    fprintf(' \n FunctionId is %d, dim %d',ParamsFunc.FuncId,ParamsFunc.Dim);
    for runtime = 1:Reptime
        [FitnessASFWA(runtime,:), TimeASFWA(runtime), ExplosionAmplitude] = ASFWAFrameworkFWA(ParamsFunc);
    end       
    %print the fitness
    fidFitnessASFWA = fopen([FileSaveFolder '\F' num2str(func_id) 'D'  num2str(ParamsFunc.Dim) '.csv'], 'w');
    for runtime = 1 : Reptime
        fprintf(fidFitnessASFWA,'%dth run,',runtime);
        for j = 1: ParamsFunc.FitnessMaxEvaMod100
            fprintf(fidFitnessASFWA,'%.10f,',FitnessASFWA(runtime,j));
        end
        fprintf(fidFitnessASFWA,'\n');
    end
    %print the average fitness, the statical results
    fprintf(fidFitnessASFWA,'\n\nthe mean value\n');
    meanFitnessASFWA = mean(FitnessASFWA,1);
    for i = 1 : ParamsFunc.FitnessMaxEvaMod100
       fprintf(fidFitnessASFWA,'%.10f,',meanFitnessASFWA(i));
    end
    fprintf(fidFitnessASFWA,'\n\n the statistical results is\n');
    fprintf(fidFitnessASFWA,'mean,%.10f,\n',meanFitnessASFWA(ParamsFunc.FitnessMaxEvaMod100));
    fprintf(fidFitnessASFWA,'std,%.10f,',std(FitnessASFWA(:,ParamsFunc.FitnessMaxEvaMod100)));
    fprintf(fidFitnessASFWA,'\n\n\n');
    fprintf(fidFitnessASFWA,'runningtime,');
    for i = 1 : Reptime
        fprintf(fidFitnessASFWA,'%.10f,',TimeASFWA(i));
    end
    fclose(fidFitnessASFWA);    
end