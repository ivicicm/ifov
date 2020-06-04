function coordinates = fov(A,rotationCount)
%BEGINDOC=================================================================
% .Description.
%
%  Computes field of values of a real matrix A.
%
%-------------------------------------------------------------------------
% .Input parameters.
%   
%   A ... real square matrix
%   rotationCount ... number of times matrix will be rotated during
%   function execution. Parameter is optional, default value is 30.
%
%------------------------------------------------------------------------
% .Output parameters.
%
%  coordinates ... vector of complex numbers - represents coordinates of
%  bound of field of values in complex plane. Number of coordinates is
%  rotationCount * 2 - 2
%
%ENDDOC===================================================================

% Assigning default values
if nargin < 2
    rotationCount = 30;
end

fov = ifov.internal.FOV(rotationCount);
fov.insertFromTwoMatrices(A,A);
coordinates = fov.Coordinates;

end

