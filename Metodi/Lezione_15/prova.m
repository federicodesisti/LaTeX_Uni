clear
clc

E = @(y1, y2) 0.5 * y2^2  + 1 - cos(y1);

%params
T = 1; %tempo finale
h = 0.1; %passo 
y10 = 1; % dato iniziale
y20 = 1;

%working vars
t = 0:h:T; %creo tutti i tempi da 0 a T con passo h
N = length(t); %quanti tempi abbiamo

%vettore per memorirzzare la soluzione
u_FE = zeros(2,N);

u_FE(1:2,1) = [y10,y20];

for n=1:N-1
    u_FE(1:2,n+1) = u_FE(1:2,n) + h*f(t(n),u_FE(n));
end

plot(u_FE,t);

function [y1,y2] = f(y1,y2)
oldy2 = y2;
y2 = -sin(y1);
y1 = oldy2;
end