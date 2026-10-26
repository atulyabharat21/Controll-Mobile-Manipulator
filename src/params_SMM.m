%% QBot Platform (datasheet)
qb.D = 0.570; qb.H = 0.227; qb.mass = 17; qb.vNom = 0.7; qb.aNom = 0.5;
%% QBot ASSUMED, replace with real values
qb.rw = 0.05; qb.track = 0.40; qb.wheelW = 0.03; qb.gc = 0.027;
qb.mWheel = 0.5; qb.mCastor = 0.05;
qb.mBody = qb.mass - 2*qb.mWheel - 4*qb.mCastor;      % 15.8 kg

%% QArm Mini (datasheet)
qa.reach = 0.382; qa.wNom = deg2rad(60); qa.wMax = deg2rad(180);
qa.grasp = 0.070; qa.payload = 0.150;
%% QArm ASSUMED, replace with real values
qa.h1 = 0.10;                                   % shoulder height above mount
qa.L2 = 0.160; qa.L3 = 0.142; qa.L4 = 0.080;    % sum = 0.382 m
qa.mount = [0.10 0 qb.H];                       % arm base position in chassis frame

m = 'SimulationMobileManipulator';
conv = find_system([m '/Subsystem'], 'SourceType', 'Simulink-PS Converter');
for k = 1:numel(conv)
    set_param(conv{k}, 'FilteringAndDerivatives','filter', 'SimscapeFilterOrder','2');
end