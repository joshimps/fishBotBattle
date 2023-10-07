classdef omronTM5 < RobotBaseClass
    %% LinearUR3 UR3 on a non-standard linear rail created by a student

    properties(Access = public)
        plyFileNameStem = 'omronTM5';
    end

    methods
        %% Define robot Function
        function self = omronTM5(baseTr)
            self.CreateModel();
            if nargin < 1
                baseTr = eye(4);
            end

            self.model.base = self.model.base.T * baseTr ;

            self.PlotAndColourRobot();
            self.model.teach;

        end

        %% Create the robot model
        function CreateModel(self)
            % Create the omron model 
            link(1) = Link('d',0.1452,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            link(2) = Link('d',0.146,'a',0.429,'alpha',0,'qlim', deg2rad([-360 360]), 'offset',0);
            link(3) = Link('d',-0.1297,'a',0.4115,'alpha',0,'qlim', deg2rad([-360 360]), 'offset', 0);
            link(4) = Link('d',0.106,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            link(5) = Link('d',0.106,'a',0,'alpha',pi/2,'qlim',deg2rad([-360,360]), 'offset',0);
            link(6) = Link('d',0.1132,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);


            % Incorporate joint limits
            link(1).qlim = [-270 270] * pi/180;
            link(2).qlim = [-180 180] * pi/180;
            link(3).qlim = [-155 155] * pi/180;
            link(4).qlim = [-180 180] * pi/180;
            link(5).qlim = [-180 180] * pi/180;
            link(6).qlim = [-270 270] * pi/180;


            % link(3).offset = -pi/2;
            % link(5).offset = -pi/2;

            self.model = SerialLink(link,'name',self.name);

        end

    end
end