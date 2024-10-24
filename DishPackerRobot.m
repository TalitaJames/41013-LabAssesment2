classdef DishPackerRobot < handle
    properties (Constant)
      
    end

    properties (SetAccess = private) % private variables
        robot_UR3e
        robot_gantry
        logger = log4matlab("out/"+ datestr(now,'yyyymmdd-HHMM') +".log"); %#ok<TNOW1,*DATST>

        % All enviroment handles
        enviroment_h;
        floor_h
        table_h;
        eStopFace_h;
    end

    methods (Access = private)
        function SetupEnviroment(self)
        % Create the enviroment, setup robots, place plates ect
            hold on;
            %axis equal;
            view(3);

            % Place the robots
            self.robot_UR3e = UR3e;

            % move the robot to inital position of on the table at "home"
            self.robot_UR3e.model.base = transl(1.7,0.8,0.7) * self.robot_UR3e.model.base.T;
            self.robot_UR3e.model.animate(self.robot_UR3e.homeQ);

            % Create the enviroment
            self.enviroment_h = PlaceObject("graphical_models/environment.ply",[1.75,1,0]);
            % plate_h = PlaceObject("graphical_models/plate.ply",[1.5,1,0]);
            % HandleManipulation.ScaleHandle(plate_h, 0.01);
            % self.envroment_h = PlaceObject("graphical_models/glass.ply",[1.5,0.6,0]);
            % HelperFunctions.RotateHandle(self.personTwo_h,trotz(pi/2))

           self.floor_h = surf([-1,-1; 3,3]... % X
                ,[-2, 3;-2,3] ... % Y
                ,[ 0.0, 0.0; 0.0,0.0] ... % Z
                ,'CData',imread('graphical_models/floor-texture.png') ...
                ,'FaceColor','texturemap');
            %self.eStopFace_h = PlaceObject("rvctools/robot/UTS/Parts/emergencyStopButton.ply",[0.9,-0.55,0.5-0.15]);
            %self.eStopFace_h = PlaceObject("rvctools/robot/UTS/Parts/tableBrown2.1x1.4x0.5m.ply",[0.9,-0.55,0.5-0.15]);

            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), "The enviroment has been created"};
        end
    end

    methods (Access = public)
        function obj = DishPackerRobot()
        % Construct a DishPacker Object
            obj.SetupEnviroment();
        end

        function [isValid, endEffectorJoints] = canReachPose(self, robot, endEffectorPose)
            isValid = false;

            currentJoints = robot.model.getpos;
            currentEndEffectorPose = robot.model.fkine(currentJoints).T;

            % check if the robot is already there
            distanceToPoint = DistanceHelpers.DistanceOfTwoSE3Points(currentEndEffectorPose, endEffectorPose);
            if(distanceToPoint <= 0.05)
                 self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Robot is already there, ", distanceToPoint, "m away"]};
                return;
            end

            endEffectorJoints = robot.model.ikine(endEffectorPose);

            % check if the robot is able to reach this point
            if isempty(endEffectorJoints)
                self.logger.mlog = {self.logger.ERROR, mfilename('class'), ...
                    ["Robot can't reach point", self.logger.MatrixToString(endEffectorPose)]};
                return;

            % if Q is same (or very close) then position must be same
            elseif (abs(sum(endEffectorJoints-currentJoints)) < 1e-4)
                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Robot Q and end Q is same!, difference total of", sum(endEffectorJoints-currentJoints)]};
                return;
            end

            isValid = true;
        end

        function AnimateRobot(self, robot, endEffectorPose, steps)
        % Animates given robot from its current position to end
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Animating a robot"};

            [poseReachable, endEffectorJoints] = self.canReachPose(robot,endEffectorPose);
            if (not(poseReachable))
                self.logger.mlog = {self.logger.WARN, mfilename('class'), ...
                    "Position Invalid"};
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

            currentJoints = robot.model.getpos;
            currentEndEffectorPose = robot.model.fkine(currentJoints).T;
            distanceToPoint = DistanceHelpers.DistanceOfTwoSE3Points(currentEndEffectorPose, endEffectorPose);
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                ["Animation done, finished total of ", distanceToPoint, "m from goal"]};
        end

        function AnimateRobotWithObj(self, robot, endEffectorPose, steps, handle)
        % Animates given robot from its current position to end, bringing a
        % handle at the position of the end efector

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
            self.robot_UR3e.model.teach(self.robot_UR3e.homeQ);
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Teaching pannel is now visable"};
        end
        
        function Chaos(self, e)
            self.AnimateRobot(self.robot_UR3e, e, 50);
        end

        function delete(self)
        % Deletes the object, including all ascocisated handles & data
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Deleting object"};
        end

    end
end
