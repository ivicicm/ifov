% Shows that fov of interval matrix isn't convex. Interval matrix A has
% only 2 interval elements. Matrices that belong to A form a 2D space. We can 
% approximate it's fov by generating matrices that belong to A and plotting
% them. The conterixample isn't rigorous though.

ADown = [0 0; 0 0];
% AUp = [0 1; 1 0];
count = 20;
hold on;
B = zeros(2);
B(1,2) = 1;
C = zeros(2);
C(2,1) = 1;
for i = 0:count
    for j= 0:count
        A = ADown + (i/count)*(B) + (j/count)*C;
        coords = ifov.matrixfov(A,20);
        coords = [coords; coords(1)];
        plot(real(coords),imag(coords));
    end
end

coords = ifov.imatrixfov(ADown,ADown + B + C, 20);
coords = [coords; coords(1)];
plot(real(coords),imag(coords), 'LineWidth', 3);