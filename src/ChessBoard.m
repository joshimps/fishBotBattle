classdef ChessBoard < handle
    %CHESSBOARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posGrid;
        chessPieces; 
        dump0; % dump zone for robot 0
        dump1; % dump zone for robot 1
        gridSize = 0.05; 
    end
    
    methods
        function obj = ChessBoard(base)
            if nargin < 1
                base = eye(4);
            end
            obj.posGrid = cell(8,8);
            obj.chessPieces = chess(); 
            obj.SpawnPosGrid(base);
        end
        
        function SpawnPosGrid(obj, base)
            for i = 1:1:8
                for j = 1:1:8
                    xOff = (j-1) * obj.gridSize + obj.gridSize/2;
                    yOff = (i-1) * obj.gridSize + obj.gridSize/2;
                    obj.posGrid{i,j}.pose = base * troty(pi) + [0 0 0 xOff;
                                                           0 0 0 yOff;
                                                           0 0 0 0.14;
                                                           0 0 0 0];
                    index = i+j-1;
                    if index > 16
                        index = index + 32;
                    end
                    obj.chessPieces.chessModel{index}.base = obj.posGrid{i,j}.pose;
                    obj.posGrid{i,j}.piece  = obj.chessPieces.chessModel{index};
                end
            end
        end
    end
end

