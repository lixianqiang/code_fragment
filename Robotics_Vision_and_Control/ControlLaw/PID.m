%**********************************************************************%
% reference link: http://blog.sina.com.cn/s/blog_93d3f1fa0101bwbz.html
% reference link: https://zhuanlan.zhihu.com/p/49572763
% reference link: https://zh.wikipedia.org/wiki/PID%E6%8E%A7%E5%88%B6%E5%99%A8#PID%E6%8E%A7%E5%88%B6%E7%9A%84%E9%99%90%E5%88%B6
%**********************************************************************%

%*****************************************************************%
% Based on location of discrete PID Controller
% u=kp*e(k) + ki*integral(e(k)*dt) + kd*de(k)/dt
% Using the Integral separation method offset Integral saturation
%*****************************************************************%
function u = PID(kp,ki,kd,error,dt)
global error_1 error_i;

if isempty(error_1) || isempty(error_i)
    error_1 = 0;
    error_i = 0;
end

[integralSet,differentialSet,~]=setParam();

%There are two way of Integral separation method
%Uncomment line 28 or line 30 but be aware of can't exist at the same time
if integralSet < abs(error)
    alpha = 0;
else
    alpha = 1;
%     error_i = error_i + error*dt;
end
error_i = error_i + error*dt;

du = (error-error_1)/dt;
if abs(du) < differentialSet
    kd = 0;
end

u = kp*error + alpha*ki*error_i + kd*(error-error_1)/dt;
error_1 = error;

end

% % TODO
% %****************************************************************************************************************%
% % Based on increment of discrete PID Controller
% % This method could offset Integral saturation even if without integral separation
% % u = u_1 + du = u_1 + differential( kp*e(k) + ki*integral(e(k)*dt) + kd*de(k)/dt )
% % Default value of dt is 1 for using increment method owing to output will be smaller when dt is 0.01 as one step
% %*****************************************************************************************************************%
% function u = pidCtrller(kp,ki,kd,error,dt)
% 
% persistent error_1 error_2 u_1;
% 
% if isempty(error_1)||isempty(error_1)||isempty(u_1)
%   error_1 = 0;
%   error_2 = 0;
%   u_1 = 0;
% end
% 
% [integralSet,differentialSet,dt]=setParam();
% 
% % Uncomment these code if use Integral separation method
% % but don't recommend uncomment because this increment method have same effect with increment method
% 
% % if integralSet < abs(error)
% %     ki = 0;
% % end
% % 
% % du = (error-error_1)/dt;
% % if abs(du) < differentialSet 
% %     kd = 0;
% % end
% 
% du=kp*(error-error_1) + ki*error*dt + kd*(error-2*error_1+error_2)/dt;
% u=u_1+du;
% 
% % if u>=10
% %     u=10;
% % end
% % 
% % if u<=-10
% %     u=-10;
% % end
% 
% error_2 = error_1;
% 
% error_1 = error;
% 
%   u_1 = u;
% 
% end

%%
function [integralSet,differentialSet,dt]=setParam()
integralSet = 15;
differentialSet = 10;
dt = 1;
end
