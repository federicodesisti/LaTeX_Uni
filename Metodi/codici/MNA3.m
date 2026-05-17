    % Oscillatore armonico
    clc; clear; close all;
    
    % simulation parameters
    T = 1; % final time
    w = 2 * pi;
    x0 = 1;
    v0 = 1;
    X0 = [x0; v0];
    A =  [0, 1;
          -w^2, 0];
    
    Num_ref = 5; % Numero di raffinamenti successivi
    Err = zeros(4,Num_ref);
    H = zeros(1,Num_ref);
    h0 = 0.1;
    theta = 0.3;
    I = eye(2);
    
    %% main
    
    for r = 1:Num_ref
    
        % working variables
        h = h0*2^(-r); % time step
        t = 0:h:T; % time grid
        N = length(t); % number of grid nodes
    
    
        % Soluzione
        X_ex = [x0*cos(w*t) + v0*sin(w*t)/w;
                v0*cos(w*t) - w*x0*sin(w*t)];
        % Pre allocazione
        X_fe = zeros(2,N);
        X_be = zeros(2,N);
        X_cn = zeros(2,N);
        X_tm = zeros(2,N);
    
        % Initial datum
        X_fe(:,1) = X0;
        X_be(:,1) = X0;
        X_cn(:,1) = X0;
        X_tm(:,1) = X0;
    
        for n = 1:N-1
            % Forward Euler
            X_fe(:,n+1) = X_fe(:,n) + h*A*X_fe(:,n); 
            % Backward Euler
            X_be(:,n+1) = (I-h*A) \ X_be(:,n);
            % Crank Nicholson
            X_cn(:,n+1) = (I-0.5*h*A) \ ((I+0.5*h*A)*X_cn(:,n));
            % Theta Metodo
            X_tm(:,n+1) = (I-theta*h*A) \ ((I+(1-theta)*h*A)*X_tm(:,n));
        end
    
        % Errore
    
        H(r) = h;
        Err(1,r) = norm(X_fe-X_ex);
        Err(2,r) = norm(X_be-X_ex);
        Err(3,r) = norm(X_cn-X_ex);
        Err(4,r) = norm(X_tm-X_ex);
    
        % Energia
        E_ex = 0.5*(X_ex(2,:)).^2 + 0.5*w^2*(X_ex(1,:)).^2;
        E_fe = 0.5*(X_fe(2,:)).^2 + 0.5*w^2*(X_fe(1,:)).^2;
        E_be = 0.5*(X_be(2,:)).^2 + 0.5*w^2*(X_be(1,:)).^2;
        E_cn = 0.5*(X_cn(2,:)).^2 + 0.5*w^2*(X_cn(1,:)).^2;
        E_tm = 0.5*(X_tm(2,:)).^2 + 0.5*w^2*(X_tm(1,:)).^2;
    end
    
    %% plot
    
    % Plot piano delle fasi
    figure(1)
    plot (X_ex(1, :), X_ex(2,:));
    hold on
    plot (X_fe(1, :), X_fe(2,:));
    hold on
    plot (X_be(1, :), X_be(2,:));
    hold on
    plot (X_cn(1, :), X_cn(2,:));
    hold on
    plot (X_tm(1, :), X_tm(2,:));
    grid on
    
    legend ('Exact', 'FE', 'BE', 'CN', 'TM')
    
    % Plot errore
    figure(2)
    plot(H, Err(1,:))
    hold on
    plot(H, Err(2,:))
    hold on
    plot(H, Err(3,:))
    hold on
    plot(H, Err(4,:))
    grid on;
    xlabel('h');
    ylabel('E_h');
    legend('FE', 'BE', 'CN', 'TM');
    
    % Plot energia
    figure(3)
    plot(t, E_ex);
    hold on;
    plot(t, E_fe);
    hold on;
    plot(t, E_be);
    hold on;
    plot(t, E_cn);
    hold on;
    plot(t, E_tm);
    grid on;
    legend ('Exact', 'FE', 'BE', 'CN', 'TM')
    xlabel('Tempo');
    ylabel('Energia(t)');