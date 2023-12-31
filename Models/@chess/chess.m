classdef chess < handle
    %brick A class that creates a herd of robot cows
    %   The cows can be moved around randomly. It is then possible to query
    %   the current location (base) of the cows.

    %#ok<*TRYNC>

    properties (Constant)
        %> Max height is for plotting of the workspace
        maxHeight = 10;
    end

    properties
        %> Number of cows
        chessCount = 32;

        chessModel;

        chessBoard;

        %> paddockSize in meters
        paddockSize = [1,1];

        %> Dimensions of the workspace in regard to the padoc size
        workspaceDimensions;

        % Chess Board Matrix
        board_matrix;

        vertex_size;

    end

    methods
        %% ...structors
        function self = chess(chessCount)
            if 0 < nargin
                self.chessCount = chessCount;
            end

            self.workspaceDimensions = [0. 0.4 0 0.4 0 1.5];


            self.chessBoard = self.GetChessModel;
            self.chessBoard.base = transl(0,0,0);
            plot3d(self.chessBoard,0,'workspace',self.workspaceDimensions,'view',[-30,30],'delay',0,'noarrow', 'nowrist');
            hold on;

            % Place the pieces in the correct location
            x = 0.3775;
            y = 0.0275;

            board_matrix = zeros(8,8);
            row = 1;
            
            for i = 1:self.chessCount
                n = mod(i,8);
                % base_pose = transl(x,y,0.155);
                base_pose = transl(x,y,0.14);
                
                if n > 0
                    self.board_matrix(row,n) = i;
                else
                    self.board_matrix(row,8) = i;
                end

                if i < 9 || i > 24 
                    switch n
                        case 1
                            self.chessModel{i} = self.GetChessModel('rook', i);
                        case 2
                            self.chessModel{i} = self.GetChessModel('knight', i);
                        case 3
                            self.chessModel{i} = self.GetChessModel('bishop', i);                     
                        case 4
                            self.chessModel{i} = self.GetChessModel('queen', i);    
                        case 5
                            self.chessModel{i} = self.GetChessModel('king', i);
                        case 6
                            self.chessModel{i} = self.GetChessModel('bishop', i);
                        case 7
                            self.chessModel{i} = self.GetChessModel('knight', i);
                        case 0
                            self.chessModel{i} = self.GetChessModel('rook', i);
                    end

                else
                    self.chessModel{i} = self.GetChessModel('pawn', i);
                end

                self.chessModel{i}.base = base_pose;

                if n == 0
                    x = x - 0.045;
                    y = 0.0275;
                    row = row + 1;
                    if i == 16
                      x = 0.070;
                      row = row + 4;
                    end
                else
                    y = y + 0.05;
                end
                
                if i < 17
                    % rgd_data = zeros(self.vertex_size,3)
                    colors = {'white'};
                else
                    colors = {'brown'};
                    % rgb_data = repmat(255, self.vertex_size, 3)
                end

                 % Plot 3D model
                plot3d(self.chessModel{i},0,'workspace',self.workspaceDimensions,'view',[-30,30],'delay',0,'noarrow', 'nowrist', 'tilesize', 0.05, 'color', colors);
                 %plot3d(self.chessModel{i},0,'workspace',self.workspaceDimensions,'view',[-30,30],'delay',0);

            end

            axis equal
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end

            

            end
        end

    methods (Static)
        %% GetChessModel
        function model = GetChessModel(name, id)
            if nargin < 1
                name = 'board';
                [faceData,vertexData] = plyread('Chess Board Simple-Assembly.PLY','tri');
                piece = 'board0';
            end
            
            % Uncomment out this section once ply files are fixed.
            switch name
                case 'board'
                    [faceData,vertexData] = plyread('Chess Board Simple-Assembly.PLY','tri');
                case 'rook'
                    [faceData,vertexData] = plyread('rook_prism_meshlab.ply','tri');
                case 'knight'
                    [faceData,vertexData] = plyread('knight_prism_meshlab.ply','tri');
                case 'bishop'
                    [faceData,vertexData] = plyread('bishop_prism_meshlab.ply','tri');
                case 'queen'
                    [faceData,vertexData] = plyread('queen_prism_meshlab.ply','tri');
                case 'king'
                    [faceData,vertexData] = plyread('King_Prism_meshlab.ply','tri');
                case 'pawn'
                    [faceData,vertexData] = plyread('pawn_prism_meshlab.ply','tri');
            end

                            
            if ~(strcmp(name, 'board'))
                piece = [name,num2str(id)];
            end

            if strcmp(name, 'board')
                [faceData,vertexData] = plyread('Chess Board Simple-Assembly.PLY','tri');
                piece = 'board0';
            end

            % if ~(strcmp(name, 'board'))
            %     [faceData,vertexData] = plyread('test_block.ply','tri');
            %     piece = [name,num2str(id)];
            % end

          
            link1 = Link('alpha',0,'a',0,'d',0,'offset',0);
            model = SerialLink(link1,'name',piece);

            % Changing order of cell array from {faceData, []} to
            % {[], faceData} so that data is attributed to Link 1
            % in plot3d rather than Link 0 (base).
            faceData;
            model.faces = {[], faceData};

            % Changing order of cell array from {vertexData, []} to
            % {[], vertexData} so that data is attributed to Link 1
            % in plot3d rather than Link 0 (base).
            model.points = {[], vertexData};

            


        end

        function moveBrick(self, brickIndex, transformationMatrix)
            % Moves a brick to a new location using a transformation matrix
            % Inputs:
            %   - brickIndex: Index of the brick to be moved
            %   - transformationMatrix: 4x4 transformation matrix (SE3) for the new location

            % Check if brickIndex is valid
            if brickIndex < 1 || brickIndex > self.brickCount
                error('Invalid brick index');
            end

            % Update the base pose of the specified brick
            self.brickModel{brickIndex}.base = transformationMatrix;

            % Redraw the scene with the updated brick location
        end

        function board = getChessBoard(self)

            board = self.board_matrix;

        end

    
    end
end

