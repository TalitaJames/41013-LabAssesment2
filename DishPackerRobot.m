classdef DishPackerRobot < handle
    properties (Constant)
      
    end

    properties (SetAccess = private) % private variables
        robot_UR3e
        robot_gantry
        logger = log4matlab("out/"+ datestr(now,'yyyymmdd-HHMM') +".log"); %#ok<TNOW1,*DATST>

        % All enviroment handles
        envroment_h;
        
    end

    methods (Access = private)
        function SetupEnviroment(self)
        % Create the enviroment, setup robots, place plates ect

            % Place the robots
            self.robot_UR3e = UR3e;


            % move the robot to inital position of on the table at "home"
            self.robot_UR3e.model.base = transl(0,0,0) * self.robot_UR3e.model.base.T;
            self.robot_UR3e.model.animate(self.robot_UR3e.homeQ);

            % Create the enviroment
            plate_h = PlaceObject("graphical_models/plate_mm.ply",[1.5,1,0]);
            HandleManipulation.ScaleHandle(plate_h, 0.01);
            %self.envroment_h = PlaceObject("graphical_models/glass.ply",[1.5,0.6,0]);
            %HelperFunctions.RotateHandle(self.personTwo_h,trotz(pi/2))

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
