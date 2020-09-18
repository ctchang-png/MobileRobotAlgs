%% Initialize.
close all; clc;

%% Drawing stuff in windows. 
% Due to the double % on the line above, this is a code section that is
% recognized as a unit of code in the editor.
% Run this in the debugger/editor by clicking on "Run Section" not "Run".
% Place a breakpoint on the first line and then step through one line at a
% time by clicking "Step". Or set multiple breakpoints and advance several
% lines to the next one with "Continue".

% Specify points as an 3Xn homogeneous array.
% Simulator length units: m.
model_points = [1.5 3.0 1.50  0 1.5; 0 1.5 3.0 1.5 0; 1 1 1 1 1];
% polyLineShape instances represent bodies.
walls = polyLineShape(model_points);

model_points = [1.6 1.6 1.4 1.4 1.6; 1.4 1.6 1.6 1.4 1.4; 1 1 1 1 1];
obstacle = polyLineShape(model_points);

obj_fig = objectFigure("simExample");
obj_fig.addObj(walls);
obj_fig.addObj(obstacle);

obj_fig.show();
pause(2.0);

obstacle.setPoseAndUpdate([0.1 ; 0.2 ; 0.3]);
obj_fig.show(); % see! it moved!

%% Simulator
% Due to the double % on the line above, this is a code section that is
% recognized as a unit of code in the editor.
% Run this in the debugger/editor by clicking on "Run Section" not "Run".
% Place a breakpoint on the first line and then step through one line at a
% time by clicking "Step". Or set multiple breakpoints and advance several
% lines to the next one with "Continue".

% Connect to the Robot

rIF = robotIF(0, true); % Set to false for a real robot. Fig 99 should pop up.

% Move the robot forward and backward
rIF.sendVelocity(.050, .050);
pause(.5);
rIF.sendVelocity(-.050, -.050);
pause(.5);
rIF.stop();

% Look at the encoder data of the left wheel (in meters)
disp("Encoders\n");
disp(rIF.encoders.LatestMessage.Vector.X);
pause(2);

% Create some walls
% Dimensions of the rectangle
wid =  2*worldModel.wallLength;
hgh =  2*worldModel.wallLength;

% Set up points
nw = [-wid/2 ; hgh/2 ; 1];
sw = [-wid/2 ;-hgh/2 ; 1];
se = [ wid/2 ;-hgh/2 ; 1];   
ne = [ wid/2 ; hgh/2 ; 1];

% form the polyLine
model_points = [nw sw se ne nw];
walls = polyLineShape(model_points);
rIF.addObjects(walls);

% Laser
% spin up the laser, wait for it to start spewing data
rIF.startLaser();
pause(3);

% look at the ranges (there are 360 of them)
disp("Ranges\n");
disp(rIF.laser.LatestMessage.Ranges);
pause(3);
% Stop Laser.
rIF.stopLaser();
pause(0.1);

% Kill simulator.
% Simulator runs MATLAB timer objects. Calling neato.shutdown() kills
% simulator cleanly.
rIF.shutdown();
pause(1);
% If you deleted the robot without rIF.shutdown(), you may have to run
% delete(timerfindall) to get rid of timers.

% Clean workspace.
close all; clear all; %clc;    

% You can close figure 99 (click on x) to stop the simulator, if needed.