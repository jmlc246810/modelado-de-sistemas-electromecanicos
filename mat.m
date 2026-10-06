% Parámetros del motor DC
Ra = 2;       % Resistencia (ohms)[cite: 1]
Kt = 0.01;    % Constante de torque (N.m/A)[cite: 1]
b = 0.0012;   % Fricción viscosa (N.m.s/rad)[cite: 1]
La = 0.023;   % Inductancia (H)[cite: 1]
Ke = 0.01;    % Constante contraelectromotriz (V.s/rad)[cite: 1]
J = 0.001;    % Inercia del rotor (kg.m^2)[cite: 1]

% Matrices del Espacio de Estados [x1 = ia, x2 = theta, x3 = omega]
A = [-Ra/La,  0, -Ke/La;
    0,    0,    1;
    Kt/J,    0,   -b/J];

B = [1/La; 
    0; 
    0];

% Voltaje aplicado
va = 12;

% Tiempo de simulación (0 a 5 segundos)
tspan = [0 5];

% Condiciones iniciales [ia(0)=0, theta(0)=0, omega(0)=0]
x0 = [0; 0; 0];

% Resolver ecuaciones diferenciales mediante ode45
[t, x] = ode45(@(t, x) A*x + B*va, tspan, x0);

% Extraer variables
ia = x(:,1);       % Corriente de armadura
theta = x(:,2);    % Posición angular
omega = x(:,3);    % Velocidad angular

% Graficar resultados
figure('Name', 'Respuesta del Motor DC en MATLAB (ODE45)');

subplot(3,1,1);
plot(t, ia, 'b', 'LineWidth', 1.5);
grid on;
 xlim([0 5]);
 ylim([0 6]);
ylabel('i_a [A]');
title('Respuesta del Motor DC (ODE45)');

subplot(3,1,2);
plot(t, omega, 'b', 'LineWidth', 1.5);
grid on;
xlim([0 5]);
ylim([0 50]);
ylabel('\omega_m [rad/s]');

subplot(3,1,3);
plot(t, theta, 'b', 'LineWidth', 1.5);
grid on;
xlim([0 5]);
ylim([0 250]);
xlabel('Tiempo [s]');
ylabel('\theta_m [rad]');