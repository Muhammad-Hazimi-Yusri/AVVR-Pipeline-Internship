addpath RIRs\

[kit, fs] = audioread('Kitchen_BFormat.wav');
hW = kit(:,1).'; hX = kit(:,2).'; hY = kit(:,3).'; hZ = kit(:,4).';

T = length (kit);
T2= 48; % 10 ms or 0.01 s
t = (1:T2)/fs;

theta = (0:5:90)*pi/180; % The azimuth 0 < theta < 2pi
phi = (0:5:90)*pi/180; % The elevation -pi/2 < phi < pi/2

Theta = repmat(permute(theta,[2,1]),[1, size(phi,2), T2]);
Phi = repmat(phi, [size(theta,2), 1, T2]);
ttime = repmat(permute(t, [1,3,2]), [size(theta,2), size(phi,2),1]);
% phi = 0;

d= 1;
rx = d*(cos(theta).')*cos(phi);
ry = d*(sin(theta).')*cos(phi);
rz = d*sin(phi);

hx = permute(hX(1:T2),[1,3,2]); hy = permute(hY(1:T2),[1,3,2]);
hz = permute(hZ(1:T2),[1,3,2]);
hx = repmat(hx,[size(theta,2),size(phi,2),1]); 
hy = repmat(hy,[size(theta,2),size(phi,2),1]);
hz = repmat(hz,[size(theta,2),size(phi,2),1]);
 
% Srt = 0.5*(hW + rx*hX + ry*hY);
% Srt = 0.5*(rx*hX + ry*hY);
% Srt_comp = Srt .*(10.^((6/20)*log2(t)));
Rx = repmat(rx,[1,1,T2]); Ry = repmat(ry,[1,1,T2]); 
Rz = repmat(rz,[1,1,T2]);
Srt_3D = 0.5*(Rx.*hx + Ry.*hy + Rz.*hz);
comp = (10.^(-(6/20)*log2(t))); % To compensate for the drop of energy
bias = repmat(permute(comp, [1,3,2]),[size(theta,2),size(phi,2),1]);
Srt_comp = randn(size(theta,2),size(phi,2),T2); %Srt_comp = Srt_3D .* bias;
% figure; imagesc(theta, phi, rx, [-1 1]);
% figure; imagesc(theta, phi, ry, [0 1]);

figure; scatter3(Theta(:),Phi(:),ttime(:),abs(Srt_comp(:)),'filled');
%% 

figure; imagesc( (1:T2)/fs, (theta)*180/pi, Srt(:,1:T2),[0 0.1]); 
xlabel ('time [s]'); ylabel ('\theta [degree]')

figure; imagesc( (1:T2)/fs, (theta)*180/pi, Srt_comp(:,1:T2),[0 0.001]); 
xlabel ('time [s]'); ylabel ('\theta [degree]')

figure; imagesc( (1:T2)/fs, (theta)*180/pi, -log10(Srt(:,1:T2).^2),[0 10]); 
xlabel ('time [s]'); ylabel ('\theta [degree]')

figure; h = imagesc( (1:T2)/fs, (theta)*180/pi, 1000.*(Srt(:,1:T2)),[0 500]); 
xlabel ('time [s]'); ylabel ('\theta [degree]')