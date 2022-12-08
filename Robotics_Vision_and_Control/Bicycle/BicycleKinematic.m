function nextStat = BicycleKinematic(inputVel,inputSteer,currStat,dt)
if nargin==3
    dt=1; %当dt=1时，把程序迭代的时间间隔作为dt,此时limAcc加速度应相应进行缩放，v=v0+a*dt
end
% currStat=[x;y;yaw;vel;angVel]
[limVel,limAcc,limSteer,limSteerVel,wheelBase] = modelParam();

if abs(inputVel) > limVel  
    inputVel = sign(inputVel)*limVel;
end
currAcc = (inputVel-currStat(4))/dt;
if abs(currAcc) > limAcc
    inputVel = currStat(4) + sign(currAcc)*limAcc*dt;
end

if abs(inputSteer) > limSteer 
    inputSteer = sign(inputSteer)*limSteer;
end
currAngVel = (inputSteer-currStat(5))/dt;
if abs(currAngVel) > limSteerVel
    inputSteer = currStat(5) + sign(currAngVel)*limSteerVel*dt;
end

nextStat(1) = currStat(1) + inputVel*cos(currStat(3))*dt;
nextStat(2) = currStat(2) + inputVel*sin(currStat(3))*dt;
nextStat(3)  = wrapToPi(currStat(3) + inputVel*tan(inputSteer)/wheelBase*dt);
nextStat(4) = inputVel;
nextStat(5) = inputSteer;

end

function [limVel,limAcc,limSteer,limSteerVel,wheelBase] = modelParam()
limVel = 1;  %vel=[-1,1]
limAcc = 1;
limSteer = pi/3;
limSteerVel = inf; %n/180*pi
wheelBase = 1;
end
