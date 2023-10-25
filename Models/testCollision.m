robot = omronTM5;
[~, allLink] = robot.model.fkine(robot.model.getpos);

tr = zeros(4,4,robot.model.n+1);
tr(:,:,1) = robot.model.base;
q = robot.model.getpos;

L = robot.model.links;
for i = 1 : robot.model.n
    tr(:,:,i+1) = tr(:,:,i) * trotz(q(i)) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha);
end
centrePoint = zeros(robot.model.n,3);
radii = zeros(robot.model.n,3);
for i = 1:robot.model.n
    x = abs(tr(1,4,i)-tr(1,4,i+1))/2;
    y = abs(tr(2,4,i)-tr(2,4,i+1))/2;
    z = abs(tr(3,4,i)-tr(3,4,i+1))/2;

    centrePoint(i,1) = -(tr(1,4,i+1)-tr(1,4,i))/2;
    centrePoint(i,2) = -(tr(2,4,i+1)-tr(2,4,i))/2;
    centrePoint(i,3) = -(tr(3,4,i+1)-tr(3,4,i))/2; 

    % centrePoint(i,1) = 0;
    % centrePoint(i,2) = 0;
    % centrePoint(i,3) = 0;

    if x < 0.05
        x = 0.05;
    end
    if y < 0.05
        y = 0.05;
    end
    if z < 0.05
        z = 0.05;
    end
    radii(i,1) = x;
    radii(i,2) = y;
    radii(i,3) = z;
end
hold on
for i = 1:robot.model.n
    
    [X,Y,Z] = ellipsoid(centrePoint(i,1), centrePoint(i,2), centrePoint(i,3), radii(i,1), radii(i,2), radii(i,3), 20);
    robot.model.points{i+1} = [X(:),Y(:),Z(:)];
    warning off
    robot.model.faces{i+1} = delaunay(robot.model.points{i+1});    
    warning on;
    % surf(X,Y,Z, 'FaceColor',[0,0,1], 'EdgeColor', 'none');
end
% workspace = [-1 1 -1 1 0 1];
% robot.model.plot3d([0,0,0,0,0,0]);
axis equal
view(3)
robot.model.teach;



