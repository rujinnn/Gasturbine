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

%% ----------디퓨저 (0 → 2) ----------
pt2 = pt0;
Tt2 = Tt0;
s2 = s0;

%% ---------- 팬에 의한 상수 ----------
B = 6;            % 바이패스 비
pi_f = 1.6;       % 팬 압력비
pi_c = 12;        % 압축기 압력비
tau_lambda = 8.0; % 비총정온도 
Q_R = 42000 * 1000;       % [J/kg] 연료 발열량

m0 = 1.0;
m_c = 1/(1+B);    % [kg/s] 코어 질유량 
m_b = B/(1+B);    % [kg/s] 바이패스 질유량

%% ---------- 팬 (2 -> f) ----------
pt_f = pt2 * pi_f;
Tt_f = Tt2 * (pi_f)^((g_c - 1) / g_c);
s_f = Air_Entropy(pt_f, Tt_f);

%% ---------- 바이패스 노즐 (f -> 9b) ----------
pt9b = pt_f;   % 손실 무시
Tt9b = Tt_f;
T9b = Tt9b * (p9 / pt9b)^((g_c - 1)/g_c);
V9b = sqrt(2 * cp_c * (Tt9b - T9b));  % 바이패스 출수 속도

%% ---------- 압축기 (f -> 3) ----------
pt3 = pt_f * pi_c;
Tt3 = Tt_f * (pt3 / pt_f)^((g_c - 1) / g_c);
s3 = s_f;

%% ---------- 연소기 (3 -> 4) (core) ----------
Tt4 = tau_lambda * T0;
pt4 = pt3;
s4 = Air_Entropy(pt4, Tt4);
f = (cp_t * Tt4 - cp_c * Tt3) / (Q_R - cp_t * Tt4);

%% ---------- 터빈 (4 -> 5) : 코어 터빈이 압축기 + 팬 구동(코어 기준) ----------
W_comp_core = cp_c * (Tt3 - Tt_f); % 코어 압축기의 일
W_fan_equiv_core = B * cp_c * (Tt_f - Tt2); % 팬의 일

deltaT_turbine = (W_comp_core + W_fan_equiv_core) / (cp_t * (1 + f)); % 터빈의 온도 변화
Tt5 = Tt4 - deltaT_turbine;
pt5 = pt4 * (Tt5 / Tt4)^(g_t / (g_t - 1));
s5 = s4;

%% ---------- 코어 노즐 (5 -> 9c) ----------
Tt9c = Tt5;
pt9c = pt5;
T9c = Tt9c * (p9 / pt9c)^((g_t - 1) / g_t);
V9c = sqrt(2 * cp_t * (Tt9c - T9c));  % core 출구 속도 (연소 후)
s9 = s5;

%% ---------- TS 선도와 효율 ----------
figure()
hold on; grid on;
title('Turbofan TS diagram')
xlabel('Entropy s [kJ/kg·K]')
ylabel('T_t [K]')

% 코어 경로 TS 선도
plot([s0, s2], [T0, Tt2], 'r-', 'LineWidth', 2);
plot([s2, s3], [Tt2, Tt3], 'g-', 'LineWidth', 2);
plot([s3, s4], [Tt3, Tt4], 'b-', 'LineWidth', 2);
plot([s4, s5], [Tt4, Tt5], 'm-', 'LineWidth', 2);
plot([s5, s9], [Tt5, T9c], 'c-', 'LineWidth', 2);
plot([s0, s9], [T0, T9c], 'k--', 'LineWidth', 1.5)   % 이상 순환계 연결선

% 바이패스 경로 TS 선도
plot([s2, s_f], [Tt2, Tt_f], 'ks', 'LineWidth', 2);   % 팬 구간
plot([s_f, s_f], [Tt_f, T9b], 'ko'.', 'LineWidth', 2);  % 바이패스 노즐 

legend({'Inlet (0→2)', 'Compressor (2→3)', 'Combustor (3→4)', ...
        'Turbine (4→5)', 'Nozzle (5→9)', 'Cycle boundary', ...
        'Fan (Bypass)', 'Bypass Nozzle'}, ...
        'Location', 'northwest')

eta_th = ((1 + f) * V9c^2 - V0^2) / (2 * f * Q_R) + B * (V9b^2 - V0) / (2 * f * Q_R); % 열역학적 효율
eta_p = ((1 + f) * V9c + B * V9b - (1 + B) * V0) * 2 * V0 / B * V9b^2 + (1 + f) * V9c^2 - (1 + B) * V0^2; % 추진효율
sF = ((1 + f)*V9c + B*V9b)/(1 + B) - V0; % 비추력

fprintf('Thermal Efficiency (η_th): %.4f\n', eta_th);
fprintf('Thrust Efficiency (η_p): %.4f\n', eta_p);
fprintf('Specific Thrust (T_s): %.4f\n', sF);
