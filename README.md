# fishBotBattle
## Dependencies
### Ros Noetic, Ubuntu 20.07, Python3, Matlab 2023a
### Stockfish

[Stockfish](https://stockfishchess.org/download/)
### Python chess
```
pip install chess
```
### Robotics Toolbox
[Robotics Toolbox for Matlab](https://petercorke.com/toolboxes/robotics-toolbox/)

## Setup
Following dependency installation, the chess service must be added to the matlab path. 

Generate the matlab messages on your local machine by running 
```
rosgenmsg('THIS_DIRECTORY')
```

To use the custom messages, follow these steps in the matlab command window:
 
1. Add the custom message folder to the MATLAB path by executing:
```
addpath('PATH_TO_THIS_FOLDER\matlab_msg_gen_ros1\glnxa64\install\m')
savepath
``` 
 
2. Refresh all message class definitions, which requires clearing the workspace, by executing:
```
clear classes
rehash toolboxcache
``` 
 
3. Verify that you can use the custom messages. Enter "rosmsg list" and ensure that the output contains fishbot_ros/chess_service.

## Usage

Configure chess parameters including difficulty and path to Stockfish executable.

Launch chess service 
```
roslaunch fishbot_ros botbattle.launch
```

In matlab run chess controller
```
g = gui()
```

