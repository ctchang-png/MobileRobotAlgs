function [rIF] = initRobot(number, sim)
    clearvars
    clear encoderEventListener
    clc
    rIF = robotIF(number, sim);
    rIF.encoders.NewMessageFcn=@encoderEventListener;
end