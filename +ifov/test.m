
ADown = rand(4);
AUp = ADown + rand(4);
coords = ifov.anglesimatrixfov(ADown,AUp,50);
coords = [coords; coords(1)];
plot(real(coords),imag(coords),'Color','k');

return;
hold on;
coords = ifov.anglesimatrixfov(ADown,AUp,50);
coords = coords + 0.1;
coords = [coords; coords(1)];
plot(real(coords),imag(coords));