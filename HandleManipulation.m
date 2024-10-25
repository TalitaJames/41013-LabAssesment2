classdef HandleManipulation

    methods(Static)

           function Translate(handle, transformation)
            % Move handle (.ply) by an adjustment factor "transformation"

            vertices = get(handle,'Vertices');
            moveXYZ = transpose(transformation(1:3,4));
            translatedVertices = bsxfun(@plus, vertices, moveXYZ);
            set(handle,'Vertices',translatedVertices);
        end

        function Move(handle, transformation)
            % Move handle (.ply) to a new position "transformation"

            vertices = get(handle,'Vertices');
            currentCenter = mean(vertices);
            newCenter = transpose(transformation(1:3,4));
            translation = newCenter - currentCenter;
            HandleManipulation.Translate(handle, transl(translation));

        end

        function Scale(handle, scale)
            % Uniformly resize handle (.ply) by some "scale" value
            vertices = get(handle,'Vertices');
            scaledVertices = vertices * scale;
            set(handle,'Vertices',scaledVertices);

            % recenter after scale
            currentCenter = mean(vertices);
            HandleManipulation.MoveHandle(handle, transl(currentCenter));
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

        function AbsoluteRotation(handle, transformation)
            % Set the rotation of handle (.ply) to some "transformation"
            warning("Calls Rotate and not absolute");
            HandleManipulation.Rotate(handle, transformation);
        end

        function [positions] = GetPositions(handle)
            % returns an array [minX, minY, minZ; maxX, maxY, maxZ] of
            % the given handle dimensions
            vertices = get(handle,'Vertices');

            positions = [min(vertices)
                         max(vertices)];
        end
    end
end