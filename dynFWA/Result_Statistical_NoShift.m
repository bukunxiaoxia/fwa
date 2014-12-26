% 结果统计

F = '.\result\';

function_number = 28;
reptimes = 51;

meanData = zeros(1,function_number);
timeData = zeros(1,function_number);

for func_id = 1:function_number
    
        file_name = [F 'F' num2str(func_id) 'D30.csv'];
        data = importdata(file_name);
        meanData(1,func_id) = mean(data.data(1:reptimes,3000));            
        timeData(1,func_id) = mean(data.data(reptimes+6,2:reptimes+1));  
    
end

fid = fopen([F 'fwa_mean.csv'],'w');
for func_id = 1:function_number
    fprintf(fid,'fun,%d,',func_id);
    fprintf(fid,'%.6f,',meanData(1,func_id));     
    fprintf(fid,'\n');
end
fclose(fid);
        
fid = fopen([F 'fwa_time.csv'],'w');
for func_id = 1:function_number
    fprintf(fid,'fun,%d,',func_id);
    fprintf(fid,'%.6f,',timeData(1,func_id));     
    fprintf(fid,'\n');
end
fclose(fid);
