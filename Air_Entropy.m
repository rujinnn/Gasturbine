function s2 = Air_Entropy(p2, T2)

% 상수
Ru = 8.314;             % Universal gas constant [J/mol·K]
M = 28.967;             % Molar mass of air [g/mol]
R = Ru / M;             % Specific gas constant [J/g·K]
R = R * 1000 / 1000;    % Convert to kJ/kg·K (J/g·K → kJ/kg·K)

cp = 1.004;             % Specific heat at constant pressure [kJ/kg·K]
T1 = 300;               % Reference temperature [K]
p1 = 100;               % Reference pressure [kPa]
s1 = 5.7016;            % Reference entropy at (T1, p1) [kJ/kg·K]

% Entropy calculation (Ideal gas approximation)
s2 = s1 + cp * log(T2 / T1) - R * log(p2 / p1);  % [kJ/kg·K]

end
