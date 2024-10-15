classdef DishPackerRobot < handle
    properties (Constant)
      
    end

    properties (SetAccess = private) % private variables
        robot_UR3e
        robot_gantry
        logger = log4matlab("out/"+ datestr(now,'yyyymmdd-HHMM') +".log"); %#ok<TNOW1,*DATST>

        % All enviroment handles
        enviroment_h;
        table_h;
        eStopFace_h;
        
    end

    methods (Access = private)
        function SetupEnviroment(self)
        % Create the enviroment, setup robots, place plates ect
            hold on;
            % grid on
            axis equal;
            view(3);
        
            % Place the robots
            self.robot_UR3e = UR3e;


            % move the robot to inital position of on the table at "home"
            self.robot_UR3e.model.base = transl(0,0,0.5) * self.robot_UR3e.model.base.T;
            self.robot_UR3e.model.animate(self.robot_UR3e.homeQ);

            % Create the enviroment
            % enviroment_h = PlaceObject("graphical_models/environment.ply",[1.5,1,0]);
            % plate_h = PlaceObject("graphical_models/plate.ply",[1.5,1,0]);
            % HandleManipulation.ScaleHandle(plate_h, 0.01);
            % self.envroment_h = PlaceObject("graphical_models/glass.ply",[1.5,0.6,0]);
            % HelperFunctions.RotateHandle(self.personTwo_h,trotz(pi/2))


            self.table_h = PlaceObject("rvctools/robot/UTS/Parts/tableBrown2.1x1.4x0.5m.ply");
            self.eStopFace_h = PlaceObject("rvctools/robot/UTS/Parts/emergencyStopButton.ply",[0.9,-0.55,0.5-0.15]);
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
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Animating a robot"};
            
            currentJoints = robot.model.getpos;
            currentEndEffector = robot.model.fkine(currentJoints).T;
            endEffectorJoints = self.DetermineJointState(endEffectorPose);
            
            % check if the robot is already there
            distanceToPoint = DistanceHelpers.DistanceOfTwoSE3Points(currentEndEffector, endEffectorPose);
            if(distanceToPoint < 0.05)
                 self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Robot is already at that point", distanceToPoint ]};
                return;
            end

            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                ["Starting Robot animation from", self.logger.MatrixToString(currentJoints),...
                "to",self.logger.MatrixToString(endEffectorJoints)]};

            robotTraj = jtraj(currentJoints,endEffectorJoints,steps);

            for i = 1:steps
                robot.model.animate(robotTraj(i,:));
                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Robot at joint pos", self.logger.MatrixToString(robotTraj(i,:))]};
                drawnow();
            end
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Animation Done"};
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
            homePose = self.robot_UR3e.model.fkine(self.robot_UR3e.homeQ).T;
            self.AnimateRobot(homePose,40);
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Reset system"};
        end

        function Teach(self)
        % Brings up the "teach" pane for each robot
            % self.Reset()
            % self.robot_UR3e.model.teach(self.robot_UR3e.homeQ);
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
