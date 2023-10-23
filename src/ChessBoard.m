classdef ChessBoard < handle
    %CHESSBOARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posGrid;
        chessPieces; 
        dump0; % dump zone for robot 0
        dump1; % dump zone for robot 1
        tempZone; %temp zone for castling
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
            obj.dump0 = base * transl(-0.15, 0.55, 0.1) * troty(pi) * trotz(-pi);
            obj.dump1 = base * transl(0.55, 0.70, 0.1) * troty(pi) * trotz(-pi);
        end
        
        function SpawnPosGrid(obj, base)
            index = 0;
            base = base * transl(0,0.4,0);
            for i = 1:1:8
                for j = 1:1:8
                    xOff = (i-1) * obj.gridSize + obj.gridSize/2;
                    yOff = (j-1) * obj.gridSize + obj.gridSize/2;
                    obj.posGrid{i,j}.pose = base * troty(pi) + [0 0 0 xOff;
                                                           0 0 0 -yOff;
                                                           0 0 0 0;
                                                           0 0 0 0];
                    index = index + 1;
                    if index < 17 || index > 48
                        if index > 48
                            pieceIndex = index - 32;
                        else
                            pieceIndex = index;
                        end
                        obj.chessPieces.chessModel{pieceIndex}.base = obj.posGrid{i,j}.pose * troty(-pi) * transl(0,0,0.14) ;
                        obj.posGrid{i,j}.piece  = obj.chessPieces.chessModel{pieceIndex};
                        obj.chessPieces.chessModel{pieceIndex}.animate(0);
                    end
                end
            end
        end
    end
end

