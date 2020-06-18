function line = getboundingline(ADown, AUp, angle)
%BEGINDOC=================================================================
% .Description.
%
%   Computes a line that bounds field of values of interval matrix A
%
%-------------------------------------------------------------------------
% .Input parameters.
%   
%   ADown ... lower bound of interval matrix A
%   AUp ... upper bound of interval matrix A
%   angle ... angle from which the field of values will be bounded, 
%   only works for values in [-pi,0] 
%
%------------------------------------------------------------------------
% .Output parameters.
%
%   lines ... vector of 2 complex numbers - points in complex plane. The
%   line is defined by those 2 points.
%
%ENDDOC===================================================================

ADownRotated = exp(1i * angle)*ADown;
AUpRotated = exp(1i * angle)*AUp;

% Constructs complex interval matrix A + iB
if angle >= -pi/2
    CDown = real(ADownRotated + ADownRotated')/2;
    CUp = real(AUpRotated + AUpRotated')/2;
else
    CDown = real(AUpRotated + AUpRotated')/2;
    CUp = real(ADownRotated + ADownRotated')/2;
end
DDown = imag(AUpRotated + ADownRotated')/2;
DUp = imag(ADownRotated + AUpRotated')/2;

% optimizing diagonal values
CDown = CDown + diag(diag(CUp) - diag(CDown));
DDown = DDown - diag(diag(DDown));
DUp = DUp - diag(diag(DUp));

CCenter = (CDown + CUp)/2;
CDelta = (CUp - CDown)/2;
DCenter = (DDown + DUp)/2;
DDelta = (DUp - DDown)/2;

bound = eigs([CCenter DCenter'; DCenter CCenter],1,'la')...
    + abs(eigs([CDelta DDelta; DDelta CDelta],1,'lm'));

line = exp(-1i*angle)*[bound; bound + 1i];
end

