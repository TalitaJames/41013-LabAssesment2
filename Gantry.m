classdef Gantry < handle
    properties
        name
        model
        homeQ
        drawn_n
        drawn_links
        model_vertices
        model_vertex_colours
        model_faces
        h_group
        h_link
    end
    methods
        function self = Gantry(baseTr)
            link(1) = Link([0      0           0        pi/2    1]);
            link(2) = Link([-pi/2  0           0       -pi/2    1]);
            link(3) = Link([0      0           0        0       1]);

            link(1).qlim = [0 0.6];
            link(2).qlim = [0 1.3];
            link(3).qlim = [0 0.3];

            self.name = 'Gantry';
            self.model = SerialLink(link, 'name', self.name, 'base', baseTr);
            self.homeQ = [0 0 0];
            self.drawn_links = {0, 1, 2, 3};
            self.drawn_n = length(self.drawn_links);
            self.h_group = gobjects();
            self.h_link = gobjects(1, self.drawn_n);
 
            for i = 1:self.drawn_n
                linkIndex = self.drawn_links{i};
                [ faceData, vertexData, data] = plyread(sprintf("graphical_models/gantry_link%i.ply", linkIndex),'tri');
                self.model_vertex_colours{i} = [data.vertex.red, data.vertex.green, data.vertex.blue] / 256;
                self.model_faces{i} = faceData;
                self.model_vertices{i} = vertexData;
            end   
        end

        function init_plot(self)
            self.h_group = hggroup('Tag', self.name);
            for i = 1:self.drawn_n
                self.h_link(i) = hgtransform('Parent', self.h_group);
                patch('Faces', self.model_faces{i}, 'Vertices', self.model_vertices{i}, ...
                    'FaceVertexCData', self.model_vertex_colours{i}, 'FaceColor', 'interp', 'EdgeAlpha', 0, ...
                    'Parent', self.h_link(i));
            end
        end

        function plot3d(self, q)
            [~, Ts] = self.model.fkine(q);
            for i = 1:self.drawn_n
                idx = self.drawn_links{i};
                h = self.h_link(i);
                if idx == 0
                    T = self.model.base;
                else
                    T = Ts(idx);
                end
                h.Matrix = T.T;
            end
        end
    end
end