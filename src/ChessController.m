 classdef ChessController < handle
    %CHESSCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    %% TODO
    % add gripper control
    
    properties
        sim;
        urReadyPose = [0, -1.1, -2, -1.5, 1.8,0];
        urWaitPose = [0 -0.25 -2.4 -0.4 1.8 0];
        tmReadyPose = [0, 1.4, 1.9, -1.7, -1.5,0];
        tmWaitPose = [0, 0.9, 1.9, -1.85, -1.5,0];
        ready = [];
        turn;
        rosCont; 
        realControl; 
        safetyWait;
        newMove;
    end
    
    methods
        function obj = ChessController(realControl)
            if nargin < 1
                realControl = 0;
            end
            obj.safetyWait = 0;
            obj.turn = 0;  
            obj.sim = IRsim();
            obj.MoveRobot(obj.sim.ur, obj.urWaitPose, true);
            obj.MoveRobot(obj.sim.tm5, obj.tmWaitPose, true);
            obj.rosCont = RosController();
            obj.realControl = realControl;
        end

        function chessGameEvE(obj)
            obj.realControl = 0; 
            obj.rosCont.Connect(0); 
            prevMove = 'e2e4,0,0';
            obj.interpMoveString(prevMove);
            gameIsOver = 0; 
            while ~gameIsOver
                newMove = obj.rosCont.getMove(prevMove(1:4));
                if size(newMove.Move,2) < 1
                    gameIsOver = true;
                end
                if size(newMove,2) < 1
                    break;
                else
                    obj.interpMoveString(newMove.Move);
                    prevMove = newMove.Move;
                end
            end
            disp("Game is over, winner is " + ~obj.turn);
        end

        function chessGamePvE(obj, realControl);
            obj.rosCont.Connect(realControl); 
            obj.realControl = realControl; 
            disp("Moves shall be entered as follows startend,capture,castle. For example, e2e4,0,0");
            prevMove = newMove; 
            obj.interpMoveString(newMove);
            while true
                if obj.turn == 1
                    engineMove = obj.rosCont.getMove(prevMove(1:4));
                    newMove = engineMove.Move;
                else
                    obj.rosCont.getMove(prevMove(1:4));
                end
                    
                if size(newMove,2) < 1
                    break;
                else
                    obj.interpMoveString(newMove);
                    prevMove = newMove;
                end
            end
            disp("Game is over, winner is " + ~obj.turn);
        end

        %promotes not implemented yet
        function interpMoveString(obj, moveString)
            disp(moveString);
            Alphabet = 'abcdefghijklmnopqrstuvwxyz';
            [~, nums] = ismember(moveString, Alphabet);
            startMove = obj.sim.board.posGrid{str2double(moveString(2)),nums(1)}.pose;
            endMove = obj.sim.board.posGrid{str2double(moveString(4)), nums(3)}.pose;
            piece = obj.sim.board.posGrid{str2double(moveString(2)),nums(1)}.piece;
            capture = str2double(moveString(6));
            castling = str2double(moveString(8));
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
                capturePiece = obj.sim.board.posGrid{str2double(moveString(4)),nums(3)}.piece;
                obj.movePiece(robot, endMove, dump, capturePiece); 
            end

            if castling
                if nums(3) == 3
                    rookPiece = obj.sim.board.posGrid{str2double(moveString(4)),1}.piece;
                    startCastle = obj.sim.board.posGrid{str2double(moveString(4)),1}.pose;
                    endCastle = obj.sim.board.posGrid{str2double(moveString(4)), 4}.pose;
                    obj.sim.board.posGrid{str2double(moveString(4)),1}.piece = 0;
                    obj.sim.board.posGrid{str2double(moveString(4)), 4}.piece = rookPiece;
                else
                   rookPiece = obj.sim.board.posGrid{str2double(moveString(4)), 8}.piece;
                   startCastle = obj.sim.board.posGrid{str2double(moveString(4)),8}.pose;
                   endCastle = obj.sim.board.posGrid{str2double(moveString(4)), 6}.pose;
                   obj.sim.board.posGrid{str2double(moveString(4)),8}.piece = 0;
                   obj.sim.board.posGrid{str2double(moveString(4)), 6}.piece = rookPiece;
                end
                obj.movePiece(robot, startCastle, endCastle, rookPiece);
            end

            obj.movePiece(robot, startMove, endMove, piece);
            obj.MoveRobot(robot, wait, true);
            obj.sim.board.posGrid{str2double(moveString(2)),nums(1)}.piece = 0;
            obj.sim.board.posGrid{str2double(moveString(4)),nums(3)}.piece = piece;
        end

        function movePiece(obj, robot, startMove, endMove, piece)
            obj.MoveRobot(robot, obj.ready, true);
            startMoveReady = startMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, startMoveReady, false);
            startMoveMid = startMoveReady * transl(0,0,0.075);
            obj.MoveRobot(robot, startMoveMid, false);
            startMovePick = startMoveMid * transl(0,0,0.07);
            obj.MoveRobot(robot, startMovePick, false);
            robot.gripper.Close();
            obj.MoveRobot(robot, startMoveMid, false, piece);
            obj.MoveRobot(robot, obj.ready, true, piece);
            endMoveReady = endMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, endMoveReady, false, piece);
            endMoveMid = endMoveReady * transl(0,0,0.07);
            obj.MoveRobot(robot, endMoveMid, false,piece);
            endMovePlace = endMoveMid * transl(0,0,0.079);
            obj.MoveRobot(robot, endMovePlace, false, piece);
            robot.gripper.Open();
            obj.MoveRobot(robot, endMoveMid,false);
            obj.MoveRobot(robot, obj.ready, true);
        end
        
        %% Moves robot along provided trajectory
        % Will stop and log a message if a collision is projected in the
        % next movement. Will move brick with end effector if a brick is
        % passed in as an argument.
        function MoveRobot(obj, robot, goalPose, isJoint, piece)
            movePiece = true;
            if  nargin < 5
                movePiece = false;
            end
            
            curQ = robot.model.getpos();
            if ~isJoint
                qGoal = robot.model.ikcon(goalPose, curQ);
            else 
                qGoal = goalPose;
            end
            goalTraj = jtraj(curQ,qGoal, 50);

            if obj.realControl
                if obj.turn == 1
                    goal = goalTraj(end,:) + [180,0,0,-90,0,0];
                    goal(3) = goal(3)*-1;
                    if goal(1) > 180
                        goal(1) = goal(1) - 360; 
                    end
                    if goal(4) < -180
                        goal(4) = goal(4) + 360
                    end
                    obj.rosCont.SetGoal(3,goal,0)
                    p = parfeval(backgroundPool, @obj.rosCont.doGoal);
                end
            end
            
            i = 1;
            while i < size(goalTraj, 1)
                temp = obj.pollSafety();
                if temp == 0
                    if obj.safetyWait == 1
                        if obj.realControl == 1
                            if obj.turn == 1
                                goal = goalTraj(end,:) + [180,0,0,-90,0,0];
                                if goal(1) > 180
                                    goal(1) = goal(1) - 360; 
                                end
                                if goal(4) < -180
                                    goal(4) = goal(4) + 360
                                end
                                goal(3) = goal(3)*-1;
                                obj.rosCont.SetGoal(3,goal,0)
                                p = parfeval(@obj.rosCont.doGoal);
                            end
                        end
                    end
                    obj.safetyWait = temp;
                end
                if obj.safetyWait == 1
                    cancel(p);
                    obj.rosCont.cancelGoal()
                    continue
                end
                qState = goalTraj(i,:);

                % move robot, gripper and, if applicable, the brick
                robot.model.animate(qState);
                eePose = robot.model.fkine(robot.model.getpos);
                drawnow();
                
                robot.gripper.UpdateBase(eePose);
                if movePiece
                    piece.base = eePose.T * troty(pi);
                    piece.animate(0);
                end
                i = i + 1; 
            end
            if obj.realControl
                wait(p);
            end

        end

        function wait = pollSafety(obj)
            % Call collision poll
            % Call estop poll
            % Call light curtain poll
            wait = false;
        end
    end
end

