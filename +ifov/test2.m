ADown = [1 0 3; 0 0 0; 0 0 0];
count = 20;
hold on;
B = zeros(3);
B(1,2) = 5;
C = zeros(3);
C(2,3) = -5;
for i = 0:count
    for j= 0:count
        A = ADown + (i/count)*(B) + (j/count)*C;
        coords = ifov.matrixfov(A,20);
        coords = [coords; coords(1)];
        plot(real(coords),imag(coords));
    end
end
for i = [0 count]
    for j= [0 count]
        A = ADown + (i/count)*(B) + (j/count)*C;
        coords = ifov.matrixfov(A,20);
        coords = [coords; coords(1)];
        plot(real(coords),imag(coords), 'LineWidth', 5);
    end
end