classdef Gantry < RobotBaseClass
    %% Custom Gantry Actuated Robot
    % Made in Spring 2024

    properties(Access = public)
        plyFileNameStem = 'Gantry';
    end


    methods
%% Constructor
        function self = Gantry(baseTr)
            self.CreateModel();
            self.workspace = [-2 2 -2 2 -0.5 1];  % Adjust these limits based on gantry range

            if nargin < 1
                baseTr = eye(4);
            end

			self.model.base = self.model.base.T * baseTr;
            self.PlotAndColourRobot();
            %drawnow
        end

%% CreateModel
        function CreateModel(self)
            link(1) = Link([0      0           0        pi/2    1]);
            link(2) = Link([-pi/2  0           0       -pi/2    1]);
            link(3) = Link([0      0           0        0       1]);

            link(1).qlim = [0.01 0.6];
            link(2).qlim = [0.01 1.3];
            link(3).qlim = [0.01 0.3];

            self.model = SerialLink(link,'name',self.name);
        end    
    end
end