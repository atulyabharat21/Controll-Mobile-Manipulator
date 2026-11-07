% %% QBot Platform (datasheet)
% qb.D = 0.570; qb.H = 0.227; qb.mass = 17; qb.vNom = 0.7; qb.aNom = 0.5;
% %% QBot ASSUMED, replace with real values
% qb.rw = 0.05; qb.track = 0.40; qb.wheelW = 0.03; qb.gc = 0.027;
% qb.mWheel = 0.5; qb.mCastor = 0.05;
% qb.mBody = qb.mass - 2*qb.mWheel - 4*qb.mCastor;      % 15.8 kg
% 
% %% QArm Mini (datasheet)
% qa.reach = 0.382; qa.wNom = deg2rad(60); qa.wMax = deg2rad(180);
% qa.grasp = 0.070; qa.payload = 0.150;
% %% QArm ASSUMED, replace with real values
% qa.h1 = 0.10;                                   % shoulder height above mount
% qa.L2 = 0.160; qa.L3 = 0.142; qa.L4 = 0.080;    % sum = 0.382 m
% qa.mount = [0.10 0 qb.H];                       % arm base position in chassis frame
% 
% m = 'main_simulation_MM';
% conv = find_system([m '/Subsystem'], 'SourceType', 'Simulink-PS Converter');
% for k = 1:numel(conv)
%     set_param(conv{k}, 'FilteringAndDerivatives','filter', 'SimscapeFilterOrder','2');
% end

%% QArm parameters for the merged model (run AFTER params_SMM.m)
% Every value below is a PLACEHOLDER - replace with real values.
% Joint order everywhere: [YAW; SHOULDER; ELBOW; WRIST]
% Joint limits in the QARM model (rad): YAW +-2.967, SHOULDER +-1.483,
% ELBOW [-1.658, 1.309], WRIST +-3.01

%% Joint-space targets fed to the Chart (arm_pos)
qa.tuck   = [0; 0.5; -0.2; 0];     % safe standby (from the comment in controlQArmMode)
qa.pickup = [0; 0.8;  0.3; 0];     % placeholder
qa.drop   = [0.5; 0.8; 0.3; 0];    % placeholder

%% Other Chart inputs
qa.zeroV       = zeros(4,1);       % zero_voltages (PWM override = arm limp)
qa.dropTimeout = 5;                % s, drop_timeout guard in the Chart
qa.attached    = 0;                % arm_attached_sensor (0 = Trace ends on isDone only)

%% Joint controller (qarm_mode = 1: position PD on torque)
qa.Kp     = [4; 6; 4; 1];          % N*m/rad
qa.Kd     = [0.4; 0.6; 0.4; 0.1];  % N*m/(rad/s)
qa.tauMax = [2; 3; 2; 1];          % N*m, saturation and PWM (qarm_mode = 2) scale

%% QBot Platform (datasheet)
qb.D = 0.570; qb.H = 0.227; qb.mass = 17; qb.vNom = 0.7; qb.aNom = 0.5;
%% QArm (datasheet)
qa.reach  = 0.750;           qa.mass = 8.25;
qa.payMin = 0.35;            qa.payMax = 0.75;
qa.wMax   = deg2rad(90);     qa.Ts = 1/500;          % 500 Hz external rate
qa.qMin   = deg2rad([-170 -85 -95 -160])';           % YAW SHOULDER ELBOW WRIST
qa.qMax   = deg2rad([ 170  85  75  160])';

%% QArm (URDF geometry)
qa.h1   = 0.1397714;
qa.Lbic = hypot(0.05, 0.35);                          % 0.3536
qa.Lfor = hypot(0.0336612, 0.2356076);                % 0.2380

%% My choices / ASSUMED
qa.wNom  = deg2rad(45);                               % my pick, tune
qa.mount = [0.10 0 qb.H];                             % ASSUMED, measure on the QBot
