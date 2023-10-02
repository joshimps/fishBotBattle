classdef ChessBoard < handle
    %CHESSBOARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posGrid;
        gridSize = 0.05; 
    end
    
    methods
        function obj = ChessBoard(base)
            obj.posGrid = cell(8,8);
            obj.modPosGrid(base);
        end
        
        function modPosGrid(obj, base)
            for i = 1:1:8
                for j = 1:1:8
                    xOff = (j-1) * obj.gridSize + obj.gridSize/2;
                    yOff = (i-1) * obj.gridSize + obj.gridSize/2;
                    obj.posGrid{i,j} = base * troty(pi) + [0 0 0 xOff;
                                                           0 0 0 yOff;
                                                           0 0 0 0;
                                                           0 0 0 0];
                end
            end
        end
    end
end

