% Initialization
clearvars
clear encoderEventListener
clear PID_control
clc
clf
num = sum(uint8(char("Fido")));
rIF = robotIF(num, true);
rIF.encoders.NewMessageFcn=@encoderEventListener;
ref = figure8ReferenceControl(3, 1, 1.0);
traj = RobotTrajectory(ref, 1000);
model = Model();
model.vMax = 0.500;
controller = Controller(traj, [0,0,0], model);
poseEstimator = PoseEstimator(model);
logger = Logger(true);
executor = Executor(model);
%cubicSpiralTrajectory.makeLookupTable(100);
pause(1.0) 


%pose_targets = [0.3048,0.3048,0.0;...
%                -0.6096,-0.6096,-pi/2.0;...
%                -0.3048, 0.3048, pi/2.0].';


system = mrplSystem(rIF, model);

system.executeTrajectory(traj);
rIF.stop()
Tf = traj.getTrajectoryDuration();
term_err = traj.getPoseAtTime(Tf) - rIF.rob.sim_motion.pose;
e = norm(term_err(1:2) * 1000);
fprintf("Terminal error: %2.2fmm \n", e)