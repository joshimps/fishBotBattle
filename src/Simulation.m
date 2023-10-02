classdef Simulation < handle
    %% World file to handle animations of models in simulation
    % Referenced code cited in-line
    % Paul, G. (2023). Putting Simulated Objects Into The Environment
    % (https://www.mathworks.com/matlabcentral/fileexchange/58774-putting-simulated-objects-into-the-environment),
    % MATLAB Central File Exchange. Retrieved September 13, 2023.

    % Paul, G. (Aug, 2023). LinePlaneIntersection.
    % (https://canvas.uts.edu.au/courses/27375/pages/lab-3-solution?module_item_id=1290524),
    % UTS. Retrieved September 13, 2023.

    properties
        robot
        pickrestPos = [0 0.2500 1.5000 -1.6000 -1.5000 -1.0000];
        gripper
        table_h
        fence_h
        extinguisher_h
        eStop_h
        eStopFence_h
        bricks;
        wallPoses;
        workspace;
        basePlane;
        baseNormal;
    end

    methods
        % Generate world based on input robot base transform
        function self = Simulation(base)
            if nargin < 1
                base = eye(4);
            end
            hold on;
            %% spawn robot and gripper
            self.robot = UR3(base);
            self.robot.model.animate(self.pickrestPos);
            baseRef = self.robot.model.base.t;

            %% update workspace
            %self.workspace = [(baseRef(1)-2.2),(baseRef(1)+2.2),(baseRef(2)-2.2),(baseRef(2)+3.5),(baseRef(3)-0.5),(baseRef(3)+2.5)];
            axis equal
            self.basePlane = [baseRef(1), baseRef(2), baseRef(3)];
            self.baseNormal = [0,0,-1];
        end



        %% Process to pick each spawned brick and place it in its
        % corresponding wall location by index. Will stop if a collision
        % is predicted. Will log movements if provided with a logger
        % object.
        function BuildWall(self, log)
            if 1 < nargin
                logEnable = true;
            end
            for i = 1:1:9
                stop = false;
                %% set target brick and desination
                brickTarget = T(self.bricks.brickModel{i}.base) * troty(pi);
                wallTarget = self.wallPoses(:,:, i) * troty(pi);
                if logEnable
                    log.mlog = {log.DEBUG, 'Build Wall', ['Brick ', num2str(i), ' position: ', log.MatrixToString(brickTarget)]};
                end
                %% move above brick
                pickReady = brickTarget * transl(0, 0, -0.3);
                qTargetPickReady = self.robot.model.ikcon(pickReady, self.robot.model.getpos);
                qTraj = jtraj(self.robot.model.getpos(), qTargetPickReady, 20);
                stop = self.MoveRobot(qTraj);
                if stop == true
                    break;
                end
                %% Pick brick
                pickTarget = pickReady * transl(0, 0, 0.15);
                qTarget = self.robot.model.ikcon(pickTarget, self.robot.model.getpos);
                qTraj = jtraj(self.robot.model.getpos(), qTarget, 20);
                stop = self.MoveRobot(qTraj);
                if stop == true
                    break;
                end
                self.gripper.Close();
                if logEnable
                    log.mlog = {log.DEBUG, 'Build Wall', ['Brick ', num2str(i), ' picked. Gripper Position: ', log.MatrixToString(self.robot.model.fkineUTS(self.robot.model.getpos))]};
                end
                %% move up
                qTraj = jtraj(self.robot.model.getpos(), qTargetPickReady, 20);
                self.MoveRobot(qTraj,self.bricks.brickModel{i});
                %% move to rest with brick
                qTraj = jtraj(self.robot.model.getpos(), self.pickrestPos, 20);
                self.MoveRobot(qTraj,self.bricks.brickModel{i});
                qTraj = jtraj(self.robot.model.getpos(), self.placerestPos, 40);
                stop = self.MoveRobot(qTraj,self.bricks.brickModel{i});
                if stop == true
                    break;
                end
                if logEnable
                    log.mlog = {log.DEBUG, 'Build Wall', ['Wall Placement ', num2str(i), ' position: ', log.MatrixToString(wallTarget)]};
                end
                %% move above destination with brick
                placeReady = wallTarget * transl(0, 0, -0.3);
                qTarget_placeReady = self.robot.model.ikcon(placeReady, self.robot.model.getpos);
                qTraj = jtraj(self.robot.model.getpos(), qTarget_placeReady, 20);
                stop = self.MoveRobot(qTraj,self.bricks.brickModel{i});
                if stop == true
                    break;
                end
                %% place brick
                placeTarget = placeReady * transl(0, 0, 0.15);
                qTarget = self.robot.model.ikcon(placeTarget, self.robot.model.getpos);
                qTraj = jtraj(self.robot.model.getpos(), qTarget, 20);
                stop = self.MoveRobot(qTraj,self.bricks.brickModel{i});
                if stop == true
                    break;
                end
                self.gripper.Open();
                if logEnable
                    % calculate and log error between brick placement
                    % target and actual placement position in mm
                    pos = self.robot.model.fkineUTS(self.robot.model.getpos);
                    % transform from placeTarget to position of brick
                    err = pos/placeTarget;
                    err = sqrt(err(1,4)^2 + err(2,4)^2 + err(3,4)^2)*1000;
                    log.mlog = {log.DEBUG, 'Build Wall', ['Brick ', num2str(i), ' placed with ', num2str(err), 'mm of error. Gripper Position: ', log.MatrixToString(pos)]};
                end
                %% move above desination
                qTraj = jtraj(self.robot.model.getpos(), qTarget_placeReady, 20);
                stop = self.MoveRobot(qTraj);
                if stop == true
                    break;
                end
                %% move to rest
                qTraj = jtraj(self.robot.model.getpos(), self.placerestPos, 20);
                stop = self.MoveRobot(qTraj);
                if stop == true
                    break;
                end
                qTraj = jtraj(self.robot.model.getpos(), self.pickrestPos, 40);
                stop = self.MoveRobot(qTraj);
                if stop == true
                    break;
                end
            end
        end


    end


    methods (Static)

        function SpawnModels()
            %% Models sourced from UTS edition of Peter Corke's Robotic Toolbox %%

            %% place table (spawning object code based upon (Paul, G. 2023))
            tablePose = T(self.robot.model.base) * makehgtform('translate', [0.25 -0.06 -0.4]) * troty(pi/2) * trotx(-pi/2);
            [f, verts, vertexColours] = self.GenVerts('tableBrown2.1x1.4x0.5m.ply', tablePose);
            self.table_h = self.PlaceModel(f, verts, vertexColours);

            %% place fence (spawning object code based upon (Paul, G. 2023))
            fencePose = T(self.robot.model.base)* makehgtform('translate', [0 0.6 0]) * trotx(-pi/2) * trotz(-pi/2);
            [f, verts, vertexColours] = self.GenVerts('fenceAssemblyGreenRectangle4x8x2.5m.ply', fencePose);
            self.fence_h = self.PlaceModel(f, verts, vertexColours);

            %% place bricks and set wall poses (spawning object code based upon (Paul, G. 2023))
            counter = 0;
            brickPose = zeros(4,4,9);
            for i = 0:1:2
                for j = 0:1:2
                    counter = counter + 1;
                    brickPose(:,:,counter) = T(self.robot.model.base) * makehgtform('translate', [(0.55 - j*0.1) -0.06 (-0.2 * i)]) * trotx(-pi/2);
                    self.wallPoses(:,:,counter) = T(self.robot.model.base) * makehgtform('translate', [(-0.45) (-0.06 + i * 0.035) (-0.135 * j)]) * trotx(-pi/2);
                end
            end
            self.bricks = RobotBricks(9, brickPose, self.workspace);

            %% Place extinguisher (spawning object code based upon (Paul, G. 2023))
            extPose = T(self.robot.model.base)* makehgtform('translate', [1.8 0.1 0.5]) * trotx(-pi/2) * trotz(-pi/2);
            [f, verts, vertexColours] = self.GenVerts('fireExtinguisherElevated.ply', extPose);
            self.extinguisher_h = self.PlaceModel(f, verts, vertexColours);

            %% Place eStop (spawning object code based upon (Paul, G. 2023))
            eStopPose = T(self.robot.model.base)* makehgtform('translate', [0.5 0.2 0.5]) * trotx(-pi/2) * trotz(-pi/2);
            [f, verts, vertexColours] = self.GenVerts('emergencyStopButton.ply', eStopPose);
            self.eStop_h = self.PlaceModel(f, verts, vertexColours);

            eStopPose = T(self.robot.model.base)* makehgtform('translate', [2.1 1 -0.05]) * trotx(pi/2) * trotz(-pi/2);
            [f, verts, vertexColours] = self.GenVerts('emergencyStopWallMounted.ply', eStopPose);
            self.eStopFence_h = self.PlaceModel(f, verts, vertexColours);

            %% Place worker (spawning object code based upon (Paul, G. 2023))
            workerPose = T(self.robot.model.base)* makehgtform('translate', [3 0.7 -0.3]) * trotx(-pi/2) * trotz(-pi/2);
            [f, verts, vertexColours] = self.GenVerts('personMaleConstruction.ply', workerPose);
            self.eStop_h = self.PlaceModel(f, verts, vertexColours);
        end
        %% GenVerts generates the faces, vertices and vertex colours of a
        % ply model. All verts will be transformed by the provided
        % transform. Code based upon (Paul, G. 2023)

        function [f, verts, vertexColours] = GenVerts(modelPath, pose)
            [f,v,data] = plyread(modelPath,'tri');
            vertCount = size(v,1);
            try
                vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            catch
                vertexColours = [50, 82, 123];
                vertexColours = repmat(vertexColours,[vertCount 1]);
            end

            midPoint = sum(v)/vertCount;
            verts = v - repmat(midPoint,vertCount,1);
            verts = [pose * [verts, ones(vertCount,1)]']';
        end

        %% Place Model takes faces, vertices and vertex colours and maps
        % them to a patch handle plotted by the trisurf function.
        % The returned handle can be used to modify the object.
        % Code based upon (Paul, G. 2023)
        function model_h = PlaceModel(f, verts, vertexColours)
            model_h = trisurf(f,verts(:,1),verts(:,2), verts(:,3) ...
                ,'FaceVertexCData',vertexColours,'EdgeColor','interp','EdgeLighting','flat');
        end
    end
end