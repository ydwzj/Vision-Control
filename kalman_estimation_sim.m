T = 0.01338; g = 9.8;
F = [1, 0, T, 0; 0, 1, 0, T; 0, 0, 1, 0; 0, 0, 0, 1];
G = [0.5*g*T^2, 0; 0, -0.5*g*T^2; g*T, 0; 0, -1*g*T];
H = [1 0 0 0; 0 1 0 0];
t = (0:T:3)'; w_sd = 0.05;  v_sd = 0.005;
Q = G*((w_sd^2)*eye(2))*G';
R = (v_sd^2)*eye(2);
w = w_sd*randn(length(t), 2);
v = v_sd*randn(length(t), 2);
sys = ss(F, G, H, 0, -1);
y = lsim(sys, w);
yv = y + v;
plot(t, y(:,1), t, y(:,2), t, yv(:, 1), t, yv(:,2));
%sprintf('''%.1f'', ',get(gca,'xtick'))
%sprintf('''%.2f'', ',get(gca,'ytick'))
set(gca,'xticklabel', {'0.0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0'});
set(gca,'yticklabel', {'-0.20', '-0.15', '-0.10', '-0.05', '0.00', '0.05', '0.10'})
