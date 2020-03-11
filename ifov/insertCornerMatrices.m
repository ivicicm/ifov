function insertCornerMatrices(ADown ,AUp, fov)
d = size(AUp,1);
if d == 1
    fov.insertMatrix(AUp);
    return
end
length = d*(d-1);
values = zeros(length,1);
Elements = zeros(length, 2);
index = 1;
for i = 1:d
    for j = 1:d
       if i ~= j
           Elements(index,:) = [i j];
           index = index + 1;
       end
    end
end

A = AUp;
fov.insertMatrix(A);
i = 1;
justReturned = false;
while i > 0
    if values(i) == 0 
       if justReturned % to the right of i are ones
           justReturned = false;
           values(i) = 1;
           values((i+1):end) = 0;
           A(Elements(i,1),Elements(i,2)) = ADown(Elements(i,1),Elements(i,2));
           for k = (i+1):length
               A(Elements(k,1),Elements(k,2)) = AUp(Elements(k,1),Elements(k,2));
           end
           fov.insertMatrix(A);
           i = i+1;
       else
           if i == length
               values(i) = 1;
               A(Elements(i,1),Elements(i,2)) = ADown(Elements(i,1),Elements(i,2));
               fov.insertMatrix(A);
           else
              i = i+1; 
           end
       end
    else % values(i) == 1
        i = i - 1;
        justReturned = true;
    end
end





