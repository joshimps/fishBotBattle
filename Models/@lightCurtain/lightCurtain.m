classdef lightCurtain < handle
    %brick A class that creates a herd of robot cows
    %   The cows can be moved around randomly. It is then possible to query
    %   the current location (base) of the cows.

    %#ok<*TRYNC>

    properties
        check;

    end

    properties (Access=private)
        curtain1;
        curtain2;
        x;
        y;
        x_min;
        x_max;
        z;
        laserStartPoint;
        laserEndPoint;
        bottomLeft;
        topRight;
        numLasers;
        vertex;
        handVertexCount;
        handMesh_h;
        Vertices;
        currentIndex;
        figure_message;
        curtainBlocked;
    end



    methods
        %% ...structors
        function self = lightCurtain(baseTr)
            if nargin < 1
                baseTr = eye(4);
            end

            self.x = baseTr(1,4);
            self.y = baseTr(2,4) - 0.3;
            self.x_min = baseTr(1,4) - 0.3;
            self.x_max = baseTr(1,4) + 0.3;
            self.z = 0;

            self.laserStartPoint = [];
            self.laserEndPoint = [];

            self.createLightCurtain();
            self.plotLightCurtain();
            self.check = 0;
            self.curtainBlocked = 0;

            self.createHand();

        end

        %% Create Light Curtain
        function createLightCurtain(self)

            self.bottomLeft = [self.x_min self.y 0];
            self.topRight = [self.x_max self.y 1];

            self.curtain1 = PlaceObject('lightCurtain.ply', [self.x_min-0.01 self.y 0]);
            self.curtain2 = PlaceObject('lightCurtain.ply', [self.x_max self.y 0]);

            laserNormals = [self.bottomLeft(1)-self.topRight(1), self.bottomLeft(2)-self.topRight(2), 0];
            laserCenters = 0.05;

            for i = 0.1 : laserCenters : 0.95

                self.laserStartPoint = [self.laserStartPoint; self.bottomLeft(1), self.bottomLeft(2), self.bottomLeft(3)+i];
            end

            for i = 0.1 : laserCenters : 0.95
                self.laserEndPoint = [self.laserEndPoint; self.topRight(1), self.topRight(2), self.bottomLeft(3)+i];
            end

            self.numLasers = size(self.laserStartPoint(:,1));

        end
        %% Plot Light Curtain
        function plotLightCurtain(self)
            view(3);

            axis([-2 2 -2 2 -2 2]);

            for i = 1 : self.numLasers

                % Then plot the start and end point in green and red, respectively.

                hold on;

                plot3([self.laserStartPoint(i, 1),self.laserEndPoint(i, 1)],[self.laserStartPoint(i, 2),self.laserEndPoint(i, 2)],[self.laserStartPoint(i, 3),self.laserEndPoint(i, 3)] ,'r');

                axis equal

            end
        end
        %% Create brick for testing curtain
        function createHand(self)

            view(3);
            handCentre = [0 0 0];
            [faces,self.vertex,data] = plyread('hand.ply','tri');
            vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            self.handVertexCount = size(self.vertex,1);

            for i = 1 : self.handVertexCount
                self.vertex(i,1) = self.vertex(i,1) + self.x;
                self.vertex(i,2) = self.vertex(i,2) + self.y - 0.5;
                self.vertex(i,3) = self.vertex(i,3) + self.z + 0.5;
            end

            self.handMesh_h = trisurf(faces,self.vertex(:,1)+handCentre(1,1),self.vertex(:,2)+handCentre(1,2), self.vertex(:,3)+handCentre(1,3) ...
                ,'FaceVertexCData',vertexColours,'EdgeColor','none','EdgeLighting','none');
            light('style', 'local', 'Position', [-2 1 1]);
            

        end

        %% Move Cat & Rectangular Prism
        function stop = blockCurtain(self)
            
            stop = 0;
            
            if self.curtainBlocked == 0
                for i = 0.01 :0.005 : 0.5
                    hold on
                    hand_pose = transl(0, 0.005, 0);
                    self.handVertexCount = size(self.vertex,1);
                    UpdatedPoints = [hand_pose * [self.vertex,ones(self.handVertexCount,1)]']';
                    self.vertex = UpdatedPoints(:,1:3);
                    self.handMesh_h.Vertices = UpdatedPoints(:,1:3);
                    pause(0.011)
                end
                self.curtainBlocked = 1
            end
            
        end
        %% Remove hand
        function resume = UnblockCurtain(self)

            resume = 0;
            if self.curtainBlocked == 1
                for i = 0.5 : -0.005 : 0.1
                    hold on
                    hand_pose = transl(0, -0.005, 0);
                    self.handVertexCount = size(self.vertex,1);
                    UpdatedPoints = [hand_pose * [self.vertex,ones(self.handVertexCount,1)]']';
                    self.vertex = UpdatedPoints(:,1:3);
                    self.handMesh_h.Vertices = UpdatedPoints(:,1:3);
                    pause(0.011)
                end
                self.curtainBlocked = 0
            end
        end
        %%

        function r = checkCurtain(self)
            for j = 1 : self.handVertexCount
                if self.vertex(j,3) < self.topRight(3)
                    if  self.vertex(j,1) > self.bottomLeft(1)
                        if self.vertex(j,1) < self.topRight(1)
                            if self.vertex(j,2) > self.bottomLeft(2)

                                self.check = 1;
                                r=1;
                                return

                            end
                        end
                    end
                end
            end
            r = 0;
            return
        end
    end
end

