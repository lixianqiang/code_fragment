function [t0, x0, u0] = shift(T, t0, x0, u,f)
%we will apply control actions in shift function. It propegates the
% control actions in f function and calculates the new state.
status = x0;
control = u(1,:)';
f_value = f(status,control);
status = status + (T*f_value);
x0 = full(status); % new initial state for next time step

t0 = t0 + T;
u0 = [u(2:size(u,1),:);u(size(u,1),:)]; % optimization variable for next time step
% as we have optimal solution from previous time step
end