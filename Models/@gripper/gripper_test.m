
r = omronTM5;

tr = r.model.fkine(r.model.getpos).T;

hold on;

workspace = [-0.5 0.5 -0.5 0.5 0 1.5];
scale = 0.5;

fingers = gripper(tr);

piece = chess(1);

piece.chessModel{1}.base

q = r.model.ikcon(piece.chessModel{1}.base.T * troty(pi))

r.model.animate(q);

pos = r.model.fkine(r.model.getpos()).T;

fingers.UpdateBase(pos);

fingers.Open;

pause(3)

fingers.Close;

pause(3)
