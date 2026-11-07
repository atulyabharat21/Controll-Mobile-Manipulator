%% connect_qarm_to_qbot.m
% Joins the QArm (Subsystem1) to the QBot (Subsystem) so both share the single
% World / Mechanism Configuration / Solver Configuration that already lives
% inside Subsystem.
%
% Run AFTER params_qarm.m / params_SMM.m (needs qa.mount in the base workspace).
% Chain that gets built:
%   QBot base_link frame -> Rigid Transform (qa.mount) -> QBot "Connection Port"
%   -> [Subsystem.lconn  ==  Subsystem1.lconn] -> QArm "Connection Port" -> Weld Joint -> QArm base_link

m      = 'main_simulation_MM';
load_system(m);
qbSys  = [m '/Subsystem'];     % QBot: has World, Mechanism Configuration, Solver Configuration
qaSys  = [m '/Subsystem1'];    % QArm: has NO solver / world of its own (this is the error)

assert(exist('qa','var') && isfield(qa,'mount'), 'Run params_qarm.m first (qa.mount missing).');

%% 1) Inside the QBot: mount transform from chassis frame to the Connection Port
cp     = [qbSys '/Connection Port'];             % already exists, currently wired to nothing
rtName = [qbSys '/QArm_MountTransform'];

if getSimulinkBlockHandle(rtName) == -1       % -1 = block not there yet
    cpPos = get_param(cp, 'Position');
    add_block('sm_lib/Frames and Transforms/Rigid Transform', rtName, ...
        'Position', [cpPos(1)+60, cpPos(2)-10, cpPos(1)+100, cpPos(2)+30]);
    set_param(rtName, ...
        'TranslationMethod',            'Cartesian', ...
        'TranslationCartesianOffset',   'qa.mount', ...
        'TranslationCartesianOffsetUnits', 'm');
end

blPh = get_param([qbSys '/base_link'], 'PortHandles');   % base_link.lconn:1 = chassis reference frame
rtPh = get_param(rtName,               'PortHandles');
cpPh = get_param(cp,                   'PortHandles');

% rigid transform BASE side -> chassis frame (a physical port may take several lines)
add_line(qbSys, blPh.LConn(1), rtPh.LConn(1));
% rigid transform FOLLOWER side -> Connection Port
add_line(qbSys, rtPh.RConn(1), cpPh.RConn(1));

%% 2) At model level: connect the two subsystem frame ports
p1 = get_param(qbSys, 'PortHandles');
p2 = get_param(qaSys, 'PortHandles');
add_line(m, p1.LConn(1), p2.LConn(1));

%% 3) Check
set_param(m, 'SimulationCommand', 'update');
disp('Connected. Model updated without the "no Solver Configuration" error.');