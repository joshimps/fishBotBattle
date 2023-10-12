function [data, info] = chess_serviceRequest
%chess_service gives an empty data for fishbot_ros/chess_serviceRequest
% Copyright 2019-2020 The MathWorks, Inc.
%#codegen
data = struct();
data.MessageType = 'fishbot_ros/chess_serviceRequest';
[data.PrevMove, info.PrevMove] = ros.internal.ros.messages.ros.char('string',0);
info.MessageType = 'fishbot_ros/chess_serviceRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,1);
info.MatPath{1} = 'prev_move';
