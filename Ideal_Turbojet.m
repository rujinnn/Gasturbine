clear all
close all
clc

%% ---------- 대기 조건, 상수 ----------
M0 = 2.0;
p0 = 10;                
T0 = -45 + 273.15;        

% 공기 특성 (압축기 측)
g_c = 1.4;                % 연소기 전 비열비
g_t = 1.33;               % 연소기 후 비열비
cp_c = 1.004 * 1000;      % [J/kg·K] 압축기 정압비열
cp_t = 1.156 * 1000;      % [J/kg·K] 터빈 정압비열
a0 = sqrt((g_c - 1) * cp_c * T0); 
V0 = M0 * a0;
p9 = p0;                  

pt0 = p0 * (1 + (g_c - 1)/2 * M0^2)^(g_c / (g_c - 1));  
Tt0 = T0 * (1 + (g_c - 1)/2 * M0^2);                   
s0 = Air_Entropy(p0, T0);                               
%% ---------- 디퓨저 (0 → 2) ----------
pt2 = pt0;
Tt2 = Tt0;
s2 = s0;

%% ---------- 압축기 (2 → 3) ----------
pi_c = 12;
pt3 = pt2 * pi_c;
Tt3 = Tt2 * (pt3 / pt2)^((g_c - 1) / g_c);
s3 = s2;

%% ---------- 연소기 (3 → 4) ----------
tau_lambda = 8.0;         % 비총정온도
Q_R = 42000 * 1000;       % [J/kg] 연료 발열량
pt4 = pt3;
Tt4 = tau_lambda * T0;
s4 = Air_Entropy(pt4, Tt4);
f = (cp_t * Tt4 - cp_c * Tt3) / (Q_R - cp_t * Tt4);   % 연공비

%% ---------- 터빈 (4 → 5) ----------
Tt5 = Tt4 - cp_c * (Tt3 - Tt2) / (cp_t * (1 + f));
pt5 = pt4 * (Tt5 / Tt4)^(g_t / (g_t - 1));
s5 = s4;

%% ---------- 노즐 (5 → 9) ----------
p9 = p0;                 
Tt9 = Tt5;
pt9 = pt5;
T9 = Tt9 * (p9 / pt9)^((g_t - 1) / g_t);
V9 = sqrt(2 * cp_t * (Tt9 - T9));
s9 = s5;

%% ---------- TS 선도 ----------
figure()
hold on
grid on
title('Ideal Brayton Cycle (TS Diagram)')
xlabel('Entropy, s [kJ/kg·K]')
ylabel('Stagnation Temperature, T_t [K]')

% 단계별 선도 선 그리기
plot([s0, s2], [T0, Tt2], 'r-',  'LineWidth', 2.5)  % 디퓨저
plot([s2, s3], [Tt2, Tt3], 'g-', 'LineWidth', 2.5)  % 압축기
plot([s3, s4], [Tt3, Tt4], 'b-', 'LineWidth', 2.5)  % 연소기
plot([s4, s5], [Tt4, Tt5], 'm-', 'LineWidth', 2.5)  % 터빈
plot([s5, s9], [Tt5, T9], 'k-',  'LineWidth', 2.5)  % 노즐
plot([s0, s9], [T0, T9], 'c--', 'LineWidth', 1.5)   % 이상 순환계 연결선

legend({'Inlet (0→2)', 'Compressor (2→3)', 'Combustor (3→4)', ...
        'Turbine (4→5)', 'Nozzle (5→9)', 'Cycle boundary'}, ...
        'Location', 'northwest')

eta_th = ((1 + f) * V9^2 - V0^2) / (2 * f * Q_R); %열역학적 효율
eta_p = 2 / (1 + V9 / V0); % 추진효율
sF = (1 + f)*V9 - V0; %비추력


fprintf('Thermal Efficiency (η_th): %.4f\n', eta_th);
fprintf('Thrust Efficiency (η_p): %.4f\n', eta_p);
fprintf('Specific Thrust (T_s): %.4f\n', sF);
