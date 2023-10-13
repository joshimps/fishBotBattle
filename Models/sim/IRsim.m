classdef IRsim < handle
    %brick A class that creates a herd of robot cows
    %   The cows can be moved around randomly. It is then possible to query
    %   the current location (base) of the cows.

    %#ok<*TRYNC>

    properties
        ur;
        tm5;
        chess;
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

            world_offset = baseTr * transl(1,0,0);

            self.ur = ur3(baseTr);
            self.tm5 = omronTM5(world_offset);
            self.chess = chess();
            self.environment = PlaceObject('robotRoom.ply', [0 0 0]);
            

            end
        end

    
    
end

