function coordinates = matrixfov(A,rotationCount)
%BEGINDOC=================================================================
% .Description.
%
%  Computes convex hull of a real matrix A.
%
%-------------------------------------------------------------------------
% .Input parameters.
%   
%   A ... real square matrix
%   rotationCount ... number of times matrix will be rotated during
%   function execution
%
%------------------------------------------------------------------------
% .Output parameters.
%
%  coordinates ... vector of complex numbers - represents coordinates of
%  bound of field of values in complex plane. Number of coordinates is
%  rotationCount * 2 - 2
%
%ENDDOC===================================================================

fov = ifov.internal.FOV(rotationCount);
fov.insertMatrix(A);
coordinates = fov.Coordinates;

end

