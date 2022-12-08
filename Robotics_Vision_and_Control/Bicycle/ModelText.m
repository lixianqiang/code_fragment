function ModelText()
clc;clf;clear;
[inputVel,initStat] = loadParam();
currStat = initStat;
global timeStamp lastTime dt
for timeStamp = timeStamp:dt:lastTime
    if timeStamp>=0 && timeStamp<3
        inputSteer = 0;
    end
    if timeStamp>=3 && timeStamp<4
        inputSteer = 0.5;
    end
    if timeStamp>=4 && timeStamp<5
        inputSteer = 0;
    end
    if timeStamp>=5 && timeStamp<6
        inputSteer = -0.5;
    end
    if timeStamp>=6 && timeStamp<=10
        inputSteer = 0;
    end
    nextStat = BicycleKinematic(inputVel,inputSteer,currStat,dt); 
    
    plot_curr_pose=currStat(1:3);
    plot_curr_stat=currStat(4:5);
    plot_next_pose=nextStat(1:3);
    plot_next_stat=nextStat(4:5);
    PlotCarProfile(plot_next_pose,plot_next_stat,plot_curr_pose,plot_curr_stat,timeStamp);
    
    currStat=nextStat;
end
end

function [inputVel,initStat] = loadParam()
%input 
inputVel=1;
%initial 
initStat = [0;0;0;0;0]; %[x,y,yaw,vel,angVel]
%step size
global timeStamp lastTime dt
timeStamp = 0;
lastTime = 10;
dt=0.01;
end