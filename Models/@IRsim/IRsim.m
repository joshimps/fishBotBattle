classdef IRsim < handle
    %brick A class that creates a herd of robot cows
    %   The cows can be moved around randomly. It is then possible to query
    %   the current location (base) of the cows.

    %#ok<*TRYNC>

    properties
        ur;
        tm5;
        board;
        baseTr;
        mode;
        world_offset;
        environment;
        curtain;        
        box;

    end

    methods
        %% ...structors
        function self = IRsim(baseTr)
            if nargin < 1
                baseTr = eye(4);
            end
            
            view(3)
            hold on
            %place the floor into the world.
            surf([-5,-5; 5,5] ...
                ,[-5,5;-5,5] ...
                ,[-0.8,-0.8;-0.8,-0.8] ...
                ,'CData',imread('concrete.jpg') ...
                ,'FaceColor','texturemap');
            
            ur_tr = baseTr * transl(-0.15, 0.25, 0);
            omron_tr = baseTr * transl(0.75,0.25,0.1);
            curtain_tr = baseTr * transl(0.25, -0.5, 0) * troty(pi/2);

            self.ur = ur3(ur_tr);
                
            self.environment = PlaceObject('robotRoom_PvP.ply', [0 0 0]);
            self.tm5 = omronTM5(omron_tr);
            self.curtain = lightCurtain(curtain_tr);
            
            self.board = ChessBoard();

            self.box = collisionBlock();
        
            axis off
            view(3)
            % axis([-1 1.25 -1 1 -0.1 1.5])
            
            end
    end
    
end