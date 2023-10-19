clear all
close all
clc

ra=60;

syms P S1 S2 rs1 rs2 rp1 real

eq1='S2-P=(S1-P)*(rs1/rp1)*(rs2+rp1-ra)/rs2';
eq2='1-P=(S1-P)*rs1/ra';

solS1=solve(eq1,eq2,'S1=0','P,S1,S2');
solS2=solve(eq1,eq2,'S2=0','P,S1,S2');
solP=solve(eq1,eq2,'P=0','P,S1,S2');

dPbS1=solS1.P;
dPbS2=solS2.P;% 4th
dS2bS1=solS1.S2;
dS2bP=solP.S2;% rev
dS1bS2=solS2.S1;% 2nd
dS1bP=solP.S1;% 1st

[S1,how]=simple(dS2bS1);
[S2,how]=simple(dS1bP);
[S3,how]=simple(dPbS1);
[S4,how]=simple(dS1bS2);
[S6,how]=simple(dPbS2);
[SR,how]=simple(dS2bP);
disp('First');
pretty(S1)
disp('Second');
pretty(S2)
disp('Third');
pretty(S3)
disp('Fourth');
pretty(S4)
disp('Sixth');
pretty(S6)
disp('Reverse');
pretty(SR)

m=0:3:10;
rs1=24+0*m;
rs2=rs1-m;
rp1=(ra-rs1)/2-4;
%rs1=40, rs2=32, rp1=26

% Rs1=30:5:60;% 57 or 43
% Rs2=30:5:60;% 30
% %Rs1=40, Rs2=30, m=10
% [rs1,rs2]=meshgrid(Rs1,Rs2);
% m=10;
% rs1(rs1>rs2+m)=nan;
% rp1=(ra-rs2)/2-m;
% 

dPbS1=10*log10(subs(dPbS1));
dPbS2=10*log10(subs(dPbS2));
dS2bS1=10*log10(subs(dS2bS1));
dS2bP=10*log10(-subs(dS2bP));
dS1bS2=10*log10(subs(dS1bS2));
dS1bP=10*log10(subs(dS1bP));

i=4;

db=[dPbS1;dPbS2;dS2bS1;dS2bP;dS1bS2;dS1bP]';
logratio=[db(:,2) zeros(length(m),1) db(:,[5 1 6 3 4])]

plot(rs2,logratio,'o-')
%legend('dPbS1','dPbS2','dS2bS1','dS2bP','dS1bS2','dS1bP')

% 
% colormap hsv
% 
% surf(rs1,rs2,dPbS1,zeros(size(rs1))+1,'facealpha',0.4), hold on
% surf(rs1,rs2,dPbS2,zeros(size(rs1))+2,'facealpha',0.4)
% surf(rs1,rs2,dS2bS1,zeros(size(rs1))+3,'facealpha',0.4)
% surf(rs1,rs2,dS2bP,zeros(size(rs1))+4,'facealpha',0.2)
% surf(rs1,rs2,dS1bS2,zeros(size(rs1))+5,'facealpha',0.4)
% surf(rs1,rs2,dS1bP,zeros(size(rs1))+6,'facealpha',0.4)
% xlabel('Rs1')
% ylabel('Rs2')