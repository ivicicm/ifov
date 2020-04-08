% shows that result from both algorithms are similar

AUp = rand(3);
ADown = AUp - rand(3);

f1 = FOV(100);
g = AngleMatrixGenerator(ADown,AUp);
g.generateAndInsert(f1);
coords1 = f1.Coordinates;
coords1 = [coords1; coords1(1)];
plot(real(coords1),imag(coords1));

hold on;
f2 = FOV(100);
insertCornerMatrices(ADown,AUp,f2);
coords2 = f2.Coordinates;
coords2 = [coords2; coords2(1)];
plot(real(coords2),imag(coords2),'--w');
hold off;