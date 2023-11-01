classdef collisionBlock < handle

    properties
        vertex;
    end

    properties (Access=private)
        boxMesh;
        vertexColours;
        faces; 
        updatedVertex;
    end

    methods
        function self = collisionBlock(self)
            [self.faces,self.vertex,data] = plyread('collision_block.ply','tri');
            self.vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            self.vertex(:,1) = self.vertex(:,1) + 0.2;
            self.vertex(:,2) = self.vertex(:,2) + 0.2;
            self.vertex(:,3) = self.vertex(:,3) - 0.2;
        end

        function plotBlock(self)
            self.boxMesh = trisurf(self.faces, self.vertex(:,1), self.vertex(:,2), self.vertex(:,3) ...
                ,'FaceVertexCData',self.vertexColours,'EdgeColor','none','EdgeLighting','none');
            light('style', 'local', 'Position', [-2 1 1]);

        end

        function liftBlock(self)   

            for i = 0.01 :0.02 : 0.2

                delete(self.boxMesh);

                self.updatedVertex = self.vertex(:,3) + i;

                self.boxMesh = trisurf(self.faces, self.vertex(:,1), self.vertex(:,2), self.updatedVertex ...
                    ,'FaceVertexCData',self.vertexColours,'EdgeColor','none', 'EdgeLighting','none');
                pause(0.5);
                
            end

        end

        function lowerBlock(self)

            for i = 0.2 : -0.02: 0.01
                delete(self.boxMesh);

                self.updatedVertex = self.vertex(:,3) + i;

                self.boxMesh = trisurf(self.faces, self.vertex(:,1), self.vertex(:,2), self.updatedVertex ...
                    ,'FaceVertexCData',self.vertexColours,'EdgeColor','none', 'EdgeLighting','none');
                pause(0.5);
            end
        end


    end


end