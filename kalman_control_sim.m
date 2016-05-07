T = 0.01338; g = 9.8; Kp = 0.3; Kd = 0.4;  w_sd = 0.04; v_sd = 0.002; t = (0:T:5)';
F = [1, 0, T, 0; 0, 1, 0, T; 0, 0, 1, 0; 0, 0, 0, 1];
G = [0.5*g*T^2, 0; 0, 0.5*g*T^2; g*T, 0; 0, 1*g*T]; H = [1 0 0 0; 0 1 0 0];
Q = G*((w_sd^2)*eye(2))*G'; R = (v_sd^2)*eye(2);
x_all = zeros(length(t), 4); xe_all = zeros(length(t), 4); y_all = zeros(length(t), 2);
P = zeros(4,4);  x = zeros(4,1); xe = zeros(4,1); u = [0;0]; 
for i=2:length(t)
    % system simulation
    w = w_sd*randn(2,1); v = v_sd*randn(2,1);
    x = F*x + G*(u+w); y = H*x + v;
    x_all(i,:) = x'; y_all(i,:) = y';
    %Time update
    xe = F*xe + G*u;
    P = F*P*F' + Q;
    %Measurement update
    K = P*H'/(H*P*H'+R);
    xe = xe + K*(y - H*xe);
    P = (eye(4) - K*H)*P*(eye(4) - K*H)' + K*R*K';
    ye = H*xe;
    u = -1*(Kp*ye + Kd*xe(3:4));
    xe_all(i,:) = xe';
end
plot(t, xe_all(:,1), t, xe_all(:, 2)); xlabel('时间（s）');ylabel('X方向、Y方向位置(m)');

%sprintf('''%.1f'', ',get(gca,'xtick'))
set(gca,'xticklabel', {'0.0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0', '3.5', '4.0', '4.5', '5.0'});
%sprintf('''%.3f'', ',get(gca,'ytick'))
set(gca,'yticklabel', {'-0.030', '-0.025', '-0.020', '-0.015', '-0.010', '-0.005', '0.000', '0.005', '0.010', '0.015'})

