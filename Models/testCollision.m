robot = omronTM5;
[~, allLink] = robot.model.fkine(robot.model.getpos);

tr = zeros(4,4,robot.model.n+2);
tr(:,:,1) = robot.model.base;
q = [0 0 0 0 0 0];

L = robot.model.links;
for i = 1 : robot.model.n
    tr(:,:,i+1) = tr(:,:,i) * trotz(q(i)) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha);
end
    tr(:,:,robot.model.n+2) = tr(:,:,robot.model.n) * trotz(q(robot.model.n)) * transl(0,0,L(robot.model.n).d+0.05) * transl(L(robot.model.n).a,0,0) * trotx(L(robot.model.n).alpha);

    centrePoint = zeros(robot.model.n,3);
radii = zeros(robot.model.n,3);
for i = 1:robot.model.n+1
    x = abs(tr(1,4,i)-tr(1,4,i+1))/2 + 0.1;
    y = abs(tr(2,4,i)-tr(2,4,i+1))/2 + 0.1;
    z = abs(tr(3,4,i)-tr(3,4,i+1))/2 + 0.1;

    centrePoint(i,1) = -(tr(1,4,i+1)-tr(1,4,i))/2;
    centrePoint(i,2) = -(tr(2,4,i+1)-tr(2,4,i))/2;
    centrePoint(i,3) = (tr(3,4,i+1)-tr(3,4,i))/2; 

    if x < 0.1
        x = 0.1;
    end
    if y < 0.1
        y = 0.1;
    end
    if z < 0.1
        z = 0.1;
    end

    radii(i,1) = x;
    radii(i,2) = y;
    radii(i,3) = z;
end
hold on
for i = 1:robot.model.n+1
    
    [X,Y,Z] = ellipsoid(centrePoint(i,1), centrePoint(i,2), centrePoint(i,3), radii(i,1), radii(i,2), radii(i,3), 20);
    robot.model.points{i+1} = [X(:),Y(:),Z(:)];
    warning off
    robot.model.faces{i+1} = delaunay(robot.model.points{i+1});    
    warning on;
    % surf(X,Y,Z, 'FaceColor',[0,0,1], 'EdgeColor', 'none');
end
% workspace = [-1 1 -1 1 0 1];
robot.model.plot3d([0,0,0,0,0,0]);
axis equal
view(3)
robot.model.teach;



