function MoveToPose()
clc;clf;clear all;
[goalPose,initStat,kp_vel,kp_alpha,kp_beta] = loadParam();
currStat = initStat;
global timeStamp lastTime dt
for timeStamp=timeStamp:dt:lastTime
    [diffVel,diffSteer] = move2Pose(kp_vel,kp_alpha,kp_beta,goalPose,currStat);
    nextStat = BicycleKinematic(diffVel,diffSteer,currStat,dt);
    
    plot_curr_pose=currStat(1:3);
    plot_next_pose=nextStat(1:3);
    PlotCarProfile(plot_next_pose,[],plot_curr_pose,[],timeStamp);
    
    currStat=nextStat;
end
end

function [goalPose,initStat,kp_vel,kp_alpha,kp_beta] = loadParam()
%initial
goalPose = [0 0 0];
initStat = [5 5 0 0 0]; %x0,y0,yaw0,vel,ang
%controller gain
kp_vel = 1;
kp_alpha = 5;
kp_beta = -2;  
%step size
global timeStamp lastTime dt
timeStamp = 0;
lastTime = 20;
dt = 0.02;
end

function [diffVel,diffSteer] = move2Pose(kp_vel,kp_alpha,kp_beta,goalPose,currStat)
%wheelBase必须与BicycleKinematic.m中的wheelBase一致
wheelBase=2;
dx = goalPose(1)-currStat(1);
dy = goalPose(2)-currStat(2);
[p,alpha,beta,direct] = toPolar(dx,dy,currStat(3),goalPose(3));
omega =  direct * (kp_alpha*alpha + kp_beta*beta);
diffSteer = atan2(omega*wheelBase,abs(currStat(4))); %diffSteer = atan(omega*wheelBase / abs(currStat(4)+0.0000001)); %加0.000000001防止分子为0而是的atan(0/0)=NaN
diffVel = direct*kp_vel*p;
end

function [p,alpha,beta,direct] = toPolar(x,y,theta,goal_theta)
global orient;
if isempty(orient)
    alpha = angDiff(atan2(y,x),theta);
    if abs(alpha)<pi/2
        orient = "head";
        direct = 1;
    elseif abs(alpha)>=pi/2
        orient = "tail";
        direct = -1;
    end
end
p = sqrt(x^2+y^2);
if orient=="head"
    alpha = angDiff(atan2(y,x),theta);           %alpha = atan2(y,x) - theta = angDiff(atan2(y,x),theta)
    
    beta = angDiff(goal_theta,atan2(y,x));       %beta = -atan2(y,x) + goal_theta
                                                 %     = goal_theta - atan2(y,x) = angDiff(goal_theta,atan2(y,x))
    direct = 1;
elseif orient=="tail"   
    alpha = angDiff(atan2(y,x)-pi,theta);        %alpha = atan2(y,x) - (theta+pi) = angDiff(atan2(y,x),(theta+pi))
                                                 %      = (atan2(y,x)-pi) - theta = angDiff(atan2(y,x)-pi,theta)
                                                 %      = atan2(-y,-x) - theta = angDiff(atan2(-y,-x),theta)
                                      
    beta  = angDiff(goal_theta+pi,atan2(y,x));   %beta = (goal_theta+pi) - atan2(y,x) = angDiff(goal_theta+pi,atan2(y,x))
                                                 %     = -(atan2(y,x)-pi) + goal_theta = -atan2(-y,-x) + goal_theta 
                                                 %                                     = goal_theta - atan2(-y,-x) = angDiff(goal_theta,atan2(-y,-x))
    direct = -1;
end

if alpha > pi/2
    alpha = pi/2;
end
if alpha < -pi/2
    alpha = -pi/2;
end
end
