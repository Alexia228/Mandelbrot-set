




M_set = Mandelbrot_set(); % Create obj

% set variable parameters
M_set.max_iterations = 200; % bigger is better and slower
M_set.resolution = 500; % bigger is better and slower
M_set.frame = Frame;


%% Draw (redraw)
M_set.init_frame.x
M_set.draw();

% 1) run for first time
% 2) choose new frame on axis
% 3) run this section one more time to redraw
% 4) repeat steps 2-3 any time

