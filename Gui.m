classdef Gui < handle
    properties
        f
        g_f

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
        action_human_approach_arm
        action_human_approach_cupboard

        status = "STANDBY"
    end

    methods
        function self = Gui() 
            XYZ = ['X', 'Y', 'Z'];
            self.nlinks_arm = 6;
            self.nlinks_gantry = 6;
            self.f = uifigure('Name', 'Dish packer robot GUI');
            self.g_f = uigridlayout(self.f, [1 3], 'RowHeight', {'fit'}, 'ColumnWidth', {'1x', '1x', '1x'});

            self.p_arm = uipanel(self.g_f, 'Title', 'Arm', 'Scrollable', 'on');
            self.g_arm = uigridlayout(self.p_arm, [3 1], 'RowHeight', {'fit', 'fit', 'fit'});
            self.p_arm_q = uipanel(self.g_arm, 'Title', 'Joint positions');
            self.g_arm_q = uigridlayout(self.p_arm_q, [2 1], 'RowHeight', {'fit', 20});
            self.g_arm_qs = uigridlayout(self.g_arm_q, [self.nlinks_arm 2], 'ColumnWidth', {'fit', '1x'});
            self.qs_label_arm = cell(self.nlinks_arm, 1);
            self.qs_edit_arm = cell(self.nlinks_arm, 1);
            for i = 1:self.nlinks_arm
                self.qs_label_arm{i} = uilabel(self.g_arm_qs, 'Text', sprintf('%d', i));
                self.qs_edit_arm{i} = uieditfield(self.g_arm_qs, 'numeric', 'Value', 0);
            end
            self.q_go_arm = uibutton(self.g_arm_q, 'Text', 'Go', 'ButtonPushedFcn', @(src, evt) self.ArmQGoPressed());
            self.p_arm_x = uipanel(self.g_arm, 'Title', 'End effector position');
            self.g_arm_x = uigridlayout(self.p_arm_x, [2 1], 'RowHeight', {'fit', 20});
            self.g_arm_xs = uigridlayout(self.g_arm_x, [3 2], 'ColumnWidth', {'fit', '1x'});
            for i = 1:3
                self.xs_label_arm{i} = uilabel(self.g_arm_xs, 'Text', XYZ(i));
                self.xs_edit_arm{i} = uieditfield(self.g_arm_xs, 'numeric', 'Value', 0);
            end
            self.x_go_arm = uibutton(self.g_arm_x, 'Text', 'Go', 'ButtonPushedFcn', @(src, evt) self.ArmXYZGoPressed());

            self.p_gantry = uipanel(self.g_f, 'Title', 'Gantry', 'Scrollable', 'on');
            self.g_gantry = uigridlayout(self.p_gantry, [3 1], 'RowHeight', {'fit', 'fit', 'fit'});
            self.p_gantry_q = uipanel(self.g_gantry, 'Title', 'Joint positions');
            self.g_gantry_q = uigridlayout(self.p_gantry_q, [2 1], 'RowHeight', {'fit', 20});
            self.g_gantry_qs = uigridlayout(self.g_gantry_q, [self.nlinks_gantry 2], 'ColumnWidth', {'fit', '1x'});
            self.qs_label_gantry = cell(self.nlinks_gantry, 1);
            self.qs_edit_gantry = cell(self.nlinks_gantry, 1);
            for i = 1:self.nlinks_gantry
                self.qs_label_gantry{i} = uilabel(self.g_gantry_qs, 'Text', sprintf('%d', i));
                self.qs_edit_gantry{i} = uieditfield(self.g_gantry_qs, 'numeric', 'Value', 0);
            end
            self.q_go_gantry = uibutton(self.g_gantry_q, 'Text', 'Go');
            self.p_gantry_x = uipanel(self.g_gantry, 'Title', 'End effector position');
            self.g_gantry_x = uigridlayout(self.p_gantry_x, [2 1], 'RowHeight', {'fit', 20});
            self.g_gantry_xs = uigridlayout(self.g_gantry_x, [3 2], 'ColumnWidth', {'fit', '1x'});
            for i = 1:3
                self.xs_label_gantry{i} = uilabel(self.g_gantry_xs, 'Text', XYZ(i));
                self.xs_edit_gantry{i} = uieditfield(self.g_gantry_xs, 'numeric', 'Value', 0);
            end
            self.x_go_gantry = uibutton(self.g_gantry_x, 'Text', 'Go');

            self.p_actions = uipanel(self.g_f, 'Title', 'Actions');
            self.g_actions = uigridlayout(self.p_actions, [5 1], 'RowHeight', {'fit', 'fit', 'fit', 'fit', 'fit'}, 'Scrollable', 'on');
            self.status_label = uilabel(self.g_actions, 'Text', 'Status STANDY');
            self.action_estop = uibutton(self.g_actions, 'Text', 'Emergency stop', 'FontColor', 'white', 'BackgroundColor', 'red', 'ButtonPushedFcn', @(src, evt) self.EStopPressed());
            self.action_demo = uibutton(self.g_actions, 'Text', 'Demo');
            self.action_human_approach_arm = uibutton(self.g_actions, 'Text', 'Show human approaching arm');
            self.action_human_approach_cupboard = uibutton(self.g_actions, 'Text', 'Show human approaching cupboard');
        end

        function ArmQGoPressed(self)
            disp("Move arm q")
            for i = 1:self.nlinks_arm
                edit = self.qs_edit_arm{i};
                edit.Value = 1;
            end
            for i = 1:3
                edit = self.xs_edit_arm{i};
                edit.Value = 0;
            end
        end

        function ArmXYZGoPressed(self)
            disp("Move arm xyz")
            for i = 1:self.nlinks_arm
                edit = self.qs_edit_arm{i};
                edit.Value = 0;
            end
            for i = 1:3
                edit = self.xs_edit_arm{i};
                edit.Value = 1;
            end
        end

        function EStopPressed(self)
            if self.status == "STANDBY"
                self.DoEstop();
            else
                self.UndoEstop();
            end
            self.UpdateStatusText();
        end

        function UpdateStatusText(self)
            self.status_label.Text = sprintf("Status %s", self.status);
        end

        function DoEstop(self)
            self.status = "ESTOP";
        end

        function UndoEstop(self)
            self.status = "STANDBY";
        end
    end
end
