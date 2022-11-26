




classdef Mandelbrot_set < handle
    properties (Access = private)
        fig;
        axis;
        use_gpu = false;
    end
    properties (Access = public)
        init_frame = struct('x', struct('min', -2, 'max', 1), ...
                            'y', struct('min', -2, 'max', 2));
        frame;
        max_iterations = 2000;
        resolution = 100; %pix per side
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
    
    methods (Access = public)
        function obj = Mandelbrot_set(use_gpu)
            use_gpu = logical(use_gpu);
            obj.use_gpu = use_gpu;
        end
        
        function draw(obj)
            if class(obj.fig) == "matlab.ui.Figure" && isvalid(obj.fig)
                X_lim = get(obj.axis, 'xlim');
                Y_lim = get(obj.axis, 'ylim');
                obj.frame.x.min = X_lim(1);
                obj.frame.x.max = X_lim(2);
                obj.frame.y.min = Y_lim(1);
                obj.frame.y.max = Y_lim(2);
                figure(obj.fig);
            else
                obj.frame = obj.init_frame;
                obj.fig = figure;
                obj.axis = gca;
            end
            out_data = compute(obj);
            imagesc(out_data.x, out_data.y, out_data.z)
            colormap gray
            axis equal
            set(gca, 'ydir', 'normal')
        end
        
    end
end









