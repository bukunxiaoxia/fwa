function [FireworksSelectMatrix, FireworksSelectFitness, FitnessEvaluationBestArray] = SparksGenerateAndSelectionRemoveGaussian(FireworksMatrix,FireworksFitness,FitnessEvaluationBestArray,ParamsAlgorithm,ParamsFunc)

global CurrentEvatime;
global ParamsASFWA;

%% calculate the sparks number for each firework

fitness_max = max(FireworksFitness); 
fitness_sub_max = abs(fitness_max - FireworksFitness);
fitness_sub_max_sum = sum(fitness_sub_max);

SparksNumArray = zeros(1, ParamsAlgorithm.FireworkNumber);

for i = 1 : ParamsAlgorithm.FireworkNumber
    sonnum_temp = (fitness_sub_max(i) + eps) / (fitness_sub_max_sum + eps);
    sonnum_temp = round( sonnum_temp * ParamsAlgorithm.Coef_Spark_Num);
    if sonnum_temp > ParamsAlgorithm.Max_Sparks_Num
        sonnum_temp = ParamsAlgorithm.Max_Sparks_Num;
    elseif sonnum_temp < ParamsAlgorithm.Min_Sparks_Num
            sonnum_temp = ParamsAlgorithm.Min_Sparks_Num;
    end
    SparksNumArray(i) = sonnum_temp; 
end
SparksNumSum = sum(SparksNumArray);

% calculate the explosion amplitde for fireworks

[fitness_best,~] = min(FireworksFitness);
fitness_sub_best = abs(fitness_best - FireworksFitness);
fitness_sub_best_sum = sum(fitness_sub_best);
SparksScopeArray = zeros(1,ParamsAlgorithm.FireworkNumber);

    
for i=1 : ParamsAlgorithm.FireworkNumber
	SparksScopeArray(i) = ParamsASFWA.Coef_Explosion_Amplitude * (fitness_sub_best(i) + eps) / (fitness_sub_best_sum + eps);  
end
[~,min_index] = min(FireworksFitness);
SparksScopeArray(min_index) = ParamsASFWA.CFExplosionAmplitude;

%% explosion sparks generate
ExplosionSparksMatrix = zeros(SparksNumSum,ParamsFunc.Dim);
% explosion fireworks
explosionIndex = 0;
for j = 1: ParamsAlgorithm.FireworkNumber
    for i = 1 : SparksNumArray(j)
        explosionIndex = explosionIndex + 1;
        ExplosionSparksMatrix(explosionIndex,:) = FireworksMatrix(j,:);        
        for k = 1 : ParamsFunc.Dim
            if rand > 0.5
                offset = (rand*2-1) * SparksScopeArray(j); %Calculate the displacement:
                ExplosionSparksMatrix(explosionIndex,k) = ExplosionSparksMatrix(explosionIndex,k) + offset;
                if ExplosionSparksMatrix(explosionIndex,k) > ParamsFunc.UpperBound || ExplosionSparksMatrix(explosionIndex,k) < ParamsFunc.LowerBound
                    ExplosionSparksMatrix(explosionIndex,k) = (rand*2-1)*(ParamsFunc.UpperBound-ParamsFunc.LowerBound)/2 + (ParamsFunc.UpperBound+ParamsFunc.LowerBound)/2;
                end
            end
        end       
    end
end


Sparks = [ExplosionSparksMatrix;FireworksMatrix];
SparksFitness = zeros(1,SparksNumSum +ParamsAlgorithm.FireworkNumber);
for i = 1: SparksNumSum
    SparksFitness(i) =  feval(ParamsFunc.FevalName,Sparks(i,:)',ParamsFunc.FuncId);
    if(SparksFitness(i)<FitnessEvaluationBestArray(CurrentEvatime))
        FitnessEvaluationBestArray(CurrentEvatime+1) = SparksFitness(i);
    else
        FitnessEvaluationBestArray(CurrentEvatime+1) = FitnessEvaluationBestArray(CurrentEvatime);
    end
    CurrentEvatime = CurrentEvatime + 1;
end
SparksFitness(SparksNumSum + 1 : SparksNumSum + ParamsAlgorithm.FireworkNumber) = FireworksFitness;
[MinValue,MinIndex] = min(SparksFitness);

FireworksSelectMatrix = zeros(ParamsAlgorithm.FireworkNumber,ParamsFunc.Dim);
FireworksSelectFitness = zeros(1,ParamsAlgorithm.FireworkNumber);
FireworksSelectMatrix(1,:) = Sparks(MinIndex,:);
FireworksSelectFitness(1) = MinValue;

for i = 2:ParamsAlgorithm.FireworkNumber
    fireworkSelectIndex = ceil(rand*(SparksNumSum + ParamsAlgorithm.FireworkNumber));
    FireworksSelectMatrix(i,:) = Sparks(fireworkSelectIndex,:);
    FireworksSelectFitness(i) = SparksFitness(fireworkSelectIndex);
end
    
