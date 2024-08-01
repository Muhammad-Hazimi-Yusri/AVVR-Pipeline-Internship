

% Script file to plot an example of a RIR signal with clusters around the
% early reflection peaks

% We consider N=4 reflections at N times & directions (theta & phi)

Ttime = [10, 32, 54, 87];

rnd = round(10*randn(4,10));

times_mat = Ttime'+ rnd;
figure; plot(abs(times_mat(:)),ones(1,length(times_mat(:))),'-*');

Theta = [35, 55, 105, 160];

rnd = round(10*randn(4,10));

theta_mat = Theta'+ rnd;
figure; plot(abs(theta_mat(:)),ones(1,length(theta_mat(:))),'-*');

phi = [0, 20, 35, 85];

rnd = round(5*randn(4,10));

phi_mat = phi'+ rnd;
figure; plot(abs(phi_mat(:)),ones(1,length(phi_mat(:))),'-*');

amp = [10, 6, 3, 8];
rnd = round(2*randn(4,10));

amp_mat =(amp'+ rnd);
figure; plot(abs(amp_mat(:)),'-*');
figure; scatter3(abs(theta_mat(:)),abs(phi_mat(:)),abs(times_mat(:)),5*abs(amp_mat(:)),'filled');
xlabel('\theta'); ylabel('\phi'); zlabel('time')
