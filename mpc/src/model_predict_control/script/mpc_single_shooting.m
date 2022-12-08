%% Trajcetory tracking using MPC point stabilization with Single shooting
clear all
close all
clc
% x_dot = [v*cos(theta);v*sin(theta);2*v*tan(phi)/l]; % system r.h.s 2*v*tan(phi)/l
%% Import CasADi
% We need to add path of CasADi v3.5.5 as an optimizer for MPC
addpath('/home/lxq/Documents/casadi-linux-matlabR2014b-v3.5.5/')
import casadi.*

T = 0.20; % sampling time [s]
N = 10; % prediction horizon
l = 1.2;
rob_diam = 0.3; % simulated robot visualization

v_max = 0.5; v_min = -v_max;
phi_max = pi / 4; phi_min = -phi_max;

x = SX.sym('x'); y = SX.sym('y'); theta = SX.sym('theta');
states = [x; y; theta]; n_states = length(states);

v = SX.sym('v'); phi = SX.sym('phi');
controls = [v; phi]; n_controls = length(controls);
rhs = [v * cos(theta); v * sin(theta); 2 * v * tan(phi) / l]; % system r.h.s

f = Function('f', {states, controls}, {rhs}); % nonlinear mapping function f(x,u)
% we pass states and controls as the function inputs and it returns rhs matrix
% using casADAi
U = SX.sym('U', n_controls, N); % Decision/control variables
P = SX.sym('P', n_states + n_states); % parameters vector P = [p_0, p_1, p_2, p_3, p_4, p_5]
% parameters (which include the initial and the reference state of the robot)

X = SX.sym('X', n_states, (N + 1)); % prediction of states
% A Matrix that represents the states over the prediction steps. So X
% represents the prediction of states contains 3 rows and N+1 columns

% compute solution symbolically
X(:, 1) = P(1:3); % initial state of X (prediction states) is the first three
%entries of state matrix P (initila state)
for k = 1:N
    st = X(:, k); con = U(:, k);
    f_value = f(st, con);
    st_next = st + (T * f_value); % it gives us next state
    X(:, k + 1) = st_next;
end

% this function to get the optimal trajectory knowing the optimal solution
ff = Function('ff', {U, P}, {X}); % it calculates the state predictions when we
% pass optimization variable U and Parameter matrix P

%% calculate objective function

obj = 0; % Objective function
g = []; % constraints vector

%Q = zeros(3,3); Q(1,1) = 1; Q(2,2) = 5; Q(3,3) = 0.1; % weighing matrices (states)
%R = zeros(2,2); R(1,1) = 0.5; R(2,2) = 0.05; % weighing matrices (controls)
Q = zeros(3, 3); Q(1, 1) = 1; Q(2, 2) = 5; Q(3, 3) = 0.2; % weighing matrices (states)
R = zeros(2, 2); R(1, 1) = 0.01; R(2, 2) = 0.09; % weighing matrices (controls)
% compute objective
for k = 1:N
    st = X(:, k); con = U(:, k);
    obj = obj + (st - P(4:6))' * Q * (st - P(4:6)) + con' * R * con; % calculate obj
end

% compute constraints
for k = 1:N + 1 % box constraints due to the map margins
    g = [g; X(1, k)] % state x, first entry of each column
    g = [g; X(2, k)] % state y, second entry of each column
    g = [g; X(3, k)] % state theta, third entry of each column
end

% make the decision variables one column vector
OPT_variables = reshape(U, 2 * N, 1); % reshape matrix U which contains 2 rows and N
% columns into a single row...ie...it will return a single row vector
nlp_prob = struct('f', obj, 'x', OPT_variables, 'g', g, 'p', P);

opts = struct;
opts.ipopt.max_iter = 50;
opts.ipopt.print_level = 0; % 0,3
opts.print_time = 0;
opts.ipopt.acceptable_tol = 1e-8;
opts.ipopt.acceptable_obj_change_tol = 1e-6;

solver = nlpsol('solver', 'ipopt', nlp_prob, opts);

args = struct;
% inequality constraints (state constraints)
args.lbg = -5.0; % lower bound of the states x and y
args.ubg = 5.0; % upper bound of the states x and y
% input constraints
args.lbx(1:2:2 * N - 1, 1) = v_min; args.lbx(2:2:2 * N, 1) = phi_min;
args.ubx(1:2:2 * N - 1, 1) = v_max; args.ubx(2:2:2 * N, 1) = phi_max;

%----------------------------------------------
% ALL OF THE ABOVE IS JUST A PROBLEM SETTING UP FOR MPC

% THE SIMULATION LOOP WILL START FROM HERE
%-------------------------------------------
t0 = 0;
x0 = [0; 0; 0]; % initial condition.
xs = [3.5; 3.5; 0]; % Reference posture.

xx(:, 1) = x0; % xx contains the history of states
t(1) = t0;

u0 = zeros(N, 2); % initilaizing optimization variable N prediction horizon*two control inputs

sim_tim = 15; % Maximum simulation time

% Start MPC counter
mpciter = 0;
xx1 = []; % store predicted state
u_cl = []; % store predicted control actions

% the main simulaton loop... it works as long as the error is greater
% than 10^-2 and the number of mpc steps is less than its maximum
% value.
main_loop = tic;

while (norm((x0 - xs), 2) > 1e-2 && mpciter < sim_tim / T)
    args.p = [x0; xs]; % set the initial values of the parameters vector
    args.x0 = reshape(u0', 2 * N, 1); % initial value of the optimization variables (convert to vector)
    %tic
    sol = solver('x0', args.x0, 'lbx', args.lbx, 'ubx', args.ubx, ...
    'lbg', args.lbg, 'ubg', args.ubg, 'p', args.p);
    %toc
    u = reshape(full(sol.x)', 2, N)'; % x contains the optimal values of control actions, reshaping it to get matrix
    ff_value = ff(u', args.p); % gives us prediction...compute OPTIMAL solution TRAJECTORY
    xx1(:, 1:3, mpciter + 1) = full(ff_value)'; % storing the predictions in 3D matrix

    u_cl = [u_cl; u(1, :)];
    t(mpciter + 1) = t0;

    [t0, x0, u0] = shift(T, t0, x0, u, f); % get the initialization of the next optimization step

    xx(:, mpciter + 2) = x0;
    mpciter;
    mpciter = mpciter + 1; %update counter
end

%main_loop_time = toc(main_loop);
%ss_error = norm((x0-xs),2)
%average_mpc_time = main_loop_time/(mpciter+1)

Draw_MPC_point_stabilization_v1 (t, xx, xx1, u_cl, xs, N, rob_diam) % a drawing function
