classdef Gripper < handle
    %% Two finger gripper model with open and close methods

    properties
        fingerLeft;
        fingerRight;
        base;
        qOpen = zeros(1,3);
        qCloseLeft = [0, pi/8, -pi/8];
        qCloseRight = [0, -pi/8, pi/8];
        steps = 10;
        qTrajOpenLeft;
        qTrajOpenRight;
        qTrajCloseLeft;
        qTrajCloseRight
        qCurLeft;
        qCurRight;
    end

    methods
        function obj = Gripper(eeBase);
            %% create fingers, initialise them in the open position on the
            % robot end effector and setup open and close trajectories
            obj.fingerLeft = obj.CreateFinger(true);
            obj.fingerRight = obj.CreateFinger(false);
            obj.qCurLeft = obj.qOpen;
            obj.qCurRight = obj.qOpen;
            obj.fingerLeft.base = eeBase;
            obj.fingerRight.base = eeBase;
            q = zeros(1, 3);
            obj.fingerLeft.plot(q, 'noname', 'nobase', 'nowrist');
            obj.fingerRight.plot(q,'noname', 'nobase', 'nowrist');
            obj.qTrajOpenLeft = jtraj(obj.qCloseLeft, obj.qOpen, obj.steps);
            obj.qTrajOpenRight = jtraj(obj.qCloseRight, obj.qOpen, obj.steps);
            obj.qTrajCloseLeft = jtraj(obj.qOpen, obj.qCloseLeft, obj.steps);
            obj.qTrajCloseRight= jtraj(obj.qOpen, obj.qCloseRight, obj.steps);
        end

        function finger = CreateFinger(obj, left)
            % Set up gripper limits based on the ROBOTIQ 2F-140 Gripper
            if left
                L1 = Link('d',0,'a',0.025,'alpha',pi/2,'qlim',[0 0]);
                L2 = Link('d',0,'a',0.057,'alpha',0,'qlim',[0 pi/6], 'offset', pi/3);
                L3 = Link('d',0,'a',0.024,'alpha',0,'qlim',[-pi/6, pi/6], 'offset', pi/6);
                name = 'left';
            else
                L1 = Link('d',0,'a',-0.025,'alpha',pi/2,'qlim',[0 0]);
                L2 = Link('d',0,'a',0.057,'alpha',0,'qlim',[0 pi/6], 'offset', pi-pi/3);
                L3 = Link('d',0,'a',0.024,'alpha',0,'qlim',[-pi/6, pi/6], 'offset', -pi/6);
                name = 'right';
            end

            finger = SerialLink([L1, L2, L3], 'name', name);
        end

        function UpdateBase(obj, base)
            obj.fingerLeft.base = base;
            obj.fingerRight.base = base;

            obj.fingerLeft.animate(obj.qCurLeft);
            obj.fingerRight.animate(obj.qCurRight);
        end

        function Close(obj)
            for i = 1:1:obj.steps
                obj.fingerLeft.animate(obj.qTrajCloseLeft(i,:));
                obj.fingerRight.animate(obj.qTrajCloseRight(i,:));
                drawnow();
            end
            obj.qCurLeft = obj.qCloseLeft;
            obj.qCurRight = obj.qCloseRight;
        end

        function Open(obj)

            for i = 1:1:obj.steps
                obj.fingerLeft.animate(obj.qTrajOpenLeft(i,:));
                obj.fingerRight.animate(obj.qTrajOpenRight(i,:));
                drawnow();
            end
            obj.qCurLeft = obj.qOpen;
            obj.qCurRight = obj.qOpen;
        end
    end
end