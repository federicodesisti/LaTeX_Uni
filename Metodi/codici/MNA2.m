clc
clear
close all

% simulation parameters
T = 1; % final time
y0 = 1; % initial datum
f = @(t,y) y; % dynamics

Num_ref = 20; % Numero di raffinamenti successivi
Err = zeros(2,Num_ref);
H = zeros(1,Num_ref);
h0 = 0.1;

for r = 1:Num_ref

    h = h0*2^(-r); % time step

    % working variables
    t = 0:h:T; % time grid
    N = length(t); % number of grid nodes
    u = zeros(2,N); 
    y = y0*exp(t); % Exact solution

    u(:,1) = y0; % initial datum

    for n = 1:N-1
        % FE
        u(1,n+1) = u(1,n) + h*f(t(n),u(1,n));
        % HEUN
        fn = f(t(n),u(2,n));
        u(2,n+1) = u(2,n)+0.5*h*(fn+f(t(n+1),u(2,n)+h*fn));
    end

    H(r) = h;
    Err(1,r) = norm(u(1,:)-y,'inf');
    Err(2,r) = norm(u(2,:)-y,'inf');
    %Err = sqrt(norm(u_FE-y,'2')*h);
end

figure(1)
plot(H, Err(1,:), 'ro-', H, Err(2,:), 'bo-');
xlabel('h');
ylabel('E_h');
legend('FE', 'Heun');

Nq = Num_ref-1;
q(1, 1:Nq) = log2(Err(1,1:Nq)./Err(1,2:Nq+1));
q(2, 1:Nq) = log2(Err(2,1:Nq)./Err(2,2:Nq+1));

figure(2)
plot(1:Nq, q(1, 1:Nq), 'r-o', 1:Nq, q(2, 1:Nq), 'b-o', ...
    [1 Nq], [1 1], 'g--', [1 Nq], [2 2], 'g--');
legend('FE', 'Heun', 'Asintoto 1', 'Asintoto 2');
xlabel('h');
ylabel('q');
xlim([1 Nq]);
ylim([0.965 2.2]);