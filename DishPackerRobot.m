classdef DishPackerRobot < handle

    properties (Constant)
        GRAPHIC_FILEPATH = "graphical_models/";
    end

    properties (SetAccess = private) % private variables
        robot_UR3e
        robot_gantry
        logger = log4matlab("out/"+ datestr(now,'yyyymmdd-HHMM') +".log"); %#ok<TNOW1,*DATST>
        
        % Plate data
        plate_h
        plate_startXYZ
        plate_currentPose
        plate_handoverXYZ
        plate_endXYZ

        % Safety data
        eStopStatus

        % All enviroment handles
        enviroment_h;
        floor_h

        gui % the graphical user interface
    end

    methods (Access = private)
        function SetupEnviroment(self, plateCount)
        % Create the enviroment, setup robots, place plates and other ply files
            hold on; % Put all the objects on the same plot
            %axis equal;
            view(3); %3D Perspective

            % Place the robots
            self.robot_UR3e = UR3e(transl(-0.1, -0.2, 0.7));
            self.robot_gantry = Gantry(transl(-1, -0.6, 0.7));

            % Create the enviroment
            self.enviroment_h = PlaceObject(self.GRAPHIC_FILEPATH+"environment.ply",[0,0,0]);

            % Place the plates
            %plateCount = 7; % How many plates to stack
            self.plate_startXYZ = DishPackerRobot.GeneratePlatePositions(transl(-0.25, 0, 0.7), ...
                                    15/1000, plateCount); % Generate [[x1,y1,z1], ... [xn,yn,zn]] start positions
            self.plate_currentPose = zeros(4,4,plateCount); % This is initialised here, set in Reset()

            % TODO this should have an intermediete transition between two
            % points then the final points (all unique not same pos)
            self.plate_handoverXYZ = transl(-0.314,-0.423,1.1);
            finalPlate = [-0.314,-0.423,1.1]; % where are the plates expexted to go
            self.plate_endXYZ = repmat(finalPlate, plateCount,1); %ie cupboard positions



            self.floor_h = surf([-1,-1; 3,3]... % X
                ,[-2, 3;-2,3] ... % Y
                ,[ 0.0, 0.0; 0.0,0.0] ... % Z
                ,'CData',imread(self.GRAPHIC_FILEPATH+"floor-texture.png") ...
                ,'FaceColor','texturemap'); % Make the floor cocer that x,y,z plane, with that image

            self.Reset() % Finalises plate placement, colouring
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), "The enviroment has been created"};
        end
    end

    methods (Access = public)
        function obj = DishPackerRobot()
        % Construct a DishPacker Object
            obj.SetupEnviroment(7);
        end

        function [isValid, endEffectorJoints] = CanReachPose(self, robot, endEffectorPose)
        % Checks if a given robot can go to a given pose
            isValid = false;
            endEffectorJoints = 0; % if already there, data is required in return vars

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

        function AnimateRobotWithJointAngles(self, robot, endJointAngles, steps)
        % Animates given robot from its current position to end
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Animating a robot with joint angles"};

            currentJoints = robot.model.getpos;
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                ["Starting Robot animation from", self.logger.MatrixToString(currentJoints),...
                "to",self.logger.MatrixToString(endJointAngles)]};

            robotTraj = jtraj(currentJoints,endJointAngles,steps);

            for i = 1:steps
                robot.model.animate(robotTraj(i,:));
                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Robot at joint pos", self.logger.MatrixToString(robotTraj(i,:))]};
                drawnow();
            end
        end

        function AnimateRobotWithEndEffector(self, robot, endEffectorPose, steps)
        % Animates given robot from its current position to end
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Animating a robot"};

            [poseReachable, endEffectorJoints] = self.CanReachPose(robot,endEffectorPose);
            if (not(poseReachable))
                self.logger.mlog = {self.logger.WARN, mfilename('class'), ...
                    "Position Invalid"};
                return;
            end

            currentJoints = robot.model.getpos;
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

        function AnimateRobotWithPlate(self, robot, endEffectorPose, steps, plateID)
        % Animates given robot from its current position to end, bringing a
        % handle at the position of the end efector

            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Animating a robot with object"};

            [poseReachable, endEffectorJoints] = self.CanReachPose(robot,endEffectorPose);
            if (not(poseReachable))
                self.logger.mlog = {self.logger.WARN, mfilename('class'), ...
                    "Position Invalid"};
                return;
            end

            currentJoints = robot.model.getpos;
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                ["Starting Robot & Obj animation from", self.logger.MatrixToString(currentJoints),...
                "to",self.logger.MatrixToString(endEffectorJoints)]};

            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                ["Starting Robot animation from", self.logger.MatrixToString(currentJoints),...
                "to",self.logger.MatrixToString(endEffectorJoints)]};

            robotTraj = jtraj(currentJoints,endEffectorJoints,steps);
            handle = self.plate_h(plateID);

            for i = 1:steps
                q = robotTraj(i,:);

                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Moving robot to joint pos", self.logger.MatrixToString(q)]};

                % Move the robot
                robot.model.animate(q);
                currentEndEffector = robot.model.fkine(q).T;

                % Move the plate
                HandleManipulation.SetPose(handle, currentEndEffector,self.plate_currentPose(:,:,plateID));
                self.plate_currentPose(:,:,plateID) = currentEndEffector; % Update current pose
                drawnow();
            end

            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Animation Done"};

        end

        function MovePlate(self, plateID)
        % Takes a plate from the start to its expected position using both robots
            steps = 50;
            plateCurrentPose = self.plate_currentPose(:,:,plateID);

            self.AnimateRobotWithEndEffector(self.robot_UR3e, plateCurrentPose, steps);
            self.AnimateRobotWithPlate(self.robot_UR3e, self.plate_handoverXYZ, ...
                steps, plateID);
            % bring gantry to shared location
            % Animate the gantry to put away the plate
            % current plate location is now at end
        end

        function Reset(self)
        % Resets the whole system to its "home" positions

             % place the plates back
            try delete(self.plate_h);end %#ok<TRYNC>

            self.plate_h = PlaceObject(self.GRAPHIC_FILEPATH+"plate.ply", self.plate_startXYZ);
            for i = 1:length(self.plate_h) % Colour all plates orange and set current pose
                HandleManipulation.SetColour(self.plate_h(i), [77, 184, 255])
                self.plate_currentPose(:,:,i) = transl(self.plate_startXYZ(i,:));
            end

            % Robots go home
            homePose = self.robot_UR3e.model.fkine(self.robot_UR3e.homeQ).T;
            self.AnimateRobotWithEndEffector(self.robot_UR3e, homePose, 5);

            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Reset system"};
        end

        function Teach(self)
        % Brings up the "teach" pane for each robot
            self.Reset()
            if isempty(self.gui)
                self.gui = Gui(self);
                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Teaching pane created"};
                return;
            end
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Teaching pane exists"};
        end

        function EStop(self)
            disp("Estop Pressed!")
            self.logger.mlog = {self.logger.WARN, mfilename('class'), ...
                "EStop Pressed!"};
        end

        function Chaos(self, e)
            self.AnimateRobotWithEndEffector(self.robot_UR3e, e, 50);
        end

        function delete(self)
        % Deletes the object, including all ascocisated handles & data
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Deleting object"};
            delete(self.gui);
            close('all','force')
        end

    end

    methods (Static)
        function [platePositions] = GeneratePlatePositions(startPos, height, count)
        % work out the starting center of each (count) plates

            platePositions = zeros(count,3);
            startXYZ = startPos(1:3, 4);  % The translation part
            for i = 1:count
                platePositions(i,:) = [startXYZ(1),startXYZ(2),(startXYZ(3)+height*(i-1))];
            end

            platePositions = flip(platePositions); % make them stack top to bottom
        end
    end
end
