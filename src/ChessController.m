classdef ChessController < handle
    %CHESSCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        board;
        robot0;
        robot1;
        turn;
        
    end
    
    methods
        function obj = ChessController(pvp)
            base0 = eye(4);
            baseBoard = base0 * transl(0.5, 0, 0);
            base1 = base0 * transl(1, 0, 0) * trotz(pi);
            obj.board = ChessBoard(baseBoard);
            if pvp == 1
                %obj.robot0 = TM5(); 
            else
                obj.robot1 = UR3(base1);
                obj.robot0 = UR3(base0); 
            end
            obj.turn = 0; 
        end
        
        %takes, castles and promotes not implemented yet
        function interpMoveString(obj, moveString)
            Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            %moveString = char(moveString);
            [~, Nums] = ismember(moveString, Alphabet);
            startMove = obj.board.posGrid{Nums(1),str2double(moveString(2))};
            endMove = obj.board.posGrid{Nums(3),str2double(moveString(4))};
            if obj.turn == 0
                robot = obj.robot0;
            else 
                robot = obj.robot1;
            end
            obj.turn = ~obj.turn;
            obj.movePiece(robot, startMove, endMove);
        end

        function movePiece(obj, robot, startMove, endMove)
            startMoveReady = startMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, startMoveReady, false);
            startMovePick = startMoveReady * transl(0,0,0.1);
            obj.MoveRobot(robot, startMovePick, false);
            readyPose = [2.8569   -1.1247    1.5594   -2.0055   -1.5708    1.2861];
            obj.MoveRobot(robot, readyPose, true);
            endMoveReady = endMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, endMoveReady, false);
            endMovePlace = endMoveReady * transl(0,0,0.1);
            obj.MoveRobot(robot, endMovePlace, false);
            obj.MoveRobot(robot, readyPose, true);
        end
        
        %% Moves robot along provided trajectory
        % Will stop and log a message if a collision is projected in the
        % next movement. Will move brick with end effector if a brick is
        % passed in as an argument.
        function stop = MoveRobot(obj, robot, goalPose, isJoint, piece)
            movePiece = true;
            stop = false;
            if  nargin < 5
                movePiece = false;
            end
            
            curQ = robot.model.getpos();
            if ~isJoint
                qStart = robot.model.ikcon(goalPose, curQ);
            else 
                qStart = goalPose;
            end
            goalTraj = jtraj(curQ,qStart, 50);

            for i = 1:size(goalTraj, 1)
                qState = goalTraj(i,:);

                % collision detection based on (Paul, G. Aug 2023)
                % [~, allLink] = self.robot.model.fkine(qState);
                % for j = 2:(size(allLink,2)-1)
                %     [~,check] = LinePlaneIntersection(self.baseNormal,self.basePlane,allLink(j).t',allLink(j+1).t');
                %     if check == 1
                %         stop = true;
                %         disp("COLLISION PREDICTED IN MOTION PLAN - ABORTING")
                %         break;
                %     end
                % end
                % if stop == true
                %     break
                % end

                % move robot, gripper and, if applicable, the brick
                robot.model.animate(qState);
                eePose = robot.model.fkine(robot.model.getpos);
                drawnow();
                
                % self.gripper.UpdateBase(eePose);
                if movePiece
                    piece.base = eePose;
                    piece.animate(0);
                end
            end
        end
    end
end

