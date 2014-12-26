% main

%% dynFWA

func_num = 28;
runtime = 51;
dynFWA_fit = zeros(func_num,runtime);
dynFWA_time = zeros(func_num,runtime);
for i = 1:func_num
    disp(sprintf('函数%d,开始运行...',i));
    for run = 1:runtime
        [dynFWA_fit(i,run),dynFWA_time(i,run)]=opt_dynFWA(i);
        disp(sprintf('函数%d,运行迭代次数%d运行完毕，结果%.6f,时间消耗%.2f s',i,run,dynFWA_fit(i,run),dynFWA_time(i,run)));
    end
    disp(sprintf('函数%d运行完毕，均值为%.6f',i,mean(dynFWA_fit(i,:))));
end

% store the results

fid_dynFWA = fopen('.\fit_dynFWA.csv', 'w');
for i = 1:func_num
    fprintf(fid_dynFWA,'fun%d',i);
    for run = 1:runtime
        fprintf(fid_dynFWA,',%.6f',dynFWA_fit(i,run));
    end
    fprintf(fid_dynFWA,'\n');
end
fclose(fid_dynFWA);

fid_dynFWA_mean = fopen('.\fit_dynFWA_mean.csv', 'w');
mean_fit = mean(dynFWA_fit,2);
for i = 1:func_num
    fprintf(fid_dynFWA_mean,'fun%d,%.6f',i,mean_fit(i));
    fprintf(fid_dynFWA_mean,'\n');
end
fclose(fid_dynFWA_mean);