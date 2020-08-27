classdef DisplayConfig
% DisplayConfig this class stores the crucial display config properties
    
    properties
        refresh_rate = 165;
        resolution_reduction = 1.0;
        native_resolution_horizontal = 2560;
        fov = 30;
    end
    
    methods
        function obj = DisplayConfig(refresh_rate, native_resolution_horizontal, resolution_reduction, fov)
            obj.refresh_rate = refresh_rate;
            obj.native_resolution_horizontal = native_resolution_horizontal;
            obj.resolution_reduction = resolution_reduction;
            obj.fov = fov;
        end
        
        function res = resolution(obj)
            res = obj.native_resolution_horizontal * obj.resolution_reduction;
        end
    end
end

