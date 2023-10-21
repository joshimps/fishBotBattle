classdef gripper < handle
    %% Combine pincers to create gripper

    properties
        gripperL;
        gripperR;
        base;
        % set the open and close q values for the gripper
        gripperopen = [deg2rad(28.8) deg2rad(-40) deg2rad(18)];
        gripperclose = [deg2rad(28.8) deg2rad(-30) deg2rad(0)];
        curQ = []
        openmatrix;
        closematrix;
        steps = 30;


    end

    methods
        function obj = gripper(eeBase)
            obj.gripperL = finger(eeBase * trotx(pi/2) * troty(pi));
            obj.gripperR = finger(eeBase * trotx(pi/2));
            obj.gripperL.model.delay = 0;
            obj.gripperR.model.delay = 0;
            obj.gripperL.model.base = eeBase * trotx(pi/2)*troty(pi);
            obj.gripperR.model.base = eeBase * trotx(pi/2);
            obj.openmatrix = jtraj(obj.gripperclose,obj.gripperopen,obj.steps);
            obj.closematrix = jtraj(obj.gripperopen,obj.gripperclose,obj.steps);
            obj.curQ = obj.gripperclose;
            
        end

        function UpdateBase(obj, base)
            obj.gripperL.model.base = base.T * trotx(pi/2)*troty(pi);
            obj.gripperR.model.base = base.T * trotx(pi/2);

            obj.gripperL.model.animate(obj.curQ);
            obj.gripperR.model.animate(obj.curQ);
        end

        function Open(obj)
            obj.curQ = obj.gripperopen;
            for j = 1:obj.steps
                    q_brick = obj.openmatrix(j,:);
                    obj.gripperL.model.animate(q_brick);
                    obj.gripperR.model.animate(q_brick);
                    drawnow();
            end

        end

        function Close(obj)
            obj.curQ = obj.gripperclose;
            for j = 1:obj.steps
                    q_brick = obj.closematrix(j,:);
                    obj.gripperL.model.animate(q_brick);
                    obj.gripperR.model.animate(q_brick);
                    drawnow();
            end
        end


    end
end