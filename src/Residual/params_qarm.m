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