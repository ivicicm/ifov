function coordinates = ifov(ADown, AUp, rotationCount)
%BEGINDOC=================================================================
% .Description.
%
%  Computes convex hull of field of values of interval matrix A. The
%  function uses basic algorithm.
%
%-------------------------------------------------------------------------
% .Input parameters.
%
%   AUp ... upper bound of interval matrix A
%   ADown ... lower bound of interval matrix A
%   rotationCount ... number of times matrix will be rotated during
%   function execution
%
%------------------------------------------------------------------------
% .Output parameters.
%
%  coordinates ... vector of complex numbers - represents bounds of convex 
%  hull of field of values in complex plane. Number of coordinates is 
%  rotationCount * 2 - 2
%
%ENDDOC===================================================================

fov = ifov.internal.FOV(rotationCount);
ifov.internal.insertboundarymatrices(ADown, AUp, fov)
coordinates = fov.Coordinates;

end