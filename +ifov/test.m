
A = rand(3);
coords = ifov.matrixfov(A,50);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));
