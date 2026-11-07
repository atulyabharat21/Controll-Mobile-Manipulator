%% fix_qarm_mount.m  -  clean up the previous attempt, rebuild, and report wiring
m     = 'main_simulation_MM';
qbSys = [m '/Subsystem'];      % QBot
qaSys = [m '/Subsystem1'];     % QArm
cp    = [qbSys '/Connection Port'];
rt    = [qbSys '/QArm_MountTransform'];
load_system(m);

%% 0) CLEAN UP: remove the transform (takes its lines with it), then every line
%     left on the Connection Port and on the top-level frame ports.
if getSimulinkBlockHandle(rt) ~= -1, delete_block(rt); end
delLines(get_param(cp,    'PortHandles'));
delLines(get_param(qbSys, 'PortHandles'));      % top-level lines on Subsystem
delLines(get_param(qaSys, 'PortHandles'));      % top-level lines on Subsystem1

%% 1) REBUILD inside the QBot
cpPos = get_param(cp,'Position');
add_block('sm_lib/Frames and Transforms/Rigid Transform', rt, ...
    'Position', [cpPos(1)+60, cpPos(2)-10, cpPos(1)+100, cpPos(2)+30]);
set_param(rt, 'TranslationMethod','Cartesian', ...
              'TranslationCartesianOffset','qa.mount', ...
              'TranslationCartesianOffsetUnits','m');

bl  = get_param([qbSys '/base_link'], 'PortHandles');
rtP = get_param(rt, 'PortHandles');
cpP = get_param(cp, 'PortHandles');
add_line(qbSys, bl.LConn(1),  rtP.LConn(1));    % B side -> chassis frame
add_line(qbSys, rtP.RConn(1), cpP.RConn(1));    % F side -> Connection Port

%% 2) top level
p1 = get_param(qbSys,'PortHandles');  p2 = get_param(qaSys,'PortHandles');
add_line(m, p1.LConn(1), p2.LConn(1));

%% 3) REPORT what every involved port is now attached to
fprintf('\n--- wiring report ---\n');
report(qbSys, 'base_link',            get_param([qbSys '/base_link'],'PortHandles'));
report(qbSys, 'QArm_MountTransform',  get_param(rt,'PortHandles'));
report(qbSys, 'Connection Port',      get_param(cp,'PortHandles'));
report(m,     'Subsystem',            get_param(qbSys,'PortHandles'));
report(m,     'Subsystem1',           get_param(qaSys,'PortHandles'));
fprintf('---------------------\n');

set_param(m,'SimulationCommand','update');

%% helpers
function delLines(ph)
    for f = {'LConn','RConn'}
        for p = ph.(f{1})(:)'
            ln = get_param(p,'Line');
            if ln ~= -1, delete_line(ln); end
        end
    end
end
function report(~, name, ph)
    for f = {'LConn','RConn'}
        for k = 1:numel(ph.(f{1}))
            ln = get_param(ph.(f{1})(k),'Line');
            if ln == -1
                fprintf('%-22s %s%d : (unconnected)\n', name, f{1}, k);
            else
                s = get_param(ln,'SrcPortHandle'); d = get_param(ln,'DstPortHandle');
                other = [s d]; other(other == ph.(f{1})(k)) = [];
                for o = other(:)'
                    fprintf('%-22s %s%d : <-> %s (%s%s)\n', name, f{1}, k, ...
                        get_param(get_param(o,'Parent'),'Name'), ...
                        get_param(o,'PortType'), num2str(get_param(o,'PortNumber')));
                end
            end
        end
    end
end