function FollowLine()
clc;clf;clear;
[lineParam,initStat,distCof,angCof] = loadParam();
currPose = initStat(1:3);
currStat = initStat;
global timeStamp lastTime dt
for timeStamp = timeStamp:dt:lastTime
    [diffVel,diffSteer] = followAline(distCof,angCof,lineParam,currPose);
    nextStat = BicycleKinematic(diffVel,diffSteer,currStat,dt);
 
    plot_curr_pose=currStat(1:3);
    plot_next_pose=nextStat(1:3);
    PlotCarProfile(plot_next_pose,[],plot_curr_pose,[],timeStamp);
    
    currPose=nextStat(1:3);
    currStat=nextStat;
end
end

function [lineParam,initStat,distCof,angCof]=loadParam()
%line vertex p1 point to p2
p1 = [1 0];
p2 = [2 10];
lineParam = lineFunc(p1,p2);
line([p1(1),p2(1)],[p1(2),p2(2)]);
%initial
initStat = [1 -2 pi/2 0 0];     %x0,y0,yaw0 vel,angVel
%controller gain
distCof = 0.5;
angCof = 1;
%step size
global timeStamp lastTime dt
timeStamp = 0;
lastTime = 20;
dt = 0.02;
end

function [diffVel,diffSteer] = followAline(distCof,angCof,lineParam,currPose)
point2line_dist = sum(lineParam.*[currPose(1:2) 1]) / hypot(lineParam(1),lineParam(2));
goalYaw=atan2(-lineParam(1),lineParam(2));
diffVel = 1;
diffSteer = -distCof*point2line_dist + angCof*angDiff(goalYaw,currPose(3));
end

function lineParam = lineFunc(startPoint,goalPoint)
%line parameter lineParam = [A,B,C]
p1 = [startPoint 1];
p2 = [goalPoint 1];
l = cross(p1,p2);
l = l/hypot(l(1),l(2));
lineParam = [l(1) l(2) l(3)];
end