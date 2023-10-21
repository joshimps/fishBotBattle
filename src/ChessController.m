classdef ChessController < handle
    %CHESSCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sim;
        urReadyPose = [0, -1.1, -2, -1.5, 1.8,0];
        urWaitPose = [0 -0.25 -2.4 -0.4 1.8 0];
        tmReadyPose = [0, 1.4, 1.9, -1.7, -1.5,0];
        tmWaitPose = [0, 0.9, 1.9, -1.85, -1.5,0];
        ready = [];
        turn;
        rosCont; 
    end
    
    methods
        function obj = ChessController(pve)
            % base0 = eye(4);
            % baseBoard = base0 * transl(0.5, 0, 0);
            % base1 = base0 * transl(1, 0, 0) * trotz(pi);
            % obj.board = ChessBoard(baseBoard);
            % obj.rosCont = RosController();
            % obj.rosCont.Connect(); 
            % if pve == 1
            %     %obj.robot0 = TM5(); 
            % else
            %     obj.robot1 = UR3(base1);
            %     obj.robot0 = UR3(base0); 
            % end
            obj.turn = 0;  
            obj.sim = IRsim;
            obj.MoveRobot(obj.sim.ur, obj.urWaitPose, true);
            obj.MoveRobot(obj.sim.tm5, obj.tmWaitPose, true);
            obj.rosCont = RosController();
            % obj.rosCont.Connect(); 
        end

        function chessGameEvE(obj)
           prevMove = 'e2e4,0,0';
           obj.interpMoveString(prevMove);
           gameIsOver = 0; 
           while ~gameIsOver
               newMove = obj.rosCont.getMove(prevMove(1:4));
               if size(newMove.Move,2) < 1
                   gameIsOver = true;
               end
               obj.interpMoveString(newMove.Move);
               prevMove = newMove.Move;
           end
           disp("Game is over, winner is " + ~obj.turn);
        end

        function chessGamePvE(obj)
           prevMove = 'e2e4,0,0';
           obj.interpMoveString(prevMove);
           gameIsOver = 0; 
           while ~gameIsOver
               if obj.turn == 0
                   engineMove = obj.rosCont.getMove(prevMove(1:4));
                   newMove = engineMove.move;
               else
                   newMove = input("Enter Player Prompt", 's');
               end
                   
               if size(newMove,2) < 1
                   gameIsOver = true;
               end
               obj.interpMoveString(newMove);
               prevMove = newMove;
           end
           disp("Game is over, winner is " + ~obj.turn);
           end

        %castles and promotes not implemented yet
        function interpMoveString(obj, moveString)
            disp(moveString);
            Alphabet = 'abcdefghijklmnopqrstuvwxyz';
            %moveString = char(moveString);
            [~, Nums] = ismember(moveString, Alphabet);
            startMove = obj.sim.board.posGrid{str2double(moveString(2)),Nums(1)}.pose;
            endMove = obj.sim.board.posGrid{str2double(moveString(4)), Nums(3)}.pose;
            piece = obj.sim.board.posGrid{str2double(moveString(2)),Nums(1)}.piece;
            obj.sim.board.posGrid{str2double(moveString(2)),Nums(1)}.piece = 0;
            obj.sim.board.posGrid{str2double(moveString(4)),Nums(3)}.piece = piece;
            capture = str2double(moveString(6));
            %castling = str2double(moveString(8));
            %promotion = 0; 
            %if length(moveString)>8
            %    promotion = moveString(10);
            %end
            if obj.turn == 0
                robot = obj.sim.ur;
                obj.ready = obj.urReadyPose;
                wait = obj.urWaitPose;
                dump = obj.sim.board.dump0;
            else 
                robot = obj.sim.tm5;
                obj.ready = obj.tmReadyPose;
                wait = obj.tmWaitPose;
                dump = obj.sim.board.dump1;
            end
            obj.turn = ~obj.turn;
            if capture
                capturePiece = obj.sim.board.posGrid{str2double(moveString(2)),Nums(1)}.piece;
                obj.movePiece(robot, endMove, dump, piece); 
            end
            obj.movePiece(robot, startMove, endMove, piece);
            obj.MoveRobot(robot, wait, true);
        end

        function movePiece(obj, robot, startMove, endMove, piece)
            obj.MoveRobot(robot, obj.ready, true);
            startMoveReady = startMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, startMoveReady, false);
            startMovePick = startMoveReady * transl(0,0,0.15);
            obj.MoveRobot(robot, startMovePick, false);
            robot.gripper.Close();
            obj.MoveRobot(robot, obj.ready, true, piece);
            endMoveReady = endMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, endMoveReady, false, piece);
            endMovePlace = endMoveReady * transl(0,0,0.15);
            obj.MoveRobot(robot, endMovePlace, false, piece);
            robot.gripper.Open();
            obj.MoveRobot(robot, obj.ready, true);
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
                
                robot.gripper.UpdateBase(eePose);
                if movePiece
                    piece.base = eePose.T * troty(pi);
                    piece.animate(0);
                end
            end
        end
    end
end

