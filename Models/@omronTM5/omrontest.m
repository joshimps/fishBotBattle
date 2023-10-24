%CHANGE DH PARAMETERS DEPENDING ON QUESTION
% d = translation z
% a = translation x
% alpha = rotation x
clear
close all

link1 = Link('d',0.1452,'a',0,'alpha',pi/2,'offset',0);
link2 = Link('d',0.146,'a',0.429,'alpha',0,'offset',0);
link3 = Link('d',-0.1297,'a',0.4115,'alpha',0,'offset',0);
link4 = Link('d',0.106,'a',0,'alpha',-pi/2,'offset',0);
link5 = Link('d',0.106,'a',0,'alpha',pi/2,'offset',0);
link6 = Link('d',0.1132,'a',0,'alpha',0,'offset',0);

 % Incorporate joint limits
link(1).qlim = [-270 270]*pi/180;
link(2).qlim = [-180 180]*pi/180;
link(3).qlim = [-155 155]*pi/180;
link(4).qlim = [-180 180]*pi/180;
link(5).qlim = [-180 180]*pi/180;
link(6).qlim = [-270 270]*pi/180;

myRobot = SerialLink([link1 link2 link3 link4 link5 link6], 'name', 'omronTM5');
% myRobot = SerialLink([link1 link2 link3 link4 link5 link6], 'name', 'omronTM5');

workspace = [-0.5 0.5 -0.5 0.5 0 1.5];
scale = 0.5;

q = zeros(1,6);

myRobot.plot(q,'workspace',workspace,'scale',scale);
myRobot.teach;