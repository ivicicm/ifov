% tests antisymmetrical matrix

AUp = rand(4);
AUp = AUp-AUp';
coords = ifov.matrixfov(AUp,10);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));