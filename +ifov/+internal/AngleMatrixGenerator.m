classdef AngleMatrixGenerator < handle
    properties
       ADown
       AUp
    end
    properties (Access = private)
        fov
        matrixCodes
        d
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
           obj.matrixCodes = false(2^(obj.d*(obj.d-1)),1);
           angles = zeros(obj.d, 2); 
           % first column means to what index the 
           % angle from current index is less than alpha
           % second colomn means maximum index
           % the arc can go to
           obj.generateAngles(angles, 1, 1);
        end
    end
    methods (Access = private)
        function A = generateMatrix(obj, angles, rotations, permutations)
            A = eye(obj.d); % matrix of 1s and 0s 
            for j = 1:obj.d
                xj = permutations(j);
                for i = 1:obj.d
                    if i >= j
                        break;
                    end
                    xi = permutations(i);
                    xmin = min([xi; xj]);
                    xmax = max([xi; xj]);
                    if angles(xmin) >= xmax % xi and xj are less than alpha appart
                        if rotations(i) == rotations(j)
                            % right corner
                            A(i,j) = 1; A(j,i) = 1;
                        else
                            % left corner
                            % A(i,j) = 0; A(j,i) = 0;
                        end
                    elseif angles(xmin) < xmin ... % xi and xj more than pi - alpha appart
                        || (angles(xmax) < xmax && angles(xmax) >= xmin)
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
            % returns true if matrix hasn't been inserted
            matrixCode = int64(0);
            for j = 1:obj.d
                for i = 1:obj.d
                    if i == j
                        continue
                    end
                    matrixCode = 2 * matrixCode + int64(A(i,j)); % Horner scheme
                end
            end
            matrixCode = matrixCode + 1; % 0 can't be index
            result = ~ obj.matrixCodes(matrixCode);
            if result
               obj.matrixCodes(matrixCode) = true; 
            end
        end
        
        function insertMatrices(obj, A)
            matrices = zeros(obj.d,obj.d,4);
            for j=1:obj.d
               for i=1:obj.d
                   if i == j
                       for k=1:4
                          matrices(i,i,k) = obj.AUp(i,i); 
                       end
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
                       matrices(i,j,3) = newValue;
                       matrices(j,i,3) = newValue;
                   else
                       matrices(i,j,2) = aij;
                       matrices(j,i,2) = aji;
                       matrices(i,j,3) = aji;
                       matrices(j,i,3) = aij;
                   end                
                   matrices(i,j,4) = aji;
                   matrices(j,i,4) = aij;
                   
                   for k=1:4
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
            obj.fov.insertMatrices(matrices);
        end
        
        function createAndAddMatrix(obj, angles, rotations, permutations)
            A = obj.generateMatrix(angles, rotations, permutations);
            if obj.testMatrix(A)
                obj.insertMatrices(A);
            end
        end
        
        function generatePermutationsAndRotations(obj, angles, rotations, permutations, notPermuted)
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
            
        function generateAngles(obj,angles,i,min)
            if i > obj.d
                obj.generatePermutationsAndRotations(angles(:,1),[], [], 2:(obj.d));
                return 
            end
            if min >= i - 1
                if min == i - 1
                    min = i;
                end
                for k = min:obj.d % bound will be to the right of i
                    if i == 1 || i < angles(k,2)
                        angles(k,2) = i; % sum of 2 angles can't be more than pi
                    end
                    nextAngles = angles;
                    if i == 1 && k < obj.d
                       for m = (k+1):obj.d
                           nextAngles(m,2) = k; % can't go beyond first bound
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
            max = angles(i,2);
            for k = min:max % bound will be to the left of i
                nextAngles = angles;
                nextAngles(i,1) = k;
                obj.generateAngles(nextAngles,i+1,k);
            end
        end
    end
end
