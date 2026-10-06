Ra = 2;
La = 0.023;
Ke = 0.01;
Kt = 0.01;
b = 0.0012;
J = 0.001;
va = 12;

model = 'MotorDC_Simscape';
if bdIsLoaded(model)
    close_system(model, 0);
end
new_system(model);
open_system(model);
load_system('fl_lib');
load_system('simscape');

source = addLibraryBlock('DC Voltage Source', [model '/Fuente DC']);
sensorI = addLibraryBlock('Current Sensor', [model '/Sensor corriente']);
resistor = addLibraryBlock('Resistor', [model '/Resistencia armadura']);
inductor = addLibraryBlock('Inductor', [model '/Inductancia armadura']);
converter = addLibraryBlock('.*Rotational.*Electromechanical.*Converter.*', ...
    [model '/Convertidor electromecanico']);
inertia = addLibraryBlock('Inertia', [model '/Inercia rotor']);
damper = addLibraryBlock('Rotational Damper', [model '/Amortiguamiento']);
electricalRef = addLibraryBlock('Electrical Reference', ...
    [model '/Referencia electrica']);
rotationalRef = addLibraryBlock('.*Mechanical.*Rotational.*Reference.*', ...
    [model '/Referencia rotacional']);
motionSensor = addLibraryBlock('.*Ideal.*Rotational.*Motion.*Sensor.*', ...
    [model '/Sensor movimiento']);
solver = add_block('nesl_utility/Solver Configuration', ...
    [model '/Solver Configuration']);
currentPS = add_block('nesl_utility/PS-Simulink Converter', ...
    [model '/Corriente a Simulink']);
speedPS = add_block('nesl_utility/PS-Simulink Converter', ...
    [model '/Velocidad a Simulink']);
positionPS = add_block('nesl_utility/PS-Simulink Converter', ...
    [model '/Posicion a Simulink']);
currentScope = add_block('simulink/Sinks/Scope', ...
    [model '/Scope corriente']);
speedScope = add_block('simulink/Sinks/Scope', ...
    [model '/Scope velocidad']);
positionScope = add_block('simulink/Sinks/Scope', ...
    [model '/Scope posicion']);

setParameter(currentPS, {'Unit', 'OutUnit', 'OutputSignalUnit'}, 'A');
setParameter(speedPS, {'Unit', 'OutUnit', 'OutputSignalUnit'}, 'rad/s');
setParameter(positionPS, {'Unit', 'OutUnit', 'OutputSignalUnit'}, 'rad');

setParameter(source, {'v0', 'V', 'Voltage'}, 'va');
setParameter(resistor, {'R', 'Resistance'}, 'Ra');
setParameter(inductor, {'L', 'Inductance'}, 'La');
setParameter(converter, {'K', 'Kt', 'TorqueConstant'}, 'Kt');
setParameter(inertia, {'I', 'J', 'Inertia', 'inertia'}, 'J');
setParameter(damper, {'b', 'D', 'd', 'Damping'}, 'b');

set_param(source, 'Position', [40 140 95 190]);
set_param(sensorI, 'Position', [150 140 205 190]);
set_param(resistor, 'Position', [260 140 315 190]);
set_param(inductor, 'Position', [370 140 425 190]);
set_param(converter, 'Position', [500 115 590 215]);
set_param(inertia, 'Position', [690 115 745 165]);
set_param(damper, 'Position', [690 205 745 255]);
set_param(motionSensor, 'Position', [820 125 880 205]);
set_param(electricalRef, 'Position', [260 275 290 305]);
set_param(rotationalRef, 'Position', [690 315 720 345]);
set_param(solver, 'Position', [40 280 75 315]);
set_param(currentPS, 'Position', [280 350 350 390]);
set_param(speedPS, 'Position', [690 390 760 430]);
set_param(positionPS, 'Position', [820 390 890 430]);
set_param(currentScope, 'Position', [400 350 440 390]);
set_param(speedScope, 'Position', [780 470 820 510]);
set_param(positionScope, 'Position', [900 470 940 510]);

connectBySide(model, source, 'LConn', 1, sensorI, 'LConn', 1);
connectBySide(model, sensorI, 'RConn', 2, resistor, 'LConn', 1);
connectBySide(model, resistor, 'RConn', 1, inductor, 'LConn', 1);
connectBySide(model, inductor, 'RConn', 1, converter, 'LConn', 1);
connectBySide(model, converter, 'RConn', 1, source, 'RConn', 1);
connectBySide(model, converter, 'LConn', 2, inertia, 'LConn', 1);
connectBySide(model, converter, 'LConn', 2, damper, 'LConn', 1);
connectBySide(model, damper, 'RConn', 1, rotationalRef, 'LConn', 1);
connectBySide(model, converter, 'RConn', 2, rotationalRef, 'LConn', 1);
connectBySide(model, converter, 'LConn', 2, motionSensor, 'LConn', 1);
connectBySide(model, motionSensor, 'RConn', 1, rotationalRef, 'LConn', 1);
connectBySide(model, source, 'RConn', 1, electricalRef, 'LConn', 1);
connectBySide(model, source, 'RConn', 1, solver, 'RConn', 1);
connectCompatiblePhysicalPorts(model, sensorI, currentPS, []);
usedMotionPorts = connectCompatiblePhysicalPorts(model, motionSensor, speedPS, []);
usedMotionPorts = [usedMotionPorts, ...
    connectCompatiblePhysicalPorts(model, motionSensor, positionPS, usedMotionPorts)];
connectSimulinkOutput(model, currentPS, currentScope);
connectSimulinkOutput(model, speedPS, speedScope);
connectSimulinkOutput(model, positionPS, positionScope);

set_param(model, 'StopTime', '5', 'Solver', 'ode23t');
set_param(currentScope, 'TimeSpan', '5', ...
    'YMin', '0', 'YMax', '6', 'ShowGrid', 'on');
set_param(speedScope, 'TimeSpan', '5', ...
    'YMin', '0', 'YMax', '50', 'ShowGrid', 'on');
set_param(positionScope, 'TimeSpan', '5', ...
    'YMin', '0', 'YMax', '250', 'ShowGrid', 'on');
save_system(model, [model '.slx']);
sim(model);

function block = addLibraryBlock(blockName, destination)
if ~contains(blockName, '.*')
    blockName = ['^' regexptranslate('escape', blockName) '$'];
end
matches = find_system('fl_lib', 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'RegExp', 'on', 'Name', blockName);
if isempty(matches)
    error('No se encontro el bloque Simscape: %s', blockName);
end
block = add_block(matches{1}, destination);
end

function setParameter(block, candidates, value)
parameters = get_param(block, 'DialogParameters');
parameterNames = fieldnames(parameters);
for k = 1:numel(candidates)
    idx = find(strcmpi(parameterNames, candidates{k}), 1);
    if ~isempty(idx)
        set_param(block, parameterNames{idx}, value);
        return;
    end
end
prompts = cellfun(@(name) parameters.(name).Prompt, parameterNames, ...
    'UniformOutput', false);
for k = 1:numel(candidates)
    idx = find(strcmpi(prompts, candidates{k}), 1);
    if ~isempty(idx)
        set_param(block, parameterNames{idx}, value);
        return;
    end
end
error('No se encontro el parametro %s. Parametros disponibles: %s', ...
    strjoin(candidates, '/'), strjoin(parameterNames, ', '));
end

function connectBySide(model, source, sourceSide, sourceIndex, ...
        destination, destinationSide, destinationIndex)
sourcePorts = get_param(source, 'PortHandles');
destinationPorts = get_param(destination, 'PortHandles');
sourceHandles = sourcePorts.(sourceSide);
destinationHandles = destinationPorts.(destinationSide);
if numel(sourceHandles) < sourceIndex || ...
        numel(destinationHandles) < destinationIndex
    error('Puertos incompatibles al conectar %s con %s.', ...
        source, destination);
end
add_line(model, sourceHandles(sourceIndex), ...
    destinationHandles(destinationIndex), 'autorouting', 'on');
end

function sourceHandle = connectCompatiblePhysicalPorts(model, source, ...
        destination, usedSourceHandles)
sourcePorts = get_param(source, 'PortHandles');
destinationPorts = get_param(destination, 'PortHandles');
sourceHandles = [sourcePorts.LConn sourcePorts.RConn];
destinationHandles = [destinationPorts.LConn destinationPorts.RConn];
for sourceHandle = sourceHandles
    if ismember(sourceHandle, usedSourceHandles)
        continue;
    end
    for destinationHandle = destinationHandles
        try
            add_line(model, sourceHandle, destinationHandle, ...
                'autorouting', 'on');
            return;
        catch
        end
    end
end
error('No se encontro una salida fisica compatible de %s.', source);
end

function connectSimulinkOutput(model, source, destination)
sourcePorts = get_param(source, 'PortHandles');
destinationPorts = get_param(destination, 'PortHandles');
add_line(model, sourcePorts.Outport(1), destinationPorts.Inport(1), ...
    'autorouting', 'on');
end