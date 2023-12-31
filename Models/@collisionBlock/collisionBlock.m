classdef collisionBlock < handle

    properties
        vertex;
        visVertex; 
        
    end

    properties (Access=private)
        boxMesh;
        vertexColours;
        faces; 
        updatedVertex;
        boxLifted;
    end

    methods
        function self = collisionBlock(self)
            [self.faces,self.vertex,data] = plyread('collision_block.ply','tri');
            self.vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            self.vertex(:,1) = self.vertex(:,1) + 0.2;
            self.vertex(:,2) = self.vertex(:,2) + 0.2;
            self.vertex(:,3) = self.vertex(:,3) - 0.2;
            self.boxLifted = 0;
            self.visVertex = self.vertex;
        end

        function plotBlock(self)
            self.boxMesh = trisurf(self.faces, self.vertex(:,1), self.vertex(:,2), self.vertex(:,3) ...
                ,'FaceVertexCData',self.vertexColours,'EdgeColor','none','EdgeLighting','none');
            light('style', 'local', 'Position', [-2 1 1]);

        end

        function liftBlock(self)   
            
            if self.boxLifted == 0
                for i = 0.01 :0.04 : 0.4
    
                    delete(self.boxMesh);
    
                    self.updatedVertex = self.vertex(:,3) + i;
                    self.visVertex(:,3) = self.updatedVertex;
    
                    self.boxMesh = trisurf(self.faces, self.vertex(:,1), self.vertex(:,2), self.updatedVertex ...
                        ,'FaceVertexCData',self.vertexColours,'EdgeColor','none', 'EdgeLighting','none');
                    pause(0.5);
                end
                self.boxLifted = 1;
            end
        end

        function lowerBlock(self)
            
            if self.boxLifted == 1
                for i = 0.4 : -0.04: 0.01
                    delete(self.boxMesh);
    
                    self.updatedVertex = self.vertex(:,3) + i;
                    self.visVertex(:,3) = self.updatedVertex;
    
                    self.boxMesh = trisurf(self.faces, self.vertex(:,1), self.vertex(:,2), self.updatedVertex ...
                        ,'FaceVertexCData',self.vertexColours,'EdgeColor','none', 'EdgeLighting','none');
                    pause(0.5);
                end
                 self.boxLifted = 0;
            end
        end


    end


end