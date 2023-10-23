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
        omron_stand;
        bucket0;
        bucket1;

    end

    methods
        %% ...structors
        function self = IRsim(baseTr, mode)
            if nargin < 2
                baseTr = eye(4);
                mode = true;
            end

            hold on
            view(3)
            
            ur_tr = baseTr * transl(-0.15, 0.25, 0);
            omron_tr = baseTr * transl(0.75,0.25,0.1);
            curtain_tr = baseTr * transl(0.7, 0.25, 0);

            self.ur = ur3(ur_tr);
            if (strcmp(mode,'PvP'))
                self.environment = PlaceObject('robotRoom_PvP.ply', [0 0 0]);
                self.tm5 = omronTM5(omron_tr);
            else
                self.environment = PlaceObject('robotRoom_PvE.ply', [0 0 0]);
                self.curtain = lightCurtain(curtain_tr);
            end
            self.board = ChessBoard();            
            
            % self.omron_stand = PlaceObject('omron_stand.ply', [0.75 0.25 0]);
            % bucket0_pos = [self.board.dump0(1,4),self.board.dump0(2,4), self.board.dump0(3,4)]
            % self.bucket0 = PlaceObject('bucket.ply', bucket0_pos);

            %place the floor into the world.
            surf([-5,-5; 5,5] ...
                ,[-5,5;-5,5] ...
                ,[-0.8,-0.8;-0.8,-0.8] ...
                ,'CData',imread('concrete.jpg') ...
                ,'FaceColor','texturemap');

            view(3)
            axis([-1 1.25 -1 1 -0.1 1.5])
            
            end
    end
    
end

