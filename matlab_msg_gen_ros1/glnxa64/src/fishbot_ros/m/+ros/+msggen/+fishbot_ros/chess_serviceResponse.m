
classdef chess_serviceResponse < ros.Message
    %chess_serviceResponse MATLAB implementation of fishbot_ros/chess_serviceResponse
    %   This class was automatically generated by
    %   ros.internal.pubsubEmitter.
    %   Copyright 2014-2020 The MathWorks, Inc.
    properties (Constant)
        MessageType = 'fishbot_ros/chess_serviceResponse' % The ROS message type
    end
    properties (Constant, Hidden)
        MD5Checksum = '52369bcdf3840fa4a649505110518725' % The MD5 Checksum of the message definition
        PropertyList = { 'Move' } % List of non-constant message properties
        ROSPropertyList = { 'move' } % List of non-constant ROS message properties
        PropertyMessageTypes = { '' ...
            } % Types of contained nested messages
    end
    properties (Constant)
    end
    properties
        Move
    end
    methods
        function set.Move(obj, val)
            val = convertStringsToChars(val);
            validClasses = {'char', 'string'};
            validAttributes = {};
            validateattributes(val, validClasses, validAttributes, 'chess_serviceResponse', 'Move');
            obj.Move = char(val);
        end
    end
    methods (Static, Access = {?matlab.unittest.TestCase, ?ros.Message})
        function obj = loadobj(strObj)
        %loadobj Implements loading of message from MAT file
        % Return an empty object array if the structure element is not defined
            if isempty(strObj)
                obj = ros.msggen.fishbot_ros.chess_serviceResponse.empty(0,1);
                return
            end
            % Create an empty message object
            obj = ros.msggen.fishbot_ros.chess_serviceResponse(strObj);
        end
    end
end