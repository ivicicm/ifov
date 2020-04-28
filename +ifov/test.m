
ADown = rand(3);
AUp = ADown + rand(3);
coords = ifov.imatrixfov(ADown,AUp,50);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));
