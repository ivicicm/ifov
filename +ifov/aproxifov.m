function coordinates = aproxifov(ADown, AUp, rotationCount)
%BEGINDOC=================================================================
% .Description.
%
%  Computes aproximation of field of values of interval matrix A.
%  Takes polynomial time with respect to the size of A and rotationCount.
%
%-------------------------------------------------------------------------
% .Input parameters.
%
%   AUp ... upper bound of interval matrix A
%   ADown ... lower bound of interval matrix A
%   rotationCount ... number of times matrix will be rotated during
%   function execution. Parameter is optional, default value is 30.
%
%------------------------------------------------------------------------
% .Output parameters.
%
%  coordinates ... vector of complex numbers - represents vertices of a polygon 
%  that bounds field of values in complex plane. Number of coordinates is 
%  rotationCount * 2 - 2
%
%ENDDOC===================================================================

% Checking parameters and assigning default values
if size(ADown,1) ~= size(AUp,1) || ~isequal(ADown <= AUp, true(size(ADown)))
    throw(MException('fov:notIntervalMatrix' ,'Interval matrix A is not defined correctly.'));
end
if nargin < 3
    rotationCount = 30;
end

lines = zeros(2, rotationCount); % array of lines defined by two points
% Computing the bounding lines
for i = 0:(rotationCount - 1)
   angle = i/(rotationCount -1)*pi;
   points = ifov.internal.getboundingline(ADown,AUp,-angle);
   lines(:,i+1) = points;
end

% vertices will represent points in the upper half of the bounding polygon
% we start by infinite polygon defined by three lines. Then we intersect it
% with all the halfspaces from the remaining lines.
vertices = [intersectLines(lines(:,1),lines(:,fix(rotationCount/2)+1)),...
    intersectLines(lines(:,fix(rotationCount/2)+1),lines(:,end))];

for i = (rotationCount - 2):-1:2
    if i == fix(rotationCount/2)+1
        continue
    end
    [removedFrom, intersectionFrom, removedTo, intersectionTo] = intersectHull(vertices, lines(:,i));
    if removedFrom == -1
        % no intersection
        continue;
    end
    vertices = [vertices(1:(removedFrom-1)) intersectionFrom intersectionTo vertices((removedTo+1):end)];
end

% Bounding the polyngon by the real axix
[removedFrom, intersectionFrom, removedTo, intersectionTo] = intersectHull(vertices, [0; 1]);
upperHalf = vertices(removedFrom:removedTo);
% Adding the lower half of the polygon by inverting the upper
vertices = [intersectionFrom upperHalf intersectionTo flip(conj(upperHalf))];
coordinates = vertices';

function [removedFrom, intersectionFrom, removedTo, intersectionTo] = intersectHull(hull, line)
    % hull is an infinite convex polygon defined by array of points. Line segments go between them and the
    % two lines from the first and last point lead straight down.
    % line is a vector of two points that define a line. We assume that line 
    % is not parallel to any line in the hull. The line
    % intersects at two points with the lines of the polygon -
    % intersectionTo and intersectionFrom. removedFrom and removedTo
    % indicate an interval of points that will be cut off from the hull if
    % we make an intersection of the halfspace defined by line and the
    % infinite polygon.
    % Returns -1 in all arguments if the line doesn't intersect with the
    % polygon or it intersects with it in only one point.
    
    foundFirst = false; % states whether the first intersection point was found
    % checking intersection with the line from first point leading down
    [intersection, mul] = intersectLines([hull(1);hull(1)-1i], line);
    if mul >= 0
        foundFirst = true;
        intersectionFrom = intersection;
        removedFrom = 1;
    end
    for j = 1:(length(hull)-1)
        [intersection, mul] = intersectLines([hull(j);hull(j+1)], line);
        if mul > 0 && mul <= 1
            if ~foundFirst
                foundFirst = true;
                intersectionFrom = intersection;
                removedFrom = j+1;
            else
                intersectionTo = intersection;
                removedTo = j;
                return;
            end
        end
    end
    if foundFirst == false
        % no intersection
        removedFrom = -1;
        intersectionFrom = -1;
        removedTo = -1;
        intersectionTo = -1;
        return
    end
    % checking intersection with the line from last point leading down
    [intersection, mul] = intersectLines([hull(end);hull(end)-1i], line);
    if mul <= 0
        % intersection with only one point of the hull
        removedFrom = -1;
        intersectionFrom = -1;
        removedTo = -1;
        intersectionTo = -1;
        return
    end
    intersectionTo = intersection;
    removedTo = length(hull)-1;
end

function [intersection, pmul, qmul] = intersectLines(p, q)
    % Computes intersection of two lines. p and q are vectors of two complex
    % numbers - two points which define a line. pmul is the number with
    % which we multiply the difference of the two points in p.
    % This multiplied difference plus first point in p is equal to the 
    % intersection of the two lines. Similarly for qmul.
    
    u = p(2) - p(1);
    v = q(2) - q(1);
    
    A = [real(u) -real(v); imag(u) -imag(v)];
    b = [real(q(1)) - real(p(1)); imag(q(1)) - imag(p(1))];
    
    warning('off','MATLAB:singularMatrix')
    warning('off','MATLAB:nearlysingularMatrix')
    x = A\b;
    warning('on','MATLAB:nearlysingularMatrix')
    warning('on','MATLAB:singularMatrix')
    
    intersection = p(1) + x(1)*u; % = q(1) + x(2) * v 
    pmul = x(1);
    qmul = x(2);
end
end

