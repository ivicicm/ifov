 classdef FOV < handle
 %BEGINDOC=================================================================
% .Description.
%
%   Computes convex hull from union of fields of values of inserted real
%   matrices. The hull can be obtained in form of coordinates of boundry
%   points in complex plane
%
%-------------------------------------------------------------------------
% .Constructor input parameters.
%   
%   rotationCount ... number of boundry points will be rotationCount * 2 -
%   2
%   
%------------------------------------------------------------------------
% .Public methods and properties.
%
%   MatrixCount ... number of inserted matrices so far
%   Coordinates ... coordinates of boundry points in complex plane
%   
%   
%
%ENDDOC===================================================================
    
    properties (Access = private)
        BoundryPoints % 2 column matrix, 1st column boundry points, 2nd column corresponding eigenvalues
        RotationCount
    end
    properties (SetAccess = private)
        MatrixCount = 0
    end
    properties (Dependent)
       Coordinates % vector of coordinates on the convex hull
    end
        
    methods
        function obj = FOV(rotationCount)        
            obj.RotationCount = rotationCount;
            obj.BoundryPoints = zeros(rotationCount, 2);
        end
        
        function coordinates = get.Coordinates(obj)
            if obj.MatrixCount == 0
                throw(MException('FOV:noMatrices' ,'No matrices were inserted.'));
            end
            % coordinates are symmetrical according to real axis, adding
            % negative part
            upCoordinates = obj.BoundryPoints(:,1);
            downCoordinates = flip(conj(upCoordinates(2:end-1)));
            coordinates = [upCoordinates; downCoordinates];
        end  
        
        function insertMatrix(obj,A)
            for i = 0:(obj.RotationCount - 1)
            	angle = i / (obj.RotationCount - 1) * pi;
                ARotated = exp(1j*angle)*A;
                ARotatedHermitian = (ARotated + ARotated')/2;
                [V,D] = eig(ARotatedHermitian);
                eigenvalues = real(diag(D));
                
                [maxEigval, maxIndex] = max(eigenvalues);
                if obj.MatrixCount == 0 || obj.BoundryPoints(i+1, 2) < maxEigval
                    % assigning new max value in the direction of angle
                    obj.BoundryPoints(i+1, 2) = maxEigval;
                    maxEigvector = V(:, maxIndex);
                    maxEigvector = maxEigvector/norm(maxEigvector);
                    obj.BoundryPoints(i+1, 1) = maxEigvector'*A*maxEigvector;
                end
            end
            obj.MatrixCount = obj.MatrixCount + 1;
        end
        
        function insertTwoMatrices(obj,matrices) % matrices is a 3D array 
            % of 2 2D matrices. First matrix is used for angles 0 - pi/2, 
            % second for angles pi/2 - pi
            i = 0;          
            for k = 1:2
                while i <= (obj.RotationCount - 1)/2*k
                    A = matrices(:,:,k);
                    % following code is almost the same as in isertMatrix
                    angle = i / (obj.RotationCount - 1) * pi;
                    ARotated = exp(1j*angle)*A;
                    ARotatedHermitian = (ARotated + ARotated')/2;
                    [V,D] = eig(ARotatedHermitian);
                    eigenvalues = real(diag(D));
                
                    [maxEigval, maxIndex] = max(eigenvalues);
                    if obj.MatrixCount == 0 || obj.BoundryPoints(i+1, 2) < maxEigval
                        obj.BoundryPoints(i+1, 2) = maxEigval;
                        maxEigvector = V(:, maxIndex);
                        maxEigvector = maxEigvector/norm(maxEigvector);
                        obj.BoundryPoints(i+1, 1) = maxEigvector'*A*maxEigvector;
                    end
                    i = i+1;
                end
            end
            obj.MatrixCount = obj.MatrixCount + 1;
        end
    end    
end

