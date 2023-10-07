
r = ur3;

tr = r.model.fkine(self.r.model.getpos).T;

hold on;

fingers = gripper(tr);
