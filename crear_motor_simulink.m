Ra = 2;
Kt = 0.01;
b = 0.0012;
La = 0.023;
Ke = 0.01;
J = 0.001;
va = 12;
Tload = 0;

model = 'MotorDC_Simulink';
if bdIsLoaded(model)
    close_system(model, 0);
end
new_system(model);
open_system(model);

add_block('simulink/Sources/Constant', [model '/Voltaje va'], ...
    'Value', 'va', 'Position', [35 65 85 95]);
add_block('simulink/Sources/Constant', [model '/Torque carga'], ...
    'Value', 'Tload', 'Position', [35 310 85 340]);

add_block('simulink/Math Operations/Sum', [model '/Suma electrica'], ...
    'Inputs', '+--', 'Position', [200 80 225 150]);
add_block('simulink/Math Operations/Gain', [model '/Ra'], ...
    'Gain', 'Ra', 'Position', [115 165 155 195]);
add_block('simulink/Math Operations/Gain', [model '/Ke'], ...
    'Gain', 'Ke', 'Position', [115 215 155 245]);
add_block('simulink/Math Operations/Gain', [model '/Inverso La'], ...
    'Gain', '1/La', 'Position', [275 95 325 125]);
add_block('simulink/Continuous/Integrator', [model '/Corriente ia'], ...
    'InitialCondition', '0', 'Position', [375 95 405 125]);

add_block('simulink/Math Operations/Gain', [model '/Kt'], ...
    'Gain', 'Kt', 'Position', [115 365 155 395]);
add_block('simulink/Math Operations/Gain', [model '/b'], ...
    'Gain', 'b', 'Position', [115 415 155 445]);
add_block('simulink/Math Operations/Sum', [model '/Suma mecanica'], ...
    'Inputs', '+--', 'Position', [200 330 225 420]);
add_block('simulink/Math Operations/Gain', [model '/Inverso J'], ...
    'Gain', '1/J', 'Position', [275 355 325 385]);
add_block('simulink/Continuous/Integrator', [model '/Velocidad omega'], ...
    'InitialCondition', '0', 'Position', [375 355 405 385]);
add_block('simulink/Continuous/Integrator', [model '/Posicion theta'], ...
    'InitialCondition', '0', 'Position', [490 355 520 385]);

add_block('simulink/Sinks/Scope', [model '/Scope corriente'], ...
    'Position', [490 85 520 115]);
add_block('simulink/Sinks/Scope', [model '/Scope velocidad'], ...
    'Position', [600 345 630 375]);
add_block('simulink/Sinks/Scope', [model '/Scope posicion'], ...
    'Position', [600 405 630 435]);

add_line(model, 'Voltaje va/1', 'Suma electrica/1');
add_line(model, 'Corriente ia/1', 'Ra/1');
add_line(model, 'Ra/1', 'Suma electrica/2');
add_line(model, 'Velocidad omega/1', 'Ke/1');
add_line(model, 'Ke/1', 'Suma electrica/3');
add_line(model, 'Suma electrica/1', 'Inverso La/1');
add_line(model, 'Inverso La/1', 'Corriente ia/1');
add_line(model, 'Corriente ia/1', 'Scope corriente/1');

add_line(model, 'Corriente ia/1', 'Kt/1');
add_line(model, 'Kt/1', 'Suma mecanica/1');
add_line(model, 'Velocidad omega/1', 'b/1');
add_line(model, 'b/1', 'Suma mecanica/2');
add_line(model, 'Torque carga/1', 'Suma mecanica/3');
add_line(model, 'Suma mecanica/1', 'Inverso J/1');
add_line(model, 'Inverso J/1', 'Velocidad omega/1');
add_line(model, 'Velocidad omega/1', 'Posicion theta/1');
add_line(model, 'Velocidad omega/1', 'Scope velocidad/1');
add_line(model, 'Posicion theta/1', 'Scope posicion/1');

set_param(model, 'Solver', 'ode45', 'StopTime', '5');
set_param([model '/Scope corriente'], 'TimeSpan', '5', ...
    'YMin', '0', 'YMax', '6', 'ShowGrid', 'on');
set_param([model '/Scope velocidad'], 'TimeSpan', '5', ...
    'YMin', '0', 'YMax', '50', 'ShowGrid', 'on');
set_param([model '/Scope posicion'], 'TimeSpan', '5', ...
    'YMin', '0', 'YMax', '250', 'ShowGrid', 'on');
save_system(model, [model '.slx']);
sim(model);