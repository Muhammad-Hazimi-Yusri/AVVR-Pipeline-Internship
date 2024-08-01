addpath RIRs

[kit, fs] = audioread('Kitchen_BFormat.wav');

L = length(kit);
t = (1:L)/fs; 

initial_delay = find(abs(kit(:,1))==max(abs(kit(:,1))));
Delay_kt = initial_delay;
Delay_rsao = 303; % For Kitchen in RSAO json file

t2 = t(1:0.2*fs-Delay_kt+1);
t1 = t(1:0.2*fs-Delay_rsao+1);


%load rir_regen_rsao.mat
addpath Unity-ogg-files\

[sirr_rir,fs]=audioread('SIRR_Kitchen_RIR.ogg');
rir_sirr_fig_mid = sirr_rir(Delay_kt:0.2*fs,:);
% Re-ordering the channels from Unity to WXYZ
rir_sirr_fig(:,1)=rir_sirr_fig_mid(:,1); % channel W
rir_sirr_fig(:,2)=rir_sirr_fig_mid(:,4); % channel X 
rir_sirr_fig(:,3)=rir_sirr_fig_mid(:,2); % channel Y 
rir_sirr_fig(:,4)=rir_sirr_fig_mid(:,3); % channel Z

% [rsao_rir,fs]=audioread('RSAO_Kitchen_rir_64.ogg');
[rsao_rir,fs]=audioread('RSAO_Kitchen_SigTmix.ogg');
rir_regen_rsao_mid=rsao_rir; %(1:10*fs,:);
% Re-ordering the channels from Unity to WXYZ
rir_regen_rsao(:,1)=rir_regen_rsao_mid(:,1); % channel W
rir_regen_rsao(:,2)=rir_regen_rsao_mid(:,4); % channel X 
rir_regen_rsao(:,3)=rir_regen_rsao_mid(:,2); % channel Y 
rir_regen_rsao(:,4)=rir_regen_rsao_mid(:,3); % channel Z

%[merged_rir,fs]=audioread('T_diff_Combo_Kitchen_rir.ogg');
%[merged_rir,fs]=audioread('Combined_Kitchen_Han.ogg');
%[merged_rir,fs]=audioread('Combined_Kitchen_Han_Tm.ogg');
[merged_rir,fs]=audioread('Combined_Kitchen_nondiff_Tdiff_Han.ogg');

merged_rir(1,:) = rir_sirr_fig_mid (1,:);
merged_rir_fig_mid = merged_rir(1:0.2*fs,:);
% Re-ordering the channels from Unity to WXYZ
merged_rir_fig(:,1)=merged_rir_fig_mid(:,1); % channel W
merged_rir_fig(:,2)=merged_rir_fig_mid(:,4); % channel X 
merged_rir_fig(:,3)=merged_rir_fig_mid(:,2); % channel Y 
merged_rir_fig(:,4)=merged_rir_fig_mid(:,3); % channel Z

%%
ch = 1;
figure;
subplot(3,1,1);
plot(t2', kit(Delay_kt:0.2*fs,ch)); hold on;
plot(t2',rir_sirr_fig(1:0.2*fs-Delay_kt+1,ch),'r');
ylim([-0.4 0.4]);
xlim([0 0.15]); % xlabel ({'Time [s]'},'FontSize',10); 
ylabel({'Amplitude'},'FontSize',12);
title('(a)','FontSize',12);
legend({'GT RIR','SIRR'},'FontSize',10)

figure;
subplot(2,1,1);

plot(t1', kit(Delay_rsao:0.2*fs,ch)); hold on;
% plot(t1',rir_regen_rsao(1:0.2*fs-Delay_rsao+1,ch),'r'); ylim([-0.4 0.4]);
% I realized that the direct sound at the beginning was not recorded in Unity
% Therefore, I consider the second impulse
plot(t1',rir_regen_rsao(L+1:L+0.2*fs-Delay_rsao+1,ch),'r'); ylim([-0.4 0.4]);
xlim([0 0.15]); % xlabel ({'Time [s]'},'FontSize',10); 
ylabel({'Amplitude'},'FontSize',12);
title('(b)','FontSize',12);
legend({'GT RIR','RSAO'},'FontSize',10)

T_difuse = 0.04*fs;
% T_mix = round(0.0277*fs);
%initial_delay = 303;
T_mix = T_difuse - initial_delay;

%figure; 
subplot(2,1,2);
% plot(t1', kit(Delay_rsao:0.2*fs,ch)); hold on;
% plot(t1',merged_rir_fig(1:0.2*fs-Delay_rsao+1,ch),'r');
plot(t2', kit(Delay_kt:0.2*fs,ch)); hold on;
plot(t2',merged_rir_fig(1:0.2*fs-Delay_kt+1,ch),'r');
% plot(t2(1:T_mix-1)',merged_rir_fig(1:T_mix-1,ch),'r');
% hold on; plot(t1(T_mix:end)',rir_regen_rsao(T_mix:0.2*fs-Delay_rsao+1,ch),'r');
ylim([-0.4 0.4]);
xlim([0 0.15]); xlabel ({'Time [s]'},'FontSize',12); 
ylabel({'Amplitude'},'FontSize',12);
title('(c)','FontSize',12);
legend({'GT RIR','Combined'},'FontSize',10)

%%
ch = 1;
M = 1000;
figure;
subplot(3,1,1);
plot(t2', 10*log10(abs(kit(Delay_kt:0.2*fs,ch)))); hold on;
plot(t2', 10*log10(abs(rir_sirr_fig(1:0.2*fs-Delay_kt+1,ch))),'r');
ylim([-30 2]);
xlim([0 0.02]); % xlabel ({'Time [s]'},'FontSize',10); 
ylabel({'Amplitude'},'FontSize',12);
title('(a)','FontSize',12);
legend({'GT RIR','SIRR'},'FontSize',10)

figure;
subplot(2,1,1);
rir_regen_rsao(1,:) = rir_regen_rsao(L+1,:);
plot(M*t1', 10*log10(abs(kit(Delay_rsao:0.2*fs,ch)))); hold on;
plot(M*t1',10*log10(abs(rir_regen_rsao(L+1:L+0.2*fs-Delay_rsao+1,ch))),'r'); ylim([-40 2]);
% I realized that the direct sound at the beginning was not recorded in Unity
% Therefore, I consider the second impulse
% plot(t1',rir_regen_rsao(L+1:L+0.2*fs-Delay_rsao+1,ch),'r'); ylim([-0.4 0.4]);
xlim([0 10]); % xlabel ({'Time [s]'},'FontSize',10); 
ylabel({'Amp[dB]'},'FontSize',12);
title('(a)','FontSize',12);
legend({'GT RIR','RSAO'},'FontSize',10); grid on;

% T_difuse = 0.04*fs;
% T_mix = round(0.0277*fs);
%initial_delay = 303;
% T_mix = T_difuse - initial_delay;

%figure; 
subplot(2,1,2);
% plot(t1', kit(Delay_rsao:0.2*fs,ch)); hold on;
% plot(t1',merged_rir_fig(1:0.2*fs-Delay_rsao+1,ch),'r');
plot(M*t2', 10*log10(abs(kit(Delay_kt:0.2*fs,ch)))); hold on;
plot(M*t2', 10*log10(abs(merged_rir_fig(1:0.2*fs-Delay_kt+1,ch))),'r');
% plot(t2(1:T_mix-1)',merged_rir_fig(1:T_mix-1,ch),'r');
% hold on; plot(t1(T_mix:end)',rir_regen_rsao(T_mix:0.2*fs-Delay_rsao+1,ch),'r');
ylim([-40 2]);
xlim([0 10]); xlabel ({'Time [ms]'},'FontSize',12); 
ylabel({'Amp[dB]'},'FontSize',12);
title('(b)','FontSize',12);
legend({'GT RIR','Combined'},'FontSize',10); grid on;
%% ........................................................................

addpath 'RIRs' 'IoSR Toolbox' 'octave'

earlyt = 0.04; % for kitchen
% tlen = 0.2968; % for kitchen in order to not exceed the RSAO second impulse
tlen = 0.3; % Kitchen
% earlyt = 0.03; % for DWRC
% tlen = 0.20; % for DWRC
% earlyt = 0.08; % for CY
% tlen = 0.5; % for CY

rir_record = kit(Delay_kt:tlen*fs,:);
kit_corr = zeros(1,4);
rir_record(:,1)=rir_record(:,1)./max(rir_record(:,1));
for i=1:4 % Number of channels
    xcor_kit =xcorr(rir_record(1:earlyt*fs,i),rir_record(1:earlyt*fs,i));
    kit_corr(i)=max(xcor_kit);
end
clear i
audiowrite('rir_record.wav',rir_record./2,fs);
[RT, DRR, C50, Cfs, EDT] = iosr.acoustics.irStats('rir_record.wav','graph', true, 'spec', 'full');

% [RT, DRR, C50, Cfs, EDT] = iosr.acoustics.irStats('Kitchen_Bformat.wav');

rir_sirr_mid = sirr_rir(Delay_kt:tlen*fs,:);
% Re-ordering the channels from Unity to WXYZ
rir_sirr(:,1)=rir_sirr_mid(:,1)./(max(rir_sirr_mid(:,1))); % channel W
rir_sirr(:,2)=rir_sirr_mid(:,4); % channel X 
rir_sirr(:,3)=rir_sirr_mid(:,2); % channel Y 
rir_sirr(:,4)=rir_sirr_mid(:,3); % channel Z

audiowrite('rir_sirr.wav',rir_sirr./2,fs);
sirr_corr = zeros(1,4);
for i=1:4 % Number of channels
    xcor_sirr =xcorr(rir_record(1:earlyt*fs,i),rir_sirr(1:earlyt*fs,i));
    sirr_corr(i)=max(xcor_sirr);
end
clear i

[RT_sirr, DRR_sirr, C50_sirr, Cfs, EDT_sirr] = iosr.acoustics.irStats('rir_sirr.wav','graph', true, 'spec', 'full');


rsao_rir(1,:) = rsao_rir(L+1,:); 
rir_rsao_mid = rsao_rir(1:tlen*fs-Delay_kt+1,:); % To have the same length 
% rir_rsao_mid = rsao_rir(L+1:L+tlen*fs-Delay_kt+1,:); % To have the same length 
% as SIRR RIR
% Re-ordering the channels from Unity to WXYZ
rir_rsao(:,1)=rir_rsao_mid(:,1)./(max(rir_rsao_mid(:,1))); % channel W 
rir_rsao(:,2)=rir_rsao_mid(:,4); % channel X 
rir_rsao(:,3)=rir_rsao_mid(:,2); % channel Y 
rir_rsao(:,4)=rir_rsao_mid(:,3); % channel Z
audiowrite('rir_rsao.wav',rir_rsao./2,fs);

rsao_corr = zeros(1,4);
for i=1:4 % Number of channels
    xcor_rsao =xcorr(rir_record(1:earlyt*fs,i),rir_rsao(1:earlyt*fs,i));
    rsao_corr(i)=max(xcor_rsao);
end
clear i

[RT_rsao, DRR_rsao, C50_rsao, Cfs, EDT_rsao] = ...
    iosr.acoustics.irStats('rir_rsao.wav','graph', true, 'spec', 'full');

merged_rir(1,:) = sirr_rir(Delay_kt,:);
rir_merged_mid = merged_rir(1:tlen*fs-Delay_kt,:);
% Re-ordering the channels from Unity to WXYZ
rir_merged(:,1)=rir_merged_mid(:,1)./(max(rir_merged_mid(:,1))); % channel W 
rir_merged(:,2)=rir_merged_mid(:,4); % channel X 
rir_merged(:,3)=rir_merged_mid(:,2); % channel Y 
rir_merged(:,4)=rir_merged_mid(:,3); % channel Z
audiowrite('rir_merged.wav',rir_merged./2,fs);

merged_corr = zeros(1,4);
for i=1:4 % Number of channels
    xcor_merged =xcorr(rir_record(1:1:earlyt*fs,i),rir_merged(1:earlyt*fs,i));
    merged_corr(i)=max(xcor_merged);
end
clear i

[RT_merged, DRR_merged, C50_merged, Cfs, EDT_merged] = ...
    iosr.acoustics.irStats('rir_merged.wav','graph', true, 'spec', 'full');


results = [mean(RT); C50; mean(EDT)
           mean(RT_sirr); C50_sirr; mean(EDT_sirr)
           mean(RT_rsao); C50_rsao; mean(EDT_rsao)
           mean(RT_merged); C50_merged; mean(EDT_merged)];


