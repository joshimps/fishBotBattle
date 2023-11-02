classdef RosController < handle

    properties
        jointStateSubscriber;
        currentJointState_123456;
        nextJointState; 
        jointNames;
        controlClient;
        goal;
        goalQ; 
        seq;
        chessClient;
        chessMove; 
    end

    methods
        function Connect(self, real_control, ip_add)
            default_ip = 'http://localhost:11311';
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
                self.currentJointState_123456 = (self.jointStateSubscriber.LatestMessage.Position)';
                self.jointNames = {'shoulder_1_joint','shoulder_2_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
    
                [self.controlClient, self.goal] = rosactionclient('/follow_joint_trajectory');
                self.seq = 1; 
            end
        end

        function [recMove] = getMove(self,sendMove)
            self.chessMove.PrevMove = sendMove;
            recMove = call(self.chessClient, self.chessMove);
        end

        function actuate_gripper(self)
            gripperClient = rossvcclient('/gripper_serv', 'std_srvs/Trigger');
            call(gripperClient);
        end

        function setGoal(self, duration, joints, reset)
            self.goalQ = joints;
            self.goal.Trajectory.JointNames = self.jointNames;
            self.seq = self.seq + 1; 
            self.goal.Trajectory.Header.Seq = self.seq;
            self.goal.Trajectory.Header.Stamp = rostime('Now','system');
            self.goal.GoalTimeTolerance = rosduration(0.5);
            bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.
           
            if reset == 1
                self.currentJointState_123456 = (self.jointStateSubscriber.LatestMessage.Position)'; 
            end
            

            startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            startJointSend.Positions = self.currentJointState_123456;
            startJointSend.Velocities = zeros(1,6);
            startJointSend.TimeFromStart = rosduration(0);    
            
            endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            self.nextJointState = joints;
            endJointSend.Positions = joints;
            endJointSend.Velocities = zeros(1,6);
            endJointSend.TimeFromStart = rosduration(duration);

            self.goal.Trajectory.Points = [startJointSend; endJointSend];

            self.goal.Trajectory.Header.Stamp = self.jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
        end

        function doGoal(self)
            sendGoal(self.controlClient,self.goal);
            %self.currentJointState_123456 = self.nextJointState;
        end

        function done = checkGoal(self)
            currentJointState_123456 = (self.jointStateSubscriber.LatestMessage.Position)';
            err = abs((currentJointState_123456/self.goalQ)*100 - 100);
            if err <= 1
                done = 1;
            else 
                done = 0;
            end
        end


        
        function cancelGoal(self)
            cancelGoal(self.controlClient);
        end
    end  
end