function [i] = findNearest(ranges)
    i = -1;
    min = intmax;
    for ii = 1:length(ranges)
        if ranges(ii) < min
            min = ranges(ii);
            i = ii;
        end
    end
end