classdef gripper < handle
    %% Combine pincers to create gripper

    properties
        gripperL;
        gripperR;
        base;
        % set the open and close q values for the gripper
        gripperopen = [deg2rad(0) deg2rad(0) deg2rad(0)];
        gripperclose = [deg2rad(15) deg2rad(0) deg2rad(-10)];
        openmatrix;
        closematrix;
        steps = 10;


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
            
        end

        function UpdateBase(obj, base)
            obj.gripperL.model.base = base * trotx(pi/2)*troty(pi);
            obj.gripperR.model.base = base * trotx(pi/2);

            obj.gripperL.model.animate(obj.gripperopen);
            obj.gripperR.model.animate(obj.gripperopen);
        end

        function Open(obj)

            for j = 1:obj.steps
                    q_brick = obj.openmatrix(j,:);
                    obj.gripperL.model.animate(q_brick);
                    obj.gripperR.model.animate(q_brick);
                    drawnow();
            end

        end

        function Close(obj)
            for j = 1:obj.steps
                    q_brick = obj.closematrix(j,:);
                    obj.gripperL.model.animate(q_brick);
                    obj.gripperR.model.animate(q_brick);
                    drawnow();
            end
        end


    end
end