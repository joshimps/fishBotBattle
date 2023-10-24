% Handle classes are called by reference. This vector class is created to
% ensure that the vector is passed in by reference in recursive functions.
% Similar to a pointer to an STL container in C++
classdef Vector < handle
    properties
        vector = [];
    end
end

