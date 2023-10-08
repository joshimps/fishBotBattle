
classdef finger < RobotBaseClass


    properties(Access = public)
        plyFileNameStem = 'Gripper';
        gripperL;
        gripperR;
    end

    methods
        %% Constructor
        function self = finger(baseTr)
            self.CreateModel();
            if nargin < 1
                baseTr = eye(4);
            end
            self.model.base = self.model.base.T * baseTr * troty(pi);
            % self.model.plot(zeros(1,3));
            self.PlotAndColourRobot();
       
        end

        %% CreateModel
        function CreateModel(self)

            link(1) = Link([0      0      0.065     0      0]);
            link(2) = Link([0      0      0.038      0      0]);
            link(3) = Link([0      0      0.025      0      0]);

            link(1).qlim = [-360 360]*pi/180;
            link(2).qlim = [-360 360]*pi/180;
            link(3).qlim = [-360 360]*pi/180;

            link(1).offset = 20*pi/180;
            link(2).offset = 80*pi/180;
            link(3).offset = -10*pi/180;

            self.model = SerialLink(link,'name',self.name);
        end

        

    end
end
