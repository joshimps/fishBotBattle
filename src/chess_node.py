#!/usr/bin/env python3

import rospy
from stockfish import Stockfish
import chess
import chess.svg
from chess import engine
from fishbot_ros.srv import chess_service, chess_serviceRequest, chess_serviceResponse
from tm_msgs.srv import SendScript, SendScriptRequest
from std_srvs.srv import Trigger, TriggerResponse


fish_path = rospy.get_param("/stockfish_file_path")
fish_diff = rospy.get_param("/stockfish_difficulty", default=20)

board = chess.Board()
fish = engine.SimpleEngine.popen_uci(fish_path)
fish.configure({"Skill Level":fish_diff})
time_limit = chess.engine.Limit(time = 0.1)
states = ["Open", "Closed"]
state = 0


def chessCallback(req):
    
    prev_move = chess.Move.from_uci(req.prev_move)
    board.push(prev_move)
    if not board.is_game_over():
        action = fish.play(board,time_limit)
        chess_move = str(action.move)
        if board.is_capture(action.move): 
            result = chess_move +',1'+',0'
        elif board.is_castling(action.move): 
            result = chess_move +',0'+',1'
        elif len(chess_move) == 5: 
            result = chess_move[:-1] +',0'+',0' + ',' + chess_move[-1]
        else: 
            result = chess_move +',0'+',0'
        return chess_serviceResponse(result)
    else: return chess_serviceResponse("")

def gripperCallback(req):
    msg = SendScriptRequest()
    msg.id = 'Exit Listener'
    msg.script = 'ScriptExit()'
    grip(msg)
    foo = "Gripper is now " + states[state]
    state != state
    return TriggerResponse(success=True, message=foo)


if __name__ == "__main__":
    rospy.init_node("Chess_Engine")
    rospy.loginfo("Starting Chess Engine")
    serv = rospy.Service('chess_service', chess_service, chessCallback)
    gripListen = rospy.Service('gripper_serv', Trigger, gripperCallback)
    grip = rospy.ServiceProxy('tm_driver/send_script', SendScript)
    rospy.loginfo("Chess Engine Ready")
    while not rospy.is_shutdown():
        pass