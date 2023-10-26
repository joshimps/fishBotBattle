classdef RosController < handle

    properties
        jointStateSubscriber;
        currentJointState_123456;
        nextJointState; 
        jointNames;
        controlClient;
        goal;
        seq;
        chessClient;
        chessMove; 
    end

    methods
        function Connect(self, real_control, ip_add)
            default_ip = 'http://mitch-pc:11311/';
            if nargin > 2
                default_ip = ip_add;
            end
            try 
                rosshutdown
            end
            rosinit(default_ip)
            [self.chessClient, self.chessMove] = rossvcclient("/chess_service", "fishbot_ros/chess_service");
            
            if real_control == 1
                self.jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
    
                pause(2); % Pause to give time for a message to appear
                currentJointState_321456 = (self.jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
                self.currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
                self.jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
    
                [self.controlClient, self.goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
                self.seq = 1; 
            end
        end

        function [recMove] = getMove(self,sendMove)
            self.chessMove.PrevMove = sendMove;
            recMove = call(self.chessClient, self.chessMove);
        end

        function SetGoal(self, duration, joints, reset)
            self.goal.Trajectory.JointNames = self.jointNames;
            self.seq = self.seq + 1; 
            self.goal.Trajectory.Header.Seq = self.seq;
            self.goal.Trajectory.Header.Stamp = rostime('Now','system');
            self.goal.GoalTimeTolerance = rosduration(0.5);
            bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.
           
            if reset == 1
                currentJointState_321456 = (self.jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
                self.currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
            end
            

            startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            startJointSend.Positions = self.currentJointState_123456;
            startJointSend.TimeFromStart = rosduration(0);    
            
            endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            self.nextJointState = joints;
            endJointSend.Positions = joints;
            endJointSend.TimeFromStart = rosduration(duration);

            self.goal.Trajectory.Points = [startJointSend; endJointSend];

            self.goal.Trajectory.Header.Stamp = self.jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
        end

        function doGoal(self)
            sendGoalAndWait(self.controlClient,self.goal);
            self.currentJointState_123456 = self.nextJointState;
        end
        
        function cancelGoal(self)
            cancelGoal(self.controlClient);
        end
    end  
end