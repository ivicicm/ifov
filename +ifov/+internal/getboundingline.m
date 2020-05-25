function line = getboundingline(ADown, AUp, angle)
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
%ENDDOC===================================================================

ADownRotated = exp(1i * angle)*ADown;
AUpRotated = exp(1i * angle)*AUp;

if angle <= pi/2
    CDown = ADownRotated + ADownRotated';
    CUp = AUpRotated + AUpRotated';
else
    CDown = AUpRotated + AUpRotated';
    CUp = ADownRotated + ADownRotated';
end
DDown = ADownRotated + AUpRotated';
DUp = AUpRotated + ADownRotated';
DDown = DDown - diag(diag(DDown));

CCenter = (CDown + CUp)/2;
CDelta = (CUp - CDown)/2;
DCenter = (DDown + DUp)/2;
DDelta = (DUp - DDown)/2;

bound = eigs([CCenter DCenter'; DCenter CCenter],1,'largestreal')...
    + abs(eigs([CDelta DDelta; DDelta CDelta],1,'largestabs'));

line = exp(-1i*angle)*[bound; bound + 1i];
end

