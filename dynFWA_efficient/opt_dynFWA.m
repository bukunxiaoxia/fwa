% DYNFWA_CEC2014 Paper
%format long 
function [fit, time] = opt_dynFWA(id)
tic;
program.func_id = id;
program.func_name = 'cec13_func';
program.dim = 30;
program.maxEvaluation = program.dim * 10000;
program.lowbound = -100;
program.upbound = 100;
program.lowInitbound = 50;
program.upInitbound = 100;

dynFWA.numfirework = 5;
dynFWA.corefirework_amplitude = (program.upbound - program.lowbound);
dynFWA.coef_amplitude = 40;
dynFWA.sparknum_coefmax = 0.8;
dynFWA.sparknum_coefmin = 0.04;
dynFWA.explosion_sparknum = 150;
dynFWA.c_aplification = 1.2;
dynFWA.c_reduction = 0.9;

maxsparks = round(dynFWA.explosion_sparknum*dynFWA.sparknum_coefmax);
minsparks = round(dynFWA.explosion_sparknum*dynFWA.sparknum_coefmin);

eval = 0;
firework_position = rand(dynFWA.numfirework,program.dim)*(program.upInitbound-program.lowInitbound)+program.lowInitbound;
firework_fitness = feval(program.func_name,firework_position',program.func_id);

eval = eval + dynFWA.numfirework;
while eval<program.maxEvaluation
         
    ymin = min(firework_fitness);
    ymax = max(firework_fitness);
    a = dynFWA.coef_amplitude*(firework_fitness-ymin+eps)/(sum(firework_fitness-ymin)+eps);
    
	%update the cf explosion amplitude
	a(1) = dynFWA.corefirework_amplitude;
	
    s = dynFWA.explosion_sparknum*(ymax-firework_fitness+eps)/(sum(ymax-firework_fitness)+eps);
    s(s>maxsparks) = maxsparks;
    s(s<minsparks) = minsparks;
    s = round(s);
    sparks_num = sum(s);
    sparks_position = zeros(sparks_num,program.dim);
    sparks_position(1:s(1),:) =  repmat(firework_position(1,:),s(1),1)+((rand(s(1),program.dim)*2-1)*a(1)).*round(rand(s(1),program.dim));
    for i = 2:dynFWA.numfirework
        sparks_position(sum(s(1:i-1))+1:sum(s(1:i)),:) = repmat(firework_position(i,:),s(i),1)+((rand(s(i),program.dim)*2-1)*a(i)).*round(rand(s(i),program.dim));
    end
    explosion_map = rand(sparks_num,program.dim)*(program.upbound-program.lowbound)+program.lowbound;
    sparks_position(sparks_position>program.upbound|sparks_position<program.lowbound) = explosion_map(sparks_position>program.upbound|sparks_position<program.lowbound);
    sparks_fitness = feval(program.func_name,sparks_position',program.func_id);
    
    candidate_set = [firework_position;sparks_position];
    candidate_set_fit = [firework_fitness,sparks_fitness];
	[min_value,min_index] =  min(candidate_set_fit);
	% update the cf explosion amplitude 
	if min_value < firework_fitness(1)
		dynFWA.corefirework_amplitude = dynFWA.corefirework_amplitude * dynFWA.c_aplification;
	else
		dynFWA.corefirework_amplitude = dynFWA.corefirework_amplitude * dynFWA.c_reduction;
	end
	
	firework_select_index = zeros(1,dynFWA.numfirework);
	firework_select_index(1) = min_index;
	firework_select_index(2:dynFWA.numfirework) = ceil((sparks_num)*rand(1,dynFWA.numfirework-1));
    firework_position = candidate_set(firework_select_index,:);
	firework_fitness = candidate_set_fit(firework_select_index);
    eval = eval+ sparks_num;
	
end
time = toc;
fit = firework_fitness(1);

