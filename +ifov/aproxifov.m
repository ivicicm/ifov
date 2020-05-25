function coordinates = aproximatrixfov(ADown, AUp, rotationCount)

lines = zeros(2, rotationCount);
for i = 0:(rotationCount - 1)
   angle = i/(rotationCount -1)*pi; 
   points = ifov.internal.getboundingline(ADown,AUp,-angle);
   lines(:,i+1) = points;
end
vertices = [intersectLines(lines(:,1),lines(:,rotationCount/2+1)),...
    intersectLines(lines(:,rotationCount/2+1),lines(:,end))];

for i = (rotationCount - 2):-1:2
    if i == rotationCount/2+1
        continue
    end
    [removedFrom, intersectionFrom, removedTo, intersectionTo] = intersectHull(vertices, lines(:,i));
    vertices = [vertices(1:(removedFrom-1)) intersectionFrom intersectionTo vertices((removedTo+1):end)];
end

[removedFrom, intersectionFrom, removedTo, intersectionTo] = intersectHull(vertices, [0; 1]);
upperHalf = vertices(removedFrom:removedTo);
vertices = [intersectionFrom upperHalf intersectionTo flip(conj(upperHalf))];
coordinates = vertices';

function [removedFrom, intersectionFrom, removedTo, intersectionTo] = intersectHull(hull, line)
    foundFirst = false;
    [intersection, mul] = intersectLines([hull(1);hull(1)-1i], line);
    if mul > 0
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
    intersection = intersectLines([hull(end);hull(end)-1i], line);
    intersectionTo = intersection;
    removedTo = length(hull)-1;
end

function [intersection, pmul, qmul] = intersectLines(p, q)
    u = p(2) - p(1);
    v = q(2) - q(1);
    
    A = [real(u) -real(v); imag(u) -imag(v)];
    b = [real(q(1)) - real(p(1)); imag(q(1)) - imag(p(1))];
    
    x = A\b;
    intersection = p(1) + x(1)*u; % = q(1) + x(2) * v 
    pmul = x(1);
    qmul = x(2);
end
end

