classdef HandleManipulation
    % A collection of static methods to manipulate a handle
    % (primarily plotted .ply) files.
    % It involves moving and getting info from them

    methods(Static)

           function Translate(handle, transformation)
            % Move handle (.ply) by an adjustment factor "transformation"

            vertices = get(handle,'Vertices');
            moveXYZ = transpose(transformation(1:3,4));
            translatedVertices = bsxfun(@plus, vertices, moveXYZ);
            set(handle,'Vertices',translatedVertices);
        end

        function AbsoluteTranslation(handle, transformation)
            % Move handle (.ply) to a new position "transformation"

            vertices = get(handle,'Vertices');
            currentCenter = mean(vertices);
            newCenter = transpose(transformation(1:3,4));
            translation = newCenter - currentCenter;
            HandleManipulation.Translate(handle, transl(translation));

        end

        function Rotate(handle, transformation)
            % Rotate handle (.ply) by some "transformation" value

            vertices = get(handle, 'Vertices');

            rotationMatrix = transformation(1:3, 1:3);

            % Subtract the current center, apply rotation, and re-add the center
            currentCenter = mean(vertices);
            centeredVertices = bsxfun(@minus, vertices, currentCenter); 
            rotatedVertices = (rotationMatrix * centeredVertices')';     % Rotate them
            recenteredVertices = bsxfun(@plus, rotatedVertices, currentCenter);  % Re-center

            set(handle, 'Vertices', recenteredVertices);
        end

        function AbsoluteRotation(handle, targetPose, currentPose)
            % RotatePatchToTarget rotates a handle(.ply) to the target pose
            % handle: Handle to the .ply
            % targetPose: 4x4 homogeneous transformation matrix of the target pose
            % currentPose: 4x4 homogeneous transformation matrix of the current pose

            % Extract rotation components (3x3 rotation matrices)
            targetRotation = targetPose(1:3, 1:3);
            currentRotation = currentPose(1:3, 1:3);

            % Calculate the relative rotation needed to align currentPose to targetPose
            relativeRotation = targetRotation * currentRotation';

            % Get current verticies and recenter them
            currentVertices = get(handle, 'Vertices');
            centerPoint = mean(currentVertices, 1); % Find the center point of the patch
            centeredVertices = currentVertices - centerPoint; % Shift vertices to the origin

            % Apply the relative rotation to centered vertices
            rotatedVertices = (relativeRotation * centeredVertices')';  % Note the transposition

            % Do the rotation
            rotatedVertices = rotatedVertices + centerPoint; % place them back at actual center
            set(handle, 'Vertices', rotatedVertices);
        end

        function SetPose(handle, targetPose, currentPose)
            HandleManipulation.AbsoluteTranslation(handle, targetPose);
            HandleManipulation.AbsoluteRotation(handle, targetPose, currentPose);
        end

        function Scale(handle, scale)
            % Uniformly resize handle (.ply) by some "scale" value
            vertices = get(handle,'Vertices');
            scaledVertices = vertices * scale;
            set(handle,'Vertices',scaledVertices);
        end

        function [positions] = GetPositions(handle)
            % returns an array [minX, minY, minZ; maxX, maxY, maxZ] of
            % the given handle dimensions
            vertices = get(handle,'Vertices');

            positions = [min(vertices)
                         max(vertices)];
        end

        function SetColour(handle, RGB)
            % SetColour changes the color of a 3D object (.ply)
            % RGB: 1x3 array specifying the desired color as [R G B], values from 0 to 1
        
            % Ensure RGB is in the range [0, 1] if provided as [0, 255]
            if max(RGB) > 1
                RGB = RGB / 255;
            end

            % Set the color for each face
            faces = get(handle, 'Faces');
            faceColors = repmat(RGB, size(faces, 1), 1); % repeat the matrix per face
            set(handle, 'FaceVertexCData', faceColors, 'FaceColor', 'flat');
        end

    end
end