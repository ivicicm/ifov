% This script includes example use of all the public functions in this
% package.
hold on;

ADown = [1 2 3; 4 1 0; 0 1 3];
AUp = [2 5 3; 5 3 0; 1 1 4];
% Interval matrix A will be defined as [ADown, AUp]

% fov
% Plotting field of values of real matrix ADown. 
coords = ifov.fov(ADown,30);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));

% ifov
% Plotting convex hull of field of values of interval matrix A 
% using basic algorithm. 
coords = ifov.ifov(ADown,AUp,30);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));

% anglesifov
% Plotting convex hull of field of values of interval matrix A 
% using angle algorithm. 
coords = ifov.anglesifov(ADown,AUp,30);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));

% aproxifov
% Plotting upper bound of field of values of interval matrix A.
coords = ifov.aproxifov(ADown,AUp,30);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));