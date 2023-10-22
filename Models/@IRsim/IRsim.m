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

    end

    methods
        %% ...structors
        function self = IRsim(baseTr, mode)
            if nargin < 1
                baseTr = eye(4);
                mode = 'PvP';
            end

            hold on
            view(3)
            
            ur_tr = baseTr * transl(-0.15, 0.25, 0);
            omron_tr = baseTr * transl(0.75,0.25,0.1);
            curtain_tr = baseTr * transl(0.7, 0.25, 0);

            self.ur = ur3(ur_tr);
            if (strcmp(mode,'PvP'))
                self.tm5 = omronTM5(omron_tr);
            else
                self.curtain = lightCurtain(curtain_tr);
            end
            self.board = ChessBoard();            
            self.environment = PlaceObject('robotRoom2.ply', [0 0 0]);

            %place the floor into the world.
            surf([-5,-5; 5,5] ...
                ,[-5,5;-5,5] ...
                ,[-0.8,-0.8;-0.8,-0.8] ...
                ,'CData',imread('concrete.jpg') ...
                ,'FaceColor','texturemap');

            view(3)
            axis([-1 1 -1 1.5 -0.1 1.5])
            
            end
    end
    
end

