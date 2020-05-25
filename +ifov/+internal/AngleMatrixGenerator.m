classdef AngleMatrixGenerator < handle
%BEGINDOC=================================================================
% .Description.
%
%   Used for inserting all matrices from interval matrix A that could have 
%   an effect on the shape of a convex hull of its field of values. The
%   matrices are inserted into an object.
%
%-------------------------------------------------------------------------
% .Constructor input parameters.
%   
%   ADown ... lower bound of interval matrix A
%   AUp ... upper bound of interval matrix A
%   
%------------------------------------------------------------------------
% .Public methods and properties.
%
%   generateAndInsert ... generates the matrices and inserts them one by
%   one into fov using insertFromTwoMatrices method. Details about the
%   method parameters are described in FOV.m
%
%ENDDOC===================================================================

    properties (Access = private)
        ADown
        AUp
        fov
        d % row or column count of A
        matrixPool % bool array of size 2^(d*(d-1)), each member represents 
            % a matrix. If its value is true, the matrix was already inserted
    end
   
    methods
        function obj = AngleMatrixGenerator(ADown, AUp)        
            obj.ADown = ADown;
            obj.AUp = AUp;
            obj.d = size(ADown,1);
        end
        
        function generateAndInsert(obj, fov) 
           obj.d = size(obj.ADown,1);
           if obj.d == 1
               fov.insertMatrix(obj.AUp)
               return
           end
           obj.fov = fov;
           obj.matrixPool = false(2^(obj.d*(obj.d-1)),1);
           angles = zeros(obj.d, 2); 
           obj.generateAngles(angles, 1, 1);
        end
    end
    methods (Access = private)
        function A = generateMatrix(obj, angles, rotations, permutations)
            % Returns matrix of 1s and 0s. If we substitute values from AUp
            % for ones and values from ADown for zeros, we get a real
            % matrix from interval matrix A.
            
            A = eye(obj.d);
            for j = 1:obj.d
                xj = permutations(j);
                for i = 1:obj.d
                    if i >= j
                        break;
                    end
                    xi = permutations(i);
                    xmin = min([xi; xj]);
                    xmax = max([xi; xj]);
                    if angles(xmin) >= xmax || angles(xmin) < xmin 
                        % xi and xj are less than alpha appart
                        if rotations(i) == rotations(j)
                            % right corner
                            A(i,j) = 1; A(j,i) = 1;
                        else
                            % left corner
                            % A(i,j) = 0; A(j,i) = 0;
                        end
                    elseif angles(xmax) < xmax && angles(xmax) >= xmin 
                        % xi and xj more than pi - alpha appart
                        if rotations(i) == rotations(j)
                            % left corner
                            % A(i,j) = 0; A(j,i) = 0;
                        else
                            % right corner
                            A(i,j) = 1; A(j,i) = 1;
                        end
                    elseif xi == xmin
                        if rotations(i) == rotations(j)
                            % upper corner
                            A(i,j) = 1; % A(j,i) = 0;
                        else
                            % lower corner
                            A(j,i) = 1; % A(i,j) = 0;
                        end
                    else % xj == xmin 
                        if rotations(i) == rotations(j)
                            % lower corner
                            A(j,i) = 1; % A(i,j) = 0;
                        else
                            % uppper corner
                            A(i,j) = 1; % A(j,i) = 0;
                        end
                    end
                end
            end
        end
        
        function result = testMatrix(obj,A)
            % returns true if matrix hasn't been inserted yet. If it hasn't 
            % been inserted, the corresponding element in matrixPool is set to true
            
            % A ... matrix of ones and zeros, diagonal elements are not
            % important
            
            matrixCode = int64(0);
            for j = 1:obj.d
                for i = 1:obj.d
                    if i == j
                        continue
                    end
                    matrixCode = 2 * matrixCode + int64(A(i,j)); % Horner scheme
                end
            end
            matrixCode = matrixCode + 1; % 0 can't be an index
            result = ~ obj.matrixPool(matrixCode);
            if result
               obj.matrixPool(matrixCode) = true; 
            end
        end
        
        function insertMatrices(obj, A)
            % First creates array of two matrices, first is A, second is a
            % matrix based on A used when the angle of rotation is more
            % than pi/2. Both are converted to matrices from interval
            % matrix A and are inserted to fov.
            
            matrices = zeros(obj.d,obj.d,2); % First matrix will be Right,
            % second Left
            for j=1:obj.d
               for i=1:obj.d
                   if i == j
                       matrices(i,i,1) = obj.AUp(i,i);
                       matrices(i,i,2) = obj.ADown(i,i); 
                       break
                   end
                   aij = A(i,j);
                   aji = A(j,i);
                   
                   matrices(i,j,1) = aij;
                   matrices(j,i,1) = aji;
                   if aij == aji
                       newValue = mod(aij + 1, 2);
                       matrices(i,j,2) = newValue;
                       matrices(j,i,2) = newValue;
                   else
                       matrices(i,j,2) = aij;
                       matrices(j,i,2) = aji;
                   end                
                   
                   for k=1:2
                       if matrices(i,j,k) == 1
                           matrices(i,j,k) = obj.AUp(i,j);
                       else
                           matrices(i,j,k) = obj.ADown(i,j);
                       end
                       if matrices(j,i,k) == 1
                           matrices(j,i,k) = obj.AUp(j,i);
                       else
                           matrices(j,i,k) = obj.ADown(j,i);
                       end
                   end
               end
            end
            obj.fov.insertFromTwoMatrices(matrices(:,:,1), matrices(:,:,2));
        end
        
        function createAndAddMatrix(obj, angles, rotations, permutations)
            A = obj.generateMatrix(angles, rotations, permutations);
            if obj.testMatrix(A)
                obj.insertMatrices(A);
            end
        end
        
        function generatePermutationsAndRotations(obj, angles, rotations, permutations, notPermuted)
            % Calls createAndAddMatrix with different rotations and
            % permutations
            
            % rotations ... bool array, represents for index i if xi has
            % positive imaginary part
            % permutations ... forms a permutation from notPermuted at the
            % end of recursion
            
            i = size(notPermuted, 2);
            if i == 0
                obj.createAndAddMatrix(angles, [0 rotations], [1 permutations]);
                return
            end
            for k = 1:i
                permutations(i) = notPermuted(k); 
                nextNotPermuted = notPermuted;
                nextNotPermuted(k) = [];
                
                rotations(i) = false;
                obj.generatePermutationsAndRotations(angles, rotations, permutations, nextNotPermuted);
                rotations(i) = true;
                obj.generatePermutationsAndRotations(angles, rotations, permutations, nextNotPermuted);
            end
        end
            
        function generateAngles(obj, angles, i, min)
            % Calls generatePermutationsAndRotations with different values
            % of angles.
            
            % angles ... 2 column matrix, first column at the end of the
            % recursion will mean to what index from the current index the
            % angle difference between xj and xi is less then alpha. The
            % column can be imagined as a circle becouse the interval
            % between xi and xj can start in the end of the column and
            % finish in the beginning. Second column is a bound for the first.
            % i ... current index in angles being recursively filled out
            % min ... minimal value for for angles(i,1)
            
            if i > obj.d
                obj.generatePermutationsAndRotations(angles(:,1),[], [], 2:(obj.d));
                return
            end
            if min >= i - 1
                if min == i - 1
                    min = i;
                end
                for k = min:obj.d % angle from i will end to the right of i
                    if i == 1 || i < angles(k,2)
                        angles(k,2) = i; % sum of 2 angles can't be more than pi,
                        % improving bounds
                    end
                    nextAngles = angles;
                    if i == 1 && k < obj.d 
                        % initializing the bounds of angles 
                        % so that no interval can contain the initial interval and
                        % also some elements to the right of it (all angles are of
                        % size alpha)
                       for m = (k+1):obj.d
                           nextAngles(m,2) = k;
                       end
                    end
                    nextAngles(i,1) = k;
                    obj.generateAngles(nextAngles,i+1,k);
                end
                min = 1;
            end
            if i == 1
                return
            end
            for k = min:angles(i,2) % angle will end to the left of i
                nextAngles = angles;
                nextAngles(i,1) = k;
                obj.generateAngles(nextAngles, i+1, k);
            end
        end
    end
end
