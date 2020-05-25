
ADown = rand(100)*50;
AUp = ADown + rand(100)*20;
coords = ifov.aproximatrixfov(ADown,AUp,50);
coords = [coords; coords(1)];
plot(real(coords),imag(coords),'Color','k');

return;
hold on;
coords = ifov.anglesimatrixfov(ADown,AUp,50);
coords = [coords; coords(1)];
plot(real(coords),imag(coords));