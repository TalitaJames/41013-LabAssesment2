classdef Gui < handle
    properties
        % GUI Interface
        % p is for panel, g for grid

        figure
        grid_figure

        nlinks_arm = 6
        nlinks_gantry = 6

        p_arm
        g_arm
        p_arm_q
        g_arm_q
        g_arm_qs
        qs_label_arm
        qs_edit_arm
        q_go_arm
        p_arm_x
        g_arm_x
        g_arm_xs
        xs_label_arm
        xs_edit_arm
        x_go_arm

        p_gantry
        g_gantry
        p_gantry_q
        g_gantry_q
        g_gantry_qs
        qs_label_gantry
        qs_edit_gantry
        q_go_gantry
        p_gantry_x
        g_gantry_x
        g_gantry_xs
        xs_label_gantry
        xs_edit_gantry
        x_go_gantry

        p_actions
        g_actions
        status_label
        action_estop
        action_demo
        action_updatePositions
        action_reset
        action_human_approach_arm
        action_human_approach_cupboard

        status = "STANDBY"

        kitchenRobot % the attached kitchen robot
    end

    methods
        function self = Gui(kitchenRobot)
            self.kitchenRobot = kitchenRobot;

            % GUI Initialisation
            XYZ = ['X', 'Y', 'Z'];
            self.nlinks_arm = 6;
            self.nlinks_gantry = 6;
            self.figure = uifigure('Name', 'Dish packer robot GUI');
            self.grid_figure = uigridlayout(self.figure, [1 3], 'RowHeight', {'fit'}, 'ColumnWidth', {'1x', '1x', '1x'});

            % Arm
            self.p_arm = uipanel(self.grid_figure, 'Title', 'Arm', 'Scrollable', 'on');
            self.g_arm = uigridlayout(self.p_arm, [3 1], 'RowHeight', {'fit', 'fit', 'fit'});
            self.p_arm_q = uipanel(self.g_arm, 'Title', 'Joint Positions [Rad]');
            self.g_arm_q = uigridlayout(self.p_arm_q, [2 1], 'RowHeight', {'fit', 20});
            self.g_arm_qs = uigridlayout(self.g_arm_q, [self.nlinks_arm 2], 'ColumnWidth', {'fit', '1x'});
            self.qs_label_arm = cell(self.nlinks_arm, 1);
            self.qs_edit_arm = cell(self.nlinks_arm, 1);
            for i = 1:self.nlinks_arm
                self.qs_label_arm{i} = uilabel(self.g_arm_qs, 'Text', sprintf('%d', i));
                self.qs_edit_arm{i} = uieditfield(self.g_arm_qs, 'numeric', 'Value', 0);
            end
            self.q_go_arm = uibutton(self.g_arm_q, 'Text', 'Go', 'ButtonPushedFcn', @(src, evt) self.ArmQGoPressed());

            self.p_arm_x = uipanel(self.g_arm, 'Title', 'End Effector Position [m]');
            self.g_arm_x = uigridlayout(self.p_arm_x, [2 1], 'RowHeight', {'fit', 20});
            self.g_arm_xs = uigridlayout(self.g_arm_x, [3 2], 'ColumnWidth', {'fit', '1x'});
            for i = 1:3
                self.xs_label_arm{i} = uilabel(self.g_arm_xs, 'Text', XYZ(i));
                self.xs_edit_arm{i} = uieditfield(self.g_arm_xs, 'numeric', 'Value', 0);
            end
            self.x_go_arm = uibutton(self.g_arm_x, 'Text', 'Go', 'ButtonPushedFcn', @(src, evt) self.ArmXYZGoPressed());

            % Gantry
            self.p_gantry = uipanel(self.grid_figure, 'Title', 'Gantry', 'Scrollable', 'on');
            self.g_gantry = uigridlayout(self.p_gantry, [3 1], 'RowHeight', {'fit', 'fit', 'fit'});
            self.p_gantry_q = uipanel(self.g_gantry, 'Title', 'Joint Positions [Rad]');
            self.g_gantry_q = uigridlayout(self.p_gantry_q, [2 1], 'RowHeight', {'fit', 20});
            self.g_gantry_qs = uigridlayout(self.g_gantry_q, [self.nlinks_gantry 2], 'ColumnWidth', {'fit', '1x'});
            self.qs_label_gantry = cell(self.nlinks_gantry, 1);
            self.qs_edit_gantry = cell(self.nlinks_gantry, 1);
            for i = 1:self.nlinks_gantry
                self.qs_label_gantry{i} = uilabel(self.g_gantry_qs, 'Text', sprintf('%d', i));
                self.qs_edit_gantry{i} = uieditfield(self.g_gantry_qs, 'numeric', 'Value', 0);
            end
            self.q_go_gantry = uibutton(self.g_gantry_q, 'Text', 'Go', 'ButtonPushedFcn', @(src, evt) self.GantryQGoPressed());

            self.p_gantry_x = uipanel(self.g_gantry, 'Title', 'End Effector Position [m]');
            self.g_gantry_x = uigridlayout(self.p_gantry_x, [2 1], 'RowHeight', {'fit', 20});
            self.g_gantry_xs = uigridlayout(self.g_gantry_x, [3 2], 'ColumnWidth', {'fit', '1x'});
            for i = 1:3
                self.xs_label_gantry{i} = uilabel(self.g_gantry_xs, 'Text', XYZ(i));
                self.xs_edit_gantry{i} = uieditfield(self.g_gantry_xs, 'numeric', 'Value', 0);
            end
            self.x_go_gantry = uibutton(self.g_gantry_x, 'Text', 'Go', 'ButtonPushedFcn', @(src, evt) self.GantryXYZGoPressed());

            % Actions
            self.p_actions = uipanel(self.grid_figure, 'Title', 'Actions');
            self.g_actions = uigridlayout(self.p_actions, [6 1], 'RowHeight', {'fit', 'fit', 'fit', 'fit', 'fit', 'fit'}, 'Scrollable', 'on');

            self.status_label = uilabel(self.g_actions, 'Text', 'Status STANDY');
            self.action_estop = uibutton(self.g_actions, 'Text', 'Emergency stop', 'FontColor', 'white', 'BackgroundColor', 'red', 'ButtonPushedFcn', @(src, evt) self.EStopPressed());
            self.action_demo = uibutton(self.g_actions, 'Text', 'Demo', 'ButtonPushedFcn', @(src, evt) self.Demo());
            self.action_updatePositions = uibutton(self.g_actions, 'Text', 'Update Positions', 'ButtonPushedFcn', @(src, evt) self.UpdateAllPositions());
            self.action_reset = uibutton(self.g_actions, 'Text', 'Reset System', 'ButtonPushedFcn', @(src, evt) self.kitchenRobot.Reset());
            self.action_human_approach_arm = uibutton(self.g_actions, 'Text', 'Show human approaching arm');
            %self.action_human_approach_cupboard = uibutton(self.g_actions, 'Text', 'Show human approaching cupboard');
            

            self.UpdateAllPositions(); %set correct initial vals
        end

        % UR3e Movement
        function ArmQGoPressed(self)
            % Get the Q values
            qValues = zeros(1,self.nlinks_arm);
            for i = 1:self.nlinks_arm
                edit = self.qs_edit_arm{i}; % get the current 
                qValues(i) = edit.Value;
            end

            self.kitchenRobot.AnimateRobotWithJointAngles(self.kitchenRobot.robot_UR3e,qValues, 50);
            self.UpdateArmPosition();
        end

        function ArmXYZGoPressed(self)
            % get XYZ
            xyz=zeros(1,3);
            for i = 1:3
                edit = self.xs_edit_arm{i};
                xyz(i) = edit.Value;
            end

            self.kitchenRobot.AnimateRobotWithEndEffector(self.kitchenRobot.robot_UR3e, ...
                transl(xyz),50);
            self.UpdateArmPosition();
        end

        function UpdateArmPosition(self)
            % querie the UR3e (arm) robot and update position in textbox
            robot = self.kitchenRobot.robot_UR3e;

            armJoints = robot.model.getpos;
            armEndEffector = robot.model.fkine(armJoints).T;
            armXYZ = armEndEffector(1:3,4);


            % Update the Joint Positions
            %armJoints = rad2deg(robot.model.getpos);
            for i = 1:self.nlinks_arm
                edit = self.qs_edit_arm{i};
                edit.Value = armJoints(i);
            end

            % Update XYZ
            for i = 1:3
                edit = self.xs_edit_arm{i};
                edit.Value = armXYZ(i);
            end
        end


        %Gantry Movement
        function GantryQGoPressed(self)
            % Get the Q values
            qValues = zeros(1,self.nlinks_arm);
            for i = 1:self.nlinks_arm
                edit = self.qs_edit_gantry{i}; % get the current 
                qValues(i) = edit.Value;
            end
            
            self.UpdateGantryPosition();
        end

        function GantryXYZGoPressed(self)
            % get XYZ
            xyz=zeros(1,3);
            for i = 1:3
                edit = self.xs_edit_gantry{i};
                xyz(i) = edit.Value;
            end

            self.UpdateGantryPosition();
        end

        function UpdateGantryPosition(self)
            % querie the Gantry robot and update position in textbox
            robot = self.kitchenRobot.robot_gantry;

            armJoints = robot.model.getpos;
            armEndEffector = robot.model.fkine(armJoints).T;
            armXYZ = armEndEffector(1:3,4);

            % Update the Joint Positions
            %armJoints = rad2deg(robot.model.getpos);
            for i = 1:self.nlinks_arm
                edit = self.qs_edit_gantry{i};
                edit.Value = armJoints(i);
            end

            % Update XYZ
            for i = 1:3
                edit = self.xs_edit_gantry{i};
                edit.Value = armXYZ(i);
            end
        end

        % Action Buttons
        function EStopPressed(self)
            self.kitchenRobot.EStop()

            self.status = "STANDBY";
            if (self.kitchenRobot.eStopStatus)
                self.status = "ESTOP ON";
            else
                self.status = "STANDBY";
            end
            self.UpdateStatusText();
        end

        function Demo(self)
                self.kitchenRobot.MoveAll;
        end

        function UpdateAllPositions(self)
            self.UpdateGantryPosition();
            self.UpdateArmPosition();
        end

        function UpdateStatusText(self)
            self.status_label.Text = sprintf("Status %s", self.status);
        end

        
    end
end