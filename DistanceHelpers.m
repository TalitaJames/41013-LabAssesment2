classdef DistanceHelpers

    methods(Static)

        % ---------- Distance -----------
        function [distance] = DistanceOfTwoSE2Points(A, B)
            distance = sqrt(sum((A(1:2,3) - B(1:2,3) ).^2));
        end

        function [distance] = DistanceOfTwoSE3Points(A, B)
            distance = sqrt(sum((A(1:3,4) - B(1:3,4) ).^2));
        end

    end
end