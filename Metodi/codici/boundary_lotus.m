clc;
clear;
close all;




p = 1;

a = zeros(1, p + 1);
b = zeros(1, p + 1);
a(1) = 1;
b(1) = 0;
bm = 1;


%CN
figure
title('one step');
subplot(2,2,3)
a=1;b=0.5;bm=0.5;
bl(a,b,bm);

%BE
subplot(2,2,2)
a=1;b=0;bm=1;
bl(a,b,bm);


figure
title('bashforth');
subplot(2,2,1);
% AB1=FE
a=1;b=1;bm=0;
bl(a,b,bm);

subplot(2,2,2);
% AB2
a=[1 0];b=[3/2 -1/2];bm=0;
bl(a,b,bm);

subplot(2,2,3);
% AB3
a=[1 0 0];b=[23/12 -16/12 5/12];bm=0;
bl(a,b,bm);

subplot(2,2,4);
% AB4
a=[1 0 0 0];b=[55/24 -59/24 37/24 -9/24];bm=0;
bl(a,b,bm);

figure
title('Adam Moulton');
subplot(2,2,1);
% AM1=CN
a=1;b=0.5;bm=0.5;
bl(a,b,bm);

subplot(2,2,2);
% AM2
a=[1 0];b=[8/12 -1/12];bm=5/12;
bl(a,b,bm);

subplot(2,2,3);
% AM3
a=[1 0 0];b=[19/24 -5/24 1/24];bm=9/24;
bl(a,b,bm);

subplot(2,2,4);
% AB4
a=[1 0 0 0];b=[646/720 -264/720 106/720 -19/720];bm=251/720;
bl(a,b,bm);


%%%%%%%%%%%%%%%%%%%%
%BDF
figure
title('BDF');
subplot(2,3,1);
% BDF1 = BE
a=1;b=0;bm=1;
bl(a,b,bm);

subplot(2,3,2);
% BDF2
a=[4/3 -1/3];b=[0 0];bm=2/3;
bl(a,b,bm);

subplot(2,3,3);
% BDF3
a=[18/11 -9/11 2/11];b=[0 0 0];bm=6/11;
bl(a,b,bm);

subplot(2,3,4);
% BDF4
a=[48/25 -36/25 16/25 -3/25];b=[0 0 0 0];bm=12/25;
bl(a,b,bm);

subplot(2,3,5);
% BDF5
a=[200/137 -300/137 200/137 -75/137 12/137];b=[0 0 0 0 0];bm=60/137;
bl(a,b,bm);

subplot(2,3,6);
% BDF6
a=[360/147 -450/147 400/147 -225/147 72/147 -10/147];b=[0 0 0 0 0 0];bm=60/147
bl(a,b,bm);



% Cambiando i coefficienti ora posso vedere la regione di stabilita di
% qualunqe metodo

function bl(a,b, bm)
    if length(a) ~= length(b)
        error("Errore, a e b hanno lunghezza diversa");
        return;
    end
    
    Ntheta = 100;
    theta = linspace(0,2*pi,Ntheta)';

    Nalpha = 70;
    alpha_max=5;
    alpha = linspace(1, alpha_max,Nalpha);

    % l exp e la circonferenza complessa, se lo moltiplico per i raggi ho tutte
    % le circonferenze

    r = exp(1i*theta)*alpha;

    H = plot(r);
    H(1).Color = [1,1,1];
    for i=2:length(H)
        H(i).Color = [1,0,0];
    end
    axis equal;
    axis (1.1*[-alpha_max alpha_max -alpha_max alpha_max]);
    %H e una collezzione di 10 linee, che sono oggetti grafici a se stanti,
    %quindi posso cambiare sinngolarmetne il colore


    %dobbiamo scrivere r^{p+1} - sum_{j=0}^p a_j r^{p-j})/sum_{j=-1}^p b_j r^{p-j}


    p = length(a) - 1;
    rho = a(1) * r.^p;
    sigma = b(1) * r.^p;

    for j=1:p
        rho = rho + a(j+1) * r.^(p-j);
        sigma = sigma + b(j+1) * r.^(p-j);
    end
    rho = r.^(p+1)-rho;
    sigma = sigma + bm*r.^(p+1);

    Z = rho./sigma;

    r = exp(1i*theta)*alpha;

    H = plot(Z);
    H(1).Color = [1,1,1];
    for i=2:length(H)
        H(i).Color = [1,0,0];
    end
    axis equal;
    grid on;
    axis (1.1*[-alpha_max alpha_max -alpha_max alpha_max]);

end