function movePiece(robot, board, startCoord, endCoord, take, castle)
    startMove = board.posGrid{startCoord(1),startCoord(2)};
    startMoveReady = startMoveReady * troty(pi) * transl(0,0,0.3);
    readyPose = [2.8569   -1.1247    1.5594   -2.0055   -1.5708    1.2861];
    endMove = board.posGrid{endCoord(1),endCoord(2)};
    curQ = robot.model.getpos()
    qStart = robot.model.ikcon(startMoveReady, curQ);
    qMat = jtraj(curQ,qStart, 20);

end
