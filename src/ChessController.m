 classdef ChessController < handle
    
    properties
        sim;
        urReadyPose = [0, -1.1, -2, -1.5, 1.8,0];
        urWaitPose = [0 -0.25 -2.4 -0.4 1.8 0];
        tmReadyPose = [-pi/2, -0.17, 1.9, 0.129, -1.5,0];
        tmWaitPose = [-pi/2, -0.67, 1.9, -0.28, -1.5,0];
        ready = [];
        turn;
        rosCont; 
        realControl; 
        realContCalib; 
        safetyWait;
        arduinoObj;
        humanMoveSent;
        newMove;
    end
    
    methods
        function obj = ChessController(realControl)
            if nargin < 1
                realControl = 0;
            end
            serialportlist("available")'
            obj.arduinoObj = serialport("/dev/ttyACM1",9600);
            configureTerminator(obj.arduinoObj,"CR/LF");
            flush(obj.arduinoObj);
            obj.arduinoObj.UserData = struct("Data",[]);
            obj.safetyWait = 0;
            obj.turn = 0;  
            obj.humanMoveSent = 0;
            obj.sim = IRsim();
            obj.rosCont = RosController();
            obj.realControl = realControl;
            obj.realContCalib = [1,-1,-1,-1,1,1];
            obj.MoveRobot(obj.sim.ur, obj.urWaitPose, true);
            obj.MoveRobot(obj.sim.tm5, obj.tmWaitPose, true);
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
            while obj.humanMoveSent ~= 1
                pause(0.001);
            end
            prevMove = obj.newMove; 
            obj.interpMoveString(obj.newMove);
            obj.humanMoveSent = 0;
            while true
                if obj.turn == 1
                    engineMove = obj.rosCont.getMove(prevMove(1:4));
                    obj.newMove = engineMove.Move;
                else  
                    obj.rosCont.getMove(prevMove(1:4));
                end
                    
                if size(obj.newMove,2) < 1
                    break;
                else
                    while obj.humanMoveSent ~= 1
                        pause(0.001);
                    end
                    obj.interpMoveString(obj.newMove);
                    prevMove = obj.newMove;
                    obj.humanMoveSent = 0;
                end
            end
            disp("Game is over, winner is " + ~obj.turn);
        end

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
            if obj.realControl
                obj.rosCont.actuate_gripper();
            end
            obj.MoveRobot(robot, startMoveMid, false, piece);
            obj.MoveRobot(robot, obj.ready, true, piece);
            endMoveReady = endMove * transl(0,0,-0.3);
            obj.MoveRobot(robot, endMoveReady, false, piece);
            endMoveMid = endMoveReady * transl(0,0,0.07);
            obj.MoveRobot(robot, endMoveMid, false,piece);
            endMovePlace = endMoveMid * transl(0,0,0.079);
            obj.MoveRobot(robot, endMovePlace, false, piece);
            robot.gripper.Open();
            if obj.realControl
                obj.rosCont.actuate_gripper();
            end
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
            
            i = 1;
            while i < size(goalTraj, 1)
                pause(0.001);
                obj.pollSafety(robot, goalTraj(i,:));
                if obj.safetyWait == 1
                    continue; 
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

            if obj.realControl == 1
                goalReached = 0; 
                while goalReached == 0
                    goal = goalTraj(end,:) .* obj.realContCalib;
                    obj.rosCont.setGoal(1, goal,1);
                    obj.rosCont.doGoal();
                    needsReset = 0;
                    while obj.rosCont.checkGoal == 0
                        obj.pollSafety(robot,goalTraj(i,:))
                        if obj.safetyWait == 1
                            needsReset = 1;
                            obj.rosCont.cancelGoal();
                        else
                            if needsReset
                                break
                            end
                        end
                    end
                    goalReached = 1;
                end
            end
        end
        
        % Move this to the arduino object surely? 
        function r = getRealEStop(obj)
            flush(obj.arduinoObj)
            data = strtrim(readline(obj.arduinoObj));
            while data == ""
                flush(obj.arduinoObj)
                data = strtrim(readline(obj.arduinoObj));
            end
            r = str2double(data);  
        end
        
        function r = pollSafety(obj, robot, qmatrix)
            % Call physical estop poll
            if obj.getRealEStop() == 1
                obj.safetyWait = 1;
                disp("SAFETY COMPROMISED, PHYSICAL E STOP PRESSED");
                return;
            end

            % Call collision poll
            if checkCollision(robot, qmatrix, obj.sim.box.vertex)
                 obj.safetyWait = 1;
                 disp("SAFETY COMPROMISED, COLLISION DETECTED");
                return;
            end
     
            % Call light curtain poll
            if obj.sim.curtain.checkCurtain()
                 obj.safetyWait = 1;
                 disp("SAFETY COMPROMISED, CURTAIN BREACH DETECTED");
                return;
            end
        end
    end
end

