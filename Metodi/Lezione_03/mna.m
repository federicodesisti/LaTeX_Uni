clear
close all
clc

%params
T = 1; %tempo finale
h = 0.1; %passo 
y0 = 1; % dato iniziale
f = @(t,y) y;% handle function, la dinamica in questione

%working vars
t = 0:h:T; %creo tutti i tempi da 0 a T con passo h
N = length(t); %quanti tempi abbiamo

% y´(t) = y(t)
% y(0) = y0

%vettore per memorirzzare la soluzione
u_FE = zeros(1,N);
u_H = zeros(1,N);
%soluzione analitica campionata sulla griglia
y = y0*exp(t);

% Applichiamo il metodi di eulero per trovare la soluzione

% Forward Euler method
% u_{n+1}=u_n+hf(t_n,u_n)

u_FE(1) = y0;
for n=1:N-1
    u_FE(n+1) = u_FE(n) + h*f(t(n),u_FE(n));
end

%Applico in metodo di Heun
% u_{n+1}=u_n+h/2(f(t_n,u_n) + f(t_{n+1},u_n + h*f(t_n,u_n)))
u_H(1) = y0;
for n=1:N-1
    fn = f(t(n),u_H(n));
    u_H(n+1) = u_H(n) + 0.5*h*(fn+f(t(n+1),u_H(n)+h*fn));
end

%aggancimao il grafico all'handle, diventa una specie di vettore di
%grafici

p_u = plot(t,y, t, u_FE, t, u_H);
% impostiamo gli assi
axis([0 T -0.1 3])
legend('exact solution', 'forward euler', 'heun');

err_FE = abs(y-u_FE);
err_H = abs(y - u_H);

figure
p_r = plot(t, err_FE, t, err_H);
legend('forward euler', 'heun');
