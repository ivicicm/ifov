 classdef FOV < handle
 %BEGINDOC=================================================================
% .Description.
%
%   Computes convex hull from union of fields of values of inserted real
%   matrices. The hull can be obtained in form of coordinates of boundary
%   points in complex plane.
%
%-------------------------------------------------------------------------
% .Constructor input parameters.
%   
%   rotationCount ... number of boundary points will be rotationCount * 2 -
%   2
%   
%------------------------------------------------------------------------
% .Public methods and properties.
%
%   MatrixCount ... number of inserted matrices so far
%   Coordinates ... coordinates of boundary points in complex plane
%   insertFromTwoMatrices ... requires array of two matrices as input, first
%   matrix is rotated from 0 to pi/2, second from pi/2 to pi
%
%ENDDOC===================================================================
    
    properties (Access = private)
        BoundaryPoints % 2 column matrix, 1st column boundary points, 2nd column corresponding eigenvalues
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
            obj.BoundaryPoints = zeros(rotationCount, 2);
        end
        
        function coordinates = get.Coordinates(obj)
            % Returns coordinates of boundary points of union of fields of
            % values of inserted matrices. It is a vector of complex
            % numbers.
                
            if obj.MatrixCount == 0
                throw(MException('fov:noMatrices' ,'No matrices were inserted.'));
            end
            upCoordinates = obj.BoundaryPoints(:,1);
            % rounding real values close to zero to zero
            for i = 1:size(upCoordinates)
                if abs(real(upCoordinates(i))) < 1e-15
                    upCoordinates(i) = 1i*imag(upCoordinates(i));
                end
            end
            % coordinates are symmetrical according to real axis, adding
            % negative part
            downCoordinates = flip(conj(upCoordinates(2:end-1)));
            coordinates = [upCoordinates; downCoordinates];
        end
        
        function insertFromTwoMatrices(obj, Right, Left) 
            % Adds right boundary ([-pi/2,pi/2]) of field of values of 
            % matrix Right to the union of fields of values of already 
            % inserted matrices. Also adds left boundary
            % of matrix Left. To insert field of values of only one matrix A,
            % use insertTwoMatrices(A,A).
            
            matrices = Right;
            matrices(:,:,2) = Left;
            i = 0;          
            for k = 1:2
                while i <= (obj.RotationCount - 1)/2*k
                    A = matrices(:,:,k);
                    angle = i / (obj.RotationCount - 1) * pi;
                    ARotated = exp(1j*angle)*A;
                    ARotatedHermitian = (ARotated + ARotated')/2;
                    [V,D] = eig(ARotatedHermitian);
                    eigenvalues = real(diag(D));
                
                    [maxEigval, maxIndex] = max(eigenvalues);
                    if obj.MatrixCount == 0 || obj.BoundaryPoints(i+1, 2) < maxEigval
                        % assigning new max value in the direction of angle
                        obj.BoundaryPoints(i+1, 2) = maxEigval;
                        maxEigvector = V(:, maxIndex);
                        maxEigvector = maxEigvector/norm(maxEigvector);
                        obj.BoundaryPoints(i+1, 1) = maxEigvector'*A*maxEigvector;
                    end
                    i = i+1;
                end
            end
            obj.MatrixCount = obj.MatrixCount + 1;
        end
    end    
end

