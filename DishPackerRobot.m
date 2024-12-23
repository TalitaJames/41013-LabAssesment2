classdef DishPackerRobot < handle

    properties (Constant)
        GRAPHIC_FILEPATH = "graphical_models/";
        RVCTOOLS_FILEPATH = "rvctools/robot/UTS/Parts/";
    end

    properties (SetAccess = private) % private variables
        robot_UR3e
        robot_gantry

        logger = log4matlab("out/"+ datestr(now,'yyyymmdd-HHMM') +".log"); %#ok<TNOW1,*DATST>

        arduinoObject = arduino('/dev/ttyACM0','Uno')
        arduinoButtonCheck
        timer
        
        % Plate data
        plate_h
        plate_startXYZ
        plate_currentPose
        plate_handoverXYZ
        plate_endXYZ
        plate_doneStatus

        % Safety data
        eStopStatus = false;

        % Safety data
        lightCurtainCheck

        % All enviroment handles
        enviroment_h;
        floor_h
        barrier1_h
        barrier2_h
        WarningLight_h

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

            % Create the safety barriers
            self.barrier1_h = PlaceObject(self.RVCTOOLS_FILEPATH+"barrier1.5x0.2x1m.ply",[-1,-0.45,0]);
            self.barrier2_h = PlaceObject(self.RVCTOOLS_FILEPATH+"barrier1.5x0.2x1m.ply",[-1.7,0.2,0]);
            rotate(self.barrier2_h,[0 0 1],90,[-1.7 0.2 0]);

            % Create the light
            self.WarningLight_h = PlaceObject(self.GRAPHIC_FILEPATH+"alarm.ply",[-1.9,0.3,0.8]);
            HandleManipulation.Scale(self.WarningLight_h, 0.001);

            % Place the plates
            %plateCount - How many plates to stack
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
        
        function blocked = LightCurtain()
        %Checks if something has passed the sensor
            %etc
            %mainly for simulated integration but needs to exist for arduino too
            blocked = false;
        end

        function StopMovement()
        % Should store current function for resume capabilities, and stop
        % all movement until ButtonPress() clears
        % and should flash light
            ButtonCheck = parfeval(backgroundPool,@ButtonPress,1);
            ButtonValue = fetchOutputs(ButtonCheck);
            %etc

            %Flash = light("Style","Local","Position",[-1.9 0.3 0.8],"Color",[1 0 0]);
        end

        function ReadArduinoButton(self)
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Checking Button"};

            if ( boolean(readDigitalPin(self.arduinoObject,'D2')) )
                self.gui.EStopPressed();
            end
        end
    end

    methods (Access = public)
        function obj = DishPackerRobot()
        % Construct a DishPacker Object
            obj.SetupEnviroment(7);
            obj.lightCurtainCheck = parfeval(backgroundPool,@obj.LightCurtain,1);

            % Create the timer
            obj.timer = timer;
            obj.timer.ExecutionMode = 'fixedRate';
            obj.timer.Period = 0.75; %[sec]
            obj.timer.TimerFcn = @(~,~) obj.ReadArduinoButton(); % Call function to check pin

            start(obj.timer);
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

        function AnimateRobotWithJointAngles(self, robot, endJointAngles, steps, plateID)
        % Animates given robot from its current position to end
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Animating a robot with joint angles"};

            currentJoints = robot.model.getpos;
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                ["Starting Robot animation from", self.logger.MatrixToString(currentJoints),...
                "to",self.logger.MatrixToString(endJointAngles)]};

            robotTraj = jtraj(currentJoints,endJointAngles,steps);

             if exist('plateID','var')
                 % third parameter does not exist, so default it to something
                  plate_handle = self.plate_h(plateID);
             end

            for i = 1:steps
                if(self.eStopStatus)
                    return;
                end

                q = robotTraj(i,:);
                %self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                %    ["Robot at joint pos", self.logger.MatrixToString(q)]};

                % Move the robot
                robot.model.animate(q);
                currentEndEffector = robot.model.fkine(q).T;
                
                if exist('plateID','var')
                    % Move the plate
                    HandleManipulation.SetPose(plate_handle, currentEndEffector,self.plate_currentPose(:,:,plateID));
                    self.plate_currentPose(:,:,plateID) = currentEndEffector; % Update current pose
                end
                
                drawnow();
            end

        end

        function AnimateRobotWithEndEffector(self, robot, endEffectorPose, steps, plateID)
        % Animates given robot from its current position to end
            [poseReachable, endEffectorJoints] = self.CanReachPose(robot,endEffectorPose);
            if (not(poseReachable))
                self.logger.mlog = {self.logger.WARN, mfilename('class'), ...
                    "Position Invalid"};
                return;
            end

            % if the end joints exist, run the function
            % (only pass plateID if it exists)
            if exist('plateID','var')
                self.AnimateRobotWithJointAngles(robot, endEffectorJoints, steps, plateID);
            else
                self.AnimateRobotWithJointAngles(robot, endEffectorJoints, steps); 
            end
        end

        function MoveAll(self)
            % Moves all plates to end
            for i = 1:length(self.plate_doneStatus)
                if(not(self.plate_doneStatus(i)))
                    self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                        ["Moving Plate ",i]};
                    self.MovePlate(i);
                else
                    self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                        ["Plate already there!",i]};
                end
            end
        end

        function MovePlate(self, plateID)
        % Takes a plate from the start to its expected position using both robots
            if(not(self.eStopStatus))
                steps = 50;
                plateCurrentPose = self.plate_currentPose(:,:,plateID);

                self.AnimateRobotWithEndEffector(self.robot_UR3e, plateCurrentPose, steps);
                self.AnimateRobotWithEndEffector(self.robot_UR3e, self.plate_handoverXYZ, ...
                    steps, plateID);
                % bring gantry to shared location
                % Animate the gantry to put away the plate
                % current plate location is now at end

                if(DistanceHelpers.DistanceOfTwoSE3Points(self.plate_currentPose(:,:,plateID), ...
                        transl(self.plate_endXYZ(plateID,:)) ) < 0.05 )
                    self.plate_doneStatus(plateID) = true; % plate is away!
                end

                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    ["Done Moving Plate!",plateID]};
            else
                self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                    "Can't Move - Estop Enabled!"};
            end
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
            self.plate_doneStatus = false(1, length(self.plate_h)); % none of the plates are placed

            % Robots go home
            homePose = self.robot_UR3e.model.fkine(self.robot_UR3e.homeQ).T;
            self.AnimateRobotWithEndEffector(self.robot_UR3e, homePose, 5);

            self.eStopStatus = false;
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
            self.eStopStatus = not(self.eStopStatus);
            self.logger.mlog = {self.logger.WARN, mfilename('class'), ...
                ["EStop Pressed, status", self.eStopStatus]};
        end

        function Chaos(self, e)
            self.AnimateRobotWithEndEffector(self.robot_UR3e, e, 50);
        end

        function delete(self)
        % Deletes the object, including all ascocisated handles & data
            self.logger.mlog = {self.logger.DEBUG, mfilename('class'), ...
                "Deleting object"};
            delete(self.gui);
            delete(self.timer);
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
