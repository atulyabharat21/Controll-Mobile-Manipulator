params_qarm;
here = fileparts(mfilename('fullpath'));
f = dir(fullfile(here,'qarm','**','*.urdf'));
disp({f.name})                                  % shows which URDF files were found
urdfFile = fullfile(f(1).folder, f(1).name);
robot = importrobot(urdfFile);  robot.DataFormat = 'column';
robot.Gravity = [0 0 -9.81];    ee = 'END-EFFECTOR';

sum(cellfun(@(b) b.Mass, robot.Bodies))      % expect ~5.76 kg
show(robot, zeros(4,1));

% reach check against 0.75 m
d = zeros(5000,1);
for k = 1:5000
    q = qa.qMin + (qa.qMax-qa.qMin).*rand(4,1);
    d(k) = norm(tform2trvec(getTransform(robot,q,ee)));
end
max(d)