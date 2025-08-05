clear all
close all
clc

%% ---------- 대기 조건 ----------

% 공기 성질 (압축기 쪽)
g_c = 1.4;
cp_c = 1004;              % [J/kg·K]

% 디퓨저 & 압축기
pi_d = 0.88;              % 디퓨저 압력비
pi_c = 12;                % 압축기 압력비
e_c = 0.9;                % 압축기 등엔트로피 효율

% 연소기
tau_lambda = 8.0;         % 연소기 총정온도 비
Q_R = 42000 * 1000;       % 연료 발열량 [J/kg]
ds_comb = 13.5752;        % 연소기 엔트로피 증가량 [kJ/kg·K]
eta_b = 0.98;             % 연소기 효율
pi_b = 0.95;              % 연소기 압력비
g_t = 1.33;               % 터빈 쪽 기체 비열비
cp_t = 1156;              % 터빈 쪽 비열 [J/kg·K]

% 터빈 & 노즐
e_t = 0.82;               % 터빈 등엔트로피 효율
eta_m = 0.995;            % 기계 효율
pi_n = 0.93;              % 노즐 압력비
p9 = p0;                  % 대기압 [kPa]

%% ---------- 비행조건 ----------

M0 = 2.0;                   
p0 = 10;                  % [kPa] (단위 통일)
T0 = -45 + 273.15;        % [K]
a0 = sqrt((g_c - 1) * cp_c * T0);     % 음속 [m/s]
V0 = M0 * a0;                         % 자유류 속도 [m/s]

pt0 = p0 * (1 + (g_c - 1) / 2 * M0^2)^(g_c / (g_c - 1));   % 총압 [kPa]
Tt0 = T0 * (1 + (g_c - 1) / 2 * M0^2);                     % 총정온도 [K]

R_c = cp_c * (g_c - 1) / g_c;      % 기체 상수 [J/kg·K]

s0 = Air_Entropy(p0, T0);           % 상태 0 엔트로피 [kJ/kg·K]

%% ---------- 인렛 (0 → 2) ----------
pt2 = pt0 * pi_d;                   % 디퓨저 후 총압 [kPa]
Tt2 = Tt0;                         % 디퓨저 후 총정온도 (가정)
s2 = s0 - R_c / 1000 * log(pi_d);  % 디퓨저 엔트로피 변화 [kJ/kg·K]

%% ---------- 압축기 (2 → 3) ----------
pt3 = pt2 * pi_c;    
Tt3 = Tt2 * (pt3 / pt2)^((g_c - 1) / (g_c * e_c));      % 압축기 후 총정온도
s3 = s2 + cp_c / 1000 * log(Tt3 / Tt2) - R_c / 1000 * log(pt3 / pt2); % 압축기 엔트로피 변화

%% ---------- 연소기 (3 → 4) ----------
pt4 = pt3 * pi_b;                 % 연소기 후 총압
Tt4 = tau_lambda * T0;            % 연소기 후 총정온도
f = (cp_t * Tt4 - cp_c * Tt3) / (eta_b * Q_R - cp_t * Tt4);  % 연료-공기비
s4 = s3 + ds_comb;                % 연소기 엔트로피 증가 [kJ/kg·K]

R_t = cp_t * (g_t - 1) / g_t;    % 터빈 쪽 기체 상수 [J/kg·K]

%% ---------- 터빈 (4 → 5) ----------
Tt5 = Tt4 - cp_c * (Tt3 - Tt2) / (eta_m * cp_t * (1 + f));  % 터빈 후 총정온도
pt5 = pt4 * (Tt5 / Tt4)^(g_t / ((g_t - 1) * e_t));          % 터빈 후 총압
s5 = s4 + cp_t / 1000 * log(Tt5 / Tt4) - R_t / 1000 * log(pt5 / pt4);  % 터빈 엔트로피 변화

%% ---------- 노즐 (5 → 9) ----------
Tt7 = Tt5;
pt7 = pt5;
pt9 = pt7 * pi_n;                    % 노즐 후 총압
Tt9 = Tt7;                          % 노즐 후 총정온도

T9 = Tt9 * (p9 / pt9)^((g_t - 1) / g_t);         % 노즐 출구 정온도
V9 = sqrt(2 * cp_t * (Tt9 - T9));                % 출구 속도

s7 = s5;
s9 = s7 - R_t / 1000 * log(pi_n);                 % 노즐 엔트로피 변화

%% ---------- TS 선도 그리기 ----------
figure()
hold on
grid on
title('Non-Ideal Brayton Cycle (TS Diagram)')
xlabel('Entropy, s [kJ/kg·K]')
ylabel('Stagnation Temperature, T_t [K]')

plot([s0, s2], [T0, Tt2], 'r-', 'LineWidth', 2.5)   % 디퓨저
plot([s2, s3], [Tt2, Tt3], 'g-', 'LineWidth', 2.5)  % 압축기
plot([s3, s4], [Tt3, Tt4], 'b-', 'LineWidth', 2.5)  % 연소기
plot([s4, s5], [Tt4, Tt5], 'm-', 'LineWidth', 2.5)  % 터빈
plot([s5, s9], [Tt5, T9], 'k-', 'LineWidth', 2.5)   % 노즐
plot([s0, s9], [T0, T9], 'c--', 'LineWidth', 1.5)   % 순환 경계

legend({'Inlet (0→2)', 'Compressor (2→3)', 'Combustor (3→4)', ...
        'Turbine (4→5)', 'Nozzle (5→9)', 'Cycle boundary'}, ...
        'Location', 'northwest')
