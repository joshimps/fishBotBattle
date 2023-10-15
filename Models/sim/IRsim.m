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
        world_offset;
        environment;

    end

    methods
        %% ...structors
        function self = IRsim(baseTr)
            if nargin < 1
                baseTr = eye(4);
            end
            
            ur_tr = baseTr * transl(-0.2, 0.25, 0);
            omron_tr = baseTr * transl(0.7,0.25,0);
            self.ur = ur3(ur_tr);
            self.tm5 = omronTM5(omron_tr);
            self.board = ChessBoard();
            self.environment = PlaceObject('robotRoom.ply', [0 0 0]);
            

            end
        end

    
    
end

