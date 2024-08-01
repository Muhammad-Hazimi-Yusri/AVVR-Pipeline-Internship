
% Script file to convert polar co-ordinates to cartesian
% The loudspeaker positions in the Unity setup
% Paper "Perceived quality and spatial impression of room reverberation in 
% VR reprodution from measured iamge and acoustics
% Luca et al, 2019

r = 1.6;% Distance, Bacause the radius of the collider in Unity is 0.5
% so we need to multiply that by 2

% Azimuths for 0 degree elevation
azim_0 = [0:15:180, -165:15:-15];

% The loudspeakers are irregularly positioned
% Azimuths for 30, & -30 Elevations
azim_30 = [0 30 45 60 90 120 135 150 180 -150 -135 -120 -90 -60 -45 -30]; 
azim_90 = zeros(1,2); % Azimuths for 90, & -90 Elevations
azim = [azim_0, azim_30,azim_30, azim_90]'; % Azimuths

elev = [zeros(1,size(azim_0,2)), -30*ones(1,size(azim_30,2)),...
    30*ones(1,size(azim_30,2)), -90, 90]'; % Elevations

% To convert the angles in degrees to radians
azim_rad = (pi/180)*azim;
elev_rad = (pi/180)*elev;

LS_polar = [azim_rad  elev_rad];

% To convert the polar coordinates to the cartesian as in Unity
% where the y-axis is up-down
mid = r*cos(elev_rad);
x = mid.*cos(azim_rad);
y = r * sin(elev_rad);
z = mid.*sin(azim_rad);

LS_cart =[(1:58)' x y z];

%% The coordinate conversion for our experiments LS setup 
% 64 loudspeakers with azimuths and elevations as follows
% It converts the polar co-ordinates to Cartesian for Unity application

load('DTU_ls_dirs_deg.mat')
azim64 = ls_dirs_deg(:,1); elev64 = ls_dirs_deg(:,2);
azim64_rad = (pi/180)*azim64; elev64_rad = (pi/180)*elev64;

LS_polar64 = [azim64_rad  elev64_rad];
rd = 2.4; % The radius is set to 2.4
% where the y-axis is up-down
mid64 = rd*cos(elev64_rad);
x64 = mid64.*cos(azim64_rad);
y64 = rd * sin(elev64_rad);
z64 = mid64.*sin(azim64_rad);

LS_cart64 =[(1:64)' x64 y64 z64];
