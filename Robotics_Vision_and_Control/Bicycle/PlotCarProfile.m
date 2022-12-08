function plotCarProfile(curr_point,curr_stat,next_point,next_stat,time_stamp)
hold on
%plot the car model each 0.2 second
% if mod(time_stamp,0.2) == 0
%     carProfile(curr_point(1),curr_point(2),curr_point(3),curr_stat(2),0.001);    
% end
line([curr_point(1) next_point(1)],[curr_point(2) next_point(2)],'Color','r');
end

function carProfile(x,y,theta,gamma,scale)
%%                                                            
%                                                               % gamma是转向角与轮轴坐标系y轴的夹角 
%               car_body(1)                                     % 左正右负
%               ^       gamma                                 gamma y
%               |      \     ^                                    \ ^ 
%               |       \    |                                     \|
%               o————————\———|—————y——————o — —> car_body(2) ^ — — —o— — —>x
%               |   _ _   \  |  _ _^      |                  |      |C
%               |   \   \  \ |  \  |\     |                  |      |
%               |    \ . \  \|  —\—o—\—>x |                  |                                                              
%               |     \_ _\       \|C_\   |  ^               |   % frame C 是指每一个前轮作为坐标原点
%               |                  |      |  |               |
%               | tire_width y            |  |               |
%               |    |<—>|   ^            |  | wheel_base    | car_base
%               |     _ _    |    _ _ _ _ |_ |_ _ _ _ _ _ _ _|_ _ _ _ _ _
%               |    |   |   |   |   |    |  |               |           ^
%        ^— — — |— — |—.—|— —o— —|—.—|>x  |  v               |           | wheel_diameter
%        |      |    |_ _|  B|\  |_ _|_ _ |_ _ _ _ _ _ _ _ _ |_ _ _ _ _ _v
%  delta |      |            | \          |                  |
%        v— — — o———————————————\—————————o — —> car_body(3) v 
%               |        <— — — —\—>      | 
%               |        wheel_width      |
%               |<— — — — — — — — —\ — — >|
%               |         car_width \      
%               v                    \   Y               % theta是车体坐标系的y轴与惯性坐标系X轴的夹角   
%               car_body(4)           \  ^                          Y  y
%                                      \ |                          ^ /
%                                       \|                          |/ theta
%                                  — — — o— — —>X              — — —o— — —>X 
%                                        |A                         |A             
%                                        |                          |
%                                                                                  

hold on
%车体参数
para_wheel_base = 2;
para_wheel_width = 1.2;
para_wheel_diameter = 1.2;
para_car_base = 4;
para_car_width = 1.8;
para_tire_width = 0.5;
para_delta = para_car_base/2 - para_wheel_base/2;

%模型按比例缩放
para_val = [para_wheel_base;para_wheel_width;para_wheel_diameter;para_car_base;para_car_width;para_tire_width;para_delta];
norm = scale * sqrt(para_val'*para_val);
wheel_base = para_wheel_base * norm;
wheel_width = para_wheel_width * norm;
wheel_diameter = para_wheel_diameter * norm;
car_base = para_car_base * norm;
car_width = para_car_width * norm;
tire_width = para_tire_width * norm;
delta = para_delta * norm;

%车体坐标系下各点位置关系
car_body = [[-car_width/2;car_base-delta] [car_width/2;car_base-delta] [car_width/2;-delta] [-car_width/2;-delta]];
wheel_body = [[-tire_width/2;wheel_diameter/2] [tire_width/2;wheel_diameter/2] [tire_width/2;-wheel_diameter/2] [-tire_width/2;-wheel_diameter/2]];
front_wheel_cen = [[-wheel_width/2;wheel_base] [wheel_width/2;wheel_base]];
rear_wheel_cen = [[-wheel_width/2;0] [wheel_width/2;0]];

%坐标转换
T_framB2framA = [sin(theta) cos(theta) x; -cos(theta) sin(theta) y];
R_framC2framB = [cos(gamma) -sin(gamma);sin(gamma) cos(gamma)];
R_rear2car = [1 0;0 1];

%车身框架
plot_car_body = T_framB2framA * [car_body;ones(1,4)];
drawRect(plot_car_body);

%画前轮中心点
plot_front_wheel_cen = T_framB2framA * [front_wheel_cen;ones(1,2)];
plot(plot_front_wheel_cen(1,:),plot_front_wheel_cen(2,:),'o');

%左前轮
front_wheel_left = [R_framC2framB front_wheel_cen(:,1)] * [wheel_body;ones(1,4)];
plot_front_wheel_left = T_framB2framA * [front_wheel_left;ones(1,4)];
drawRect(plot_front_wheel_left);

%右前轮
front_wheel_right = [R_framC2framB front_wheel_cen(:,2)] * [wheel_body;ones(1,4)];
plot_front_wheel_right = T_framB2framA * [front_wheel_right;ones(1,4)];
drawRect(plot_front_wheel_right);

%后轮中心点
plot_rear_wheel_cen = T_framB2framA * [rear_wheel_cen;ones(1,2)];
plot(plot_rear_wheel_cen(1,:),plot_rear_wheel_cen(2,:),'o');

%左后轮
rear_wheel_left = [R_rear2car rear_wheel_cen(:,1)] * [wheel_body;ones(1,4)];
plot_rear_wheel_left = T_framB2framA * [rear_wheel_left;ones(1,4)];
drawRect(plot_rear_wheel_left);

%右后轮
rear_wheel_right = [R_rear2car rear_wheel_cen(:,2)] * [wheel_body;ones(1,4)];
rear_wheel_right_plot = T_framB2framA * [rear_wheel_right;ones(1,4)];
drawRect(rear_wheel_right_plot);

end

function drawRect(point)
plot([point(1,1) point(1,2)],[point(2,1) point(2,2)]);
plot([point(1,2) point(1,3)],[point(2,2) point(2,3)]);
plot([point(1,3) point(1,4)],[point(2,3) point(2,4)]);
plot([point(1,4) point(1,1)],[point(2,4) point(2,1)]);
end