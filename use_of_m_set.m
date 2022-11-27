

% run this to find all NOTE, FIXME and TODO
dofixrpt('Mandelbrot_set.m', 'file')


%%

clc

M_set = Mandelbrot_set(false); % Create obj

% set variable parameters
M_set.max_iterations = 1000; % bigger is better and slower
M_set.resolution = 1000; % bigger is better and slower



%% Draw (redraw)
tic
M_set.draw();
toc
% 1) run for first time
% 2) choose new frame on axis
% 3) run this section one more time to redraw
% 4) repeat steps 2-3 any time





%% Time test
clc
M_set_cpu = Mandelbrot_set(false); % Create obj
M_set_gpu = Mandelbrot_set(true); % Create obj

Iter = 100; % try 100 and 1000 iterations to figure opu that GPU is useful ...
Res = 1000; % only in task with high amount of computations

M_set_cpu.max_iterations = Iter; % bigger is better and slower
M_set_cpu.resolution = Iter; % bigger is better and slower

M_set_gpu.max_iterations = Res; % bigger is better and slower
M_set_gpu.resolution = Res; % bigger is better and slower

clearvars Iter Res

% test CPU time
timer = tic;
M_set_cpu.draw();
Time_of_cpu = toc(timer);
% ----------------------

% test CPU time
timer = tic;
M_set_gpu.draw();
Time_of_gpu = toc(timer);
% ----------------------

clc
disp(['Time of CPU: ' num2str(Time_of_cpu) ' s'])
disp(['Time of GPU: ' num2str(Time_of_gpu) ' s'])

close all

clearvars timer Time_of_cpu Time_of_gpu













