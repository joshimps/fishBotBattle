%% Inputs
% robot - a robot object inherited from the RobotBaseClass.
% pos - the current position of the robot through the kinematic chain, will
% be 1 when calling if wanting to start from the first link of the robot.
% step - the number of steps between the qLimits.
% vector [in|out] - a handle object used to track the end effector points
% through recursive calls.
% q - the current joint state as the function progresses through all
% configurations.
% log - a logger object of type log4matlab.
% maxSteps - an approximate count of the number of points recorded in the
% point cloud, used for progress updates.
%% Outputs
% vector [in|out] a handle object used to track the end effector points
% through recursive calls.
%% Function
function GenWorkspaceQ(robot, pos, step, vector, q, maxSteps)
% access robot parameters
numLinks = size(robot.model.links, 2) - 1;
qlim = robot.model.qlim;

for i = pos:1:numLinks

    %normalise qlimits to be a maximum range of 0 to 360 degrees to
    %reduce computational load
    qlimMin = qlim(i, 1);
    qlimMax = qlim(i, 2);
    if qlimMax == 2*pi
        if qlimMin == -2*pi
            qlimMin = 0;
        end
    end

    %call self recursively until reaching the second last link in the
    %kinematic chain, iterating through joint states one at a time
    for j = 0:1:step
        if pos ~= numLinks
            GenWorkspaceQ(robot, i+1, step, vector, q, maxSteps);
        end

        q(i) = qlimMin + ((qlimMax-qlimMin)/step) * j;
        eePos = robot.model.fkineUTS(q);

        % exclude all values below the base of the robot
        if robot.model.base.t(3,1) < eePos(3,4);
            vector.vector = cat(1,vector.vector,(eePos(1:3,4))');

            %status update logged at each point that divides evenly
            count = size(vector.vector,1);
            if mod(count/maxSteps * 100,1) == 0;
                disp([num2str(count/maxSteps*100), ' % Complete']);
            end
        end

    end
end
end