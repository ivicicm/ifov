function insertCornerMatrices(ADown ,AUp, fov)
%BEGINDOC=================================================================
% .Description.
%
%   Generates 2^(n*(n-1)) matrices from interval matrix A, union of their 
%   fields of values is the field of value of A. The function inserts all
%   these matrices to fov using insertMatrix method.
%
%-------------------------------------------------------------------------
% .Input parameters.
%   
%   ADown ... lower bound of interval matrix A
%   AUp ... upper bound of interval matrix A
%   fov ... instance of class FOV
%
%------------------------------------------------------------------------
% .Output parameters.
%
%------------------------------------------------------------------------
% .Implementation details. 
%
%   Generated matrices and proof of correctness are described
%   in hledani_vlastniho_cisla.pdf
%
%ENDDOC===================================================================

d = size(AUp,1);

% 1x1 interval matrix was entered 
if d == 1
    fov.insertMatrix(AUp);
    return
end

length = d*(d-1); % count of the nondiagonal elements of a matrix,
% we can assign each nondiagonal element of matrix a unique number - its
% position in matrix

% First column of Elements maps the position of an element 
% in matrix to its x coordinate, second column to its
% y coordinate
Elements = zeros(length, 2);
index = 1;
for i = 1:d
    for j = 1:d
       if i ~= j
           Elements(index,:) = [i j];
           index = index + 1;
       end
    end
end

A = AUp;
values = zeros(length,1); % Element of values with index i represents
% a nondiagonal element of A in position i. If it is 0, than the matrix
% element takes its value from AUp, if it is 1, matrix element takes value
% from ADown

% values can have 2^length different values, from these we obtain matrices
% which we insert to fov. We iterate through values by "binariy adding 1"
% to values
fov.insertMatrix(A);
i = 1; % index to position in values
justReturned = false; % true if under ith element in values are only ones
while i > 0
    if values(i) == 0 
       if justReturned
           justReturned = false;
           values(i) = 1;
           values((i+1):end) = 0;
           A(Elements(i,1),Elements(i,2)) = ADown(Elements(i,1),Elements(i,2));
           for k = (i+1):length
               A(Elements(k,1),Elements(k,2)) = AUp(Elements(k,1),Elements(k,2));
           end
           fov.insertMatrix(A);
           i = i+1;
       else
           if i == length
               values(i) = 1;
               A(Elements(i,1),Elements(i,2)) = ADown(Elements(i,1),Elements(i,2));
               fov.insertMatrix(A);
           else
              i = i+1; 
           end
       end
    else % values(i) == 1
        i = i - 1;
        justReturned = true;
    end
end





