classdef DishPackerRobot < handle
    properties (Constant)
      
    end

    properties (SetAccess = private) % private variables
        UR3e
        gantry
        logger = log4matlab("out/"+ datestr(now,'yyyymmdd-HHMM') +".log"); %#ok<TNOW1,*DATST>

        % All enviroment handles

        
    end

    methods (Access = private)
        function SetupEnviroment(self)
        % Create the enviroment, setup robots, place plates ect
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), "The enviroment has been created"};
        end
    end

    methods (Access = public)
        function obj = DishPackerRobot()
        % Construct a DishPacker Object
            obj.SetupEnviroment();
        end

        function AnimateRobot(self, robot, endEffectorPose, steps)
        % Animates given robot from its current position to end
        end

        function AnimateRobotWithObj(self, robot, endEffectorPose, steps, handle)
        % Animates given robot from its current position to end, bringing a
        % handle at the position of 
            
        end

        function MovePlate(self, startPos, endPos)
        % Takes a plate from the start to its expected position using both robots
        end

        function Reset(self)
        % Resets the whole system to its "home" positions
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Reset system"};
        end

        function Teach(self)
        % Brings up the "teach" pane for each robot
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Teaching pannel is now visable"};
        end

        function delete(self)
        % Deletes the object, including all ascocisated handles & data
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Deleting object"};
        end

    end
end
