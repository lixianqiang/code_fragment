function FollowTrajectory()
clc;clf;clear all;
[initStat,keepDist,velCof,angCof,pubFreq] = loadParam();
currPose = initStat(1:3);
currStat = initStat();
hold on
global timeStamp lastTime dt
for timeStamp = roundn(timeStamp:dt:lastTime,-5)
    goalPoint = clock(pubFreq);
    [diffVel,diffSteer] = followTrajectory(velCof,angCof,goalPoint,currPose,keepDist,dt);
    nextStat = BicycleKinematic(diffVel,diffSteer,currStat,dt);
    plot_curr_pose=currStat(1:3);
    plot_next_pose=nextStat(1:3);
    PlotCarProfile(plot_next_pose,[],plot_curr_pose,[],timeStamp);
    plotTraject(goalPoint);
    currPose=nextStat(1:3);
    currStat=nextStat;
end
end

function [initStat,keepDist,velCof,angCof,pubFreq] = loadParam()
%initial
initStat = [16 -1 pi/2 0 0];  %x0,y0,yaw0,vel,angVel
keepDist = 0.1;

%controller gain
velCof = [2 0.01];
angCof = 2;

%traject & clock parameter
global timer trajStr interval
timer = 0;
trajStr = 'circle';
interval = 0.01;   % interval and pubFreq determine the step size of traject
pubFreq =20; % publish frequency

% step size
global timeStamp lastTime dt
timeStamp = 0;
lastTime = 70;
dt = 0.02; %50hz
end

function wayPoint=clock(pubFreq)
global timer timeStamp lastTime dt
global trajStr interval
if dt >= 1/pubFreq
    for timer = timer:1/pubFreq:lastTime
        if timer >= timeStamp
            latch = false;
            wayPoint = TrajectoryGenerator(trajStr,interval,latch);
            break
        else
            latch = true;
            wayPoint = TrajectoryGenerator(trajStr,interval,latch); 
        end
    end
elseif dt <= 1/pubFreq && timeStamp <= lastTime
    if timeStamp >= timer
        latch = false;
        wayPoint = TrajectoryGenerator(trajStr,interval,latch); 
    else
        latch = true;
        wayPoint = TrajectoryGenerator(trajStr,interval,latch); 
        return
    end
end
timer = roundn(timer+1/pubFreq,-5);
end

function wayPoint = TrajectoryGenerator(trajStr,interval,latch)
global cache theta
switch trajStr
    case "circle"        
        if isempty(theta)
            theta=0;
        end
        central = [10,0];
        radius = 5;
        dw = interval/radius;
        theta = theta+dw;
        x = central(1)+radius*cos(theta);    
        y = central(2)+radius*sin(theta);
        if latch==true
            wayPoint=cache;
        else
            cache = [x,y];
            wayPoint = [x,y];
        end
    case "segement"
        % TODO
end
end

function [outputArg1,outputArg2] = plotTraject(currPoint)
global lastPoint
if isempty(lastPoint)
    lastPoint=currPoint;
end
line([currPoint(1) lastPoint(1)],[currPoint(2) lastPoint(2)],'Color','b');
lastPoint=currPoint;
end

function [diffVel,diffSteer] = followTrajectory(velCof,angCof,goalPoint,currPose,keepDist,dt)
global error_i
if isempty(error_i)
    error_i=0;
end
dx = goalPoint(1)-currPose(1);
dy = goalPoint(2)-currPose(2);
distErr = hypot(dy,dx)-keepDist;

error_i = error_i + distErr*dt;
diffVel = velCof(1)*distErr + velCof(2)*error_i; % diffVel = PID(velCof(1),velCof(2),velCof(3),distErr,dt);

goalYaw = atan2(dy,dx);
diffSteer = angCof*angDiff(goalYaw,currPose(3));
end