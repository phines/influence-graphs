% options
addpath('../dcsimsep');
addpath('../dcsimsep/data');
opt = psoptions;
opt.draw.width = 0.2;
opt.draw.fontsize = 14;
C = psconstants;
% load the case data
ps = case6_mod_ps;
% run power flow
ps = dcpf(ps);
%printps(ps);
% draw the case
figure(1); clf;
set(gca,'fontsize',16);
drawps(ps,opt);
