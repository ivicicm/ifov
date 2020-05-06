
ADown = rand(3);
AUp = ADown + rand(3);
coords = ifov.anglesimatrixfov(ADown,AUp,50);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));
hold on;
coords = ifov.imatrixfov(ADown,AUp,50);
coords = coords + 0.1;
coords = [coords; coords(1)];
plot(real(coords),imag(coords));
