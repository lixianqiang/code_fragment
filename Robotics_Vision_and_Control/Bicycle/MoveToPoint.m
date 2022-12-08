function MoveToPoint()
clf;clc;clear;
[goalPoint,initStat,kp_vel,kp_steer] = loadParam();
currPose = initStat(1:3);
currStat = initStat;
global timeStamp lastTime dt
for timeStamp=timeStamp:dt:lastTime
    [diffVel,diffSteer] = move2Point(kp_vel,kp_steer,goalPoint,currPose);
    nextStat = BicycleKinematic(diffVel,diffSteer,currStat,dt);
    
    plot_curr_pose=currStat(1:3);
    plot_next_pose=nextStat(1:3);
    PlotCarProfile(plot_curr_pose,currStat(4:5),plot_next_pose,nextStat(4:5),timeStamp);
    currPose=nextStat(1:3);
    currStat=nextStat;
end
end

function [goalPoint,initStat,kp_vel,kp_steer]=loadParam()
%goal point [x,y]
goalPoint = [10 10];
%initial value
initStat = [0,0,0,0,0];  %x0,y0,yaw0,vel,angVel
%controller gain
kp_vel = 0.5;
kp_steer = 4;
%step size
global timeStamp lastTime dt
timeStamp = 0;
lastTime = 50;
dt = 0.02;
end

function [diffVel,diffSteer] = move2Point(kp_vel,kp_steer,goalPoint,currPose)
dx = goalPoint(1)-currPose(1);
dy = goalPoint(2)-currPose(2);
ds=hypot(dx,dy);
goalYaw = atan2(dy,dx);
diffVel = kp_vel*ds;
diffSteer = kp_steer*angDiff(goalYaw,currPose(3));
end
