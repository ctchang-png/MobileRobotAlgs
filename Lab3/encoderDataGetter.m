function [E] = encoderDataGetter
    global encoderData;
    global updatedSincePull;
    while ~updatedSincePull
        pause(0.001)
    end
    E = [encoderData(1), encoderData(2), encoderData(3)];
    updatedSincePull = false;
end