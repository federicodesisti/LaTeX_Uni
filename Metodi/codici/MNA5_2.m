clear;
clc;
close all;

% Caloclo livelli di energia

E = @(U) 0.5 * (U(2,:)).^2 + 1 - cos(U(1,:));

phi_range = linspace(-10, 10, 1000);
theta_range = linspace(-10, 10, 1000);

[Phi, Theta] = meshgrid(phi_range,theta_range);

E_grid = 0.5*Phi.^2 + 1 - cos(Theta);


%first 2 are axes third one is actual value, \R\times\R -> \R, 25 layers,
%green color
contour(Theta, Phi, E_grid, 25, 'w');
hold on;


%dinamica
F = @(y) [y(2), - sin(y(1))]';

% Options


J = @(y) [0, 1; -cos(y(1)), 0];
tol = 1e-5;
nmax = 100;

% con y1 angolo
% con y2 velocita angolare
phi0 = 1.75;
theta0 = 1;

U0 = [phi0,theta0]';

%timestep
h = 0.05;
%total time
T = 10;
%times
t = [0:h:T];

N = length(t);

U_fe = zeros(2, N);
U_he = zeros(2, N);
U_rk4 = zeros(2, N);
U_be = zeros(2, N);
U_cn = zeros(2, N);

U_fe(:,1) = U0;
U_he(:,1) = U0;
U_rk4(:,1) = U0;
U_be(:,1) = U0;
U_cn(:,1) = U0;


for n = 1:N-1
    % Forward Euler
    U_fe(:, n+1) = U_fe(:, n) + h * F(U_fe(:,n));

    % Heun
    Fhe = F(U_he(:,n));
    U_he(:,n+1) = U_he(:, n) + h/2 *(Fhe + F(U_he(:,n) + h*Fhe));

    % RK4
    K1 = F(U_rk4(:,n));
    K2 = F(U_rk4(:,n) + h*K1/2);
    K3 = F(U_rk4(:,n) + h*K2/2);
    K4 = F(U_rk4(:,n) + h*K3);
    U_rk4(:,n+1) = U_rk4(:,n) + h*(K1/6 +K2/3 + K3/3 + K4/6);

    % Backward Euler
    f_be = @(x) x - h*F(x) - U_be(:,n);
    Jf_be = @(x) eye(2) - h*J(x);
    [X, ~, ~, ~] = Newton(f_be, Jf_be, U_be(:,n), tol, nmax, 1);
    U_be(:,n+1) = X;

    % Crank Nicholson
    f_cn = @(x) x - U_cn(:,n) - (h/2)*(F(x) + F(U_cn(:,n)));
    Jf_cn = @(x) eye(2) - (h/2)*J(x);
    [X, ~, ~, ~] = Newton(f_cn, Jf_cn, U_cn(:,n), tol, nmax, 1);
    U_cn(:,n+1) = X;
end

plot(U_fe(1,:), U_fe(2,:), 'LineWidth', 1.5)
plot(U_he(1,:), U_he(2,:), '--', 'LineWidth', 2) % Heun evidenziato perché è sovrapposto a CN
plot(U_rk4(1,:), U_rk4(2,:), 'LineWidth', 1.5)
plot(U_be(1,:), U_be(2,:), ':', 'LineWidth', 1.5)
plot(U_cn(1,:), U_cn(2,:), '-.', 'LineWidth', 1.5)
legend ('Energia', 'FE', 'HE', 'RK4', 'BE', 'CN')


%% Plot Energie

E_ex = E(U0);
E_fe = E(U_fe);
E_he = E(U_he);
E_rk4 = E(U_rk4);
E_be = E(U_be);
E_cn = E(U_cn);

figure(2)
plot([0 T], [E_ex E_ex], ...
     t, E_fe, ...
     t, E_he, ...
     t, E_rk4, ...
     t, E_be, ...
     t, E_cn);
grid on
legend ('E esatta', 'FE', 'HE', 'RK4', 'BE', 'CN')


function [x, r, iter, errvec] = Newton(Ffun, Jfun, x0, tol, nmax, p)
iter = 0;
err = tol + 1;
x = x0(:);
errvec = [];
step = 0;

while err > tol && iter < nmax

    if step == 0
        Jx = Jfun(x);
    end

    Fx = Ffun(x);

    % Risoluzione diretta del sistema Jx * deltax = -Fx
    deltax = -Jx \ Fx;

    x_old = x;
    x = x + deltax;

    err = norm(x - x_old);
    errvec = [errvec, err];
    iter = iter + 1;

    step = step + 1;
    if step == p
        step = 0;
    end

end

r = norm(Ffun(x));
end