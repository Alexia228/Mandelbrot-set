% TODO:
% 1) Add new coloring scheme
% 

classdef Mandelbrot_set < handle
%------------------PUBLIC SECTION--------------------------
% NOTE:
% this functions and data properties could be used from anywhere   
% also think about someone set resolution equal to -3/4 :D

% FIXME: add some protection to this two variables
    properties (Access = public)
        max_iterations = 500;
        resolution = 1000; %pix per side
    end
    
    methods (Access = public) 
        function obj = Mandelbrot_set(use_gpu)
            use_gpu = logical(use_gpu);
            obj.use_gpu = use_gpu;
        end
        
        function draw(obj)
            if class(obj.fig) == "matlab.ui.Figure" && isvalid(obj.fig)
                figure(obj.fig); %open figure 'fig' on foreground
                X_lim = get(obj.axis, 'xlim');
                Y_lim = get(obj.axis, 'ylim');
                obj.frame.x.min = X_lim(1);
                obj.frame.x.max = X_lim(2);
                obj.frame.y.min = Y_lim(1);
                obj.frame.y.max = Y_lim(2);
            else
                obj.frame = obj.init_frame;
                obj.fig = figure; %figure will appear on your screen on this line
                obj.axis = gca; %create axis and get its handle for further use
            end
            out_data = compute(obj);
            imagesc(out_data.x, out_data.y, out_data.z)
            colormap gray %coloring magic here (dont forget that data is inverted z = 1 - Cplx_grid)
            axis equal
            set(gca, 'ydir', 'normal')
        end
    end
    

%------------------PRIVATE SECTION-------------------------
% this functions and data properties could be used from class methods ONLY
    properties (Access = private)
        fig;
        axis;
        use_gpu = false;
        init_frame = struct('x', struct('min', -2, 'max', 1), ...
            'y', struct('min', -2, 'max', 2));
        frame;
    end
    
    methods (Access = private)
        function out_data = compute(obj)
            X_range = linspace(obj.frame.x.min, obj.frame.x.max, obj.resolution);
            Y_range = linspace(obj.frame.y.min, obj.frame.y.max, obj.resolution);
            
            [X_grid, Y_grid] = meshgrid(X_range, Y_range);
            Cplx_grid_base = complex(X_grid, Y_grid);
            clearvars X_grid Ygrid
            
            Cplx_grid = complex(zeros(size(Cplx_grid_base)));
            
            if ~obj.use_gpu
                for i = 1:obj.max_iterations
                    disp(['progress: ' num2str(round(i/obj.max_iterations*10000)/100) '%']);
                    Cplx_grid = Cplx_grid.^2 + Cplx_grid_base;
                end
                Cplx_grid = abs(Cplx_grid);
                Cplx_grid(Cplx_grid > 2) = 0;
                Cplx_grid(Cplx_grid > 0) = 1;
            else
                Cplx_grid_gpu = gpuArray(Cplx_grid);
                Cplx_grid_base_gpu = gpuArray(Cplx_grid_base);
                for i = 1:obj.max_iterations
                    disp(['progress: ' num2str(round(i/obj.max_iterations*10000)/100) '%']);
                    Cplx_grid_gpu = Cplx_grid_gpu.^2 + Cplx_grid_base_gpu;
                end
                Cplx_grid_gpu = abs(Cplx_grid_gpu);
                Cplx_grid_gpu(Cplx_grid_gpu > 2) = 0;
                Cplx_grid_gpu(Cplx_grid_gpu > 0) = 1;
                Cplx_grid = gather(Cplx_grid_gpu);
            end
            
            out_data.z = 1 - Cplx_grid;
            out_data.x = X_range;
            out_data.y = Y_range;
        end
    end
end

