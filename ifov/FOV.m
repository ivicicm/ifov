 classdef FOV < handle
 %BEGINDOC=================================================================
% .Description.
%
%   Computes convex hull from union of fields of values of inserted 
%   matrices. The hull can be obtained in form of coordinates of boundry
%   points in complex plane
%
%-------------------------------------------------------------------------
% .Constructor input parameters.
%   
%   rotationCount ... number of boundry points
%
%------------------------------------------------------------------------
% .Public methods and properties.
%
%   Coordinates ... coordinates of boundry points in complex plane
%   insertMatrix ...
%   
%
%------------------------------------------------------------------------
% .Implementation details. 
%
%   Generated matrices and proof of correctness are described
%   in hledani_vlastniho_cisla.pdf
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
            coordinates = obj.BoundryPoints(:,1);
        end  
        
        function insertMatrix(obj,A)
            for i = 1:(obj.RotationCount)
            	angle = (i - 1) / obj.RotationCount * 2 * pi;
                ARotated = exp(1j*angle)*A;
                ARotatedHermitian = (ARotated + ARotated')/2;
                [V,D] = eig(ARotatedHermitian);
                eigenvalues = real(diag(D));
                
                [maxEigval, maxIndex] = max(eigenvalues);
                if obj.MatrixCount == 0 || obj.BoundryPoints(i, 2) < maxEigval
                    obj.BoundryPoints(i,2) = maxEigval;
                    maxEigvector = V(:, maxIndex);
                    maxEigvector = maxEigvector/norm(maxEigvector);
                    obj.BoundryPoints(i,1) = maxEigvector'*A*maxEigvector;
                end
            end
            obj.MatrixCount = obj.MatrixCount + 1;
        end
        
        function insertMatrices(obj,matrices) % matrices is 3D array of 4 2D matrices
            i = 1;          
            for k = 1:4
                while i <= obj.RotationCount/4*k
                    A = matrices(:,:,k);
                    angle = (i - 1) / obj.RotationCount * 2 * pi;
                    ARotated = exp(1j*angle)*A;
                    ARotatedHermitian = (ARotated + ARotated')/2;
                    [V,D] = eig(ARotatedHermitian);
                    eigenvalues = real(diag(D));
                
                    [maxEigval, maxIndex] = max(eigenvalues);
                    if obj.MatrixCount == 0 || obj.BoundryPoints(i, 2) < maxEigval
                        obj.BoundryPoints(i,2) = maxEigval;
                        maxEigvector = V(:, maxIndex);
                        maxEigvector = maxEigvector/norm(maxEigvector);
                        obj.BoundryPoints(i,1) = maxEigvector'*A*maxEigvector;
                    end
                    i = i+1;
                end
            end
            obj.MatrixCount = obj.MatrixCount + 1;
        end
    end    
    methods (Access = private) % this method is not used, calling it instead of using the code inline it might slow the program
        function insertMatrixRotation(obj,A,i) % can be modified in child class to compute eigenvalues differently       
            angle = (i - 1) / obj.RotationCount * 2 * pi;
            ARotated = exp(1j*angle)*A;
            ARotatedHermitian = (ARotated + ARotated')/2;
            [V,D] = eig(ARotatedHermitian);
            eigenvalues = real(diag(D));
                
            [maxEigval, maxIndex] = max(eigenvalues);
            if obj.MatrixCount == 0 || obj.BoundryPoints(i, 2) < maxEigval
                obj.BoundryPoints(i,2) = maxEigval;
                maxEigvector = V(:, maxIndex);
                maxEigvector = maxEigvector/norm(maxEigvector);
                obj.BoundryPoints(i,1) = maxEigvector'*A*maxEigvector;
            end
        end
    end
end

