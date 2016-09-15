function col = iscolumn(a)
%Checks whether input array is a column vector

col = false;

if size(a,2) == 1 && ndims(a) == 2
    col = true;
end

end