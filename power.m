total = 177;

POWER = [8 30 98 30 31];

LABELS = {'DVDD References — 8.85 mW', 'DVDD Columns (TDC+SS) — 31.8 mW', 'AVDD Columns (S/H + COMP) — 102.5 mW', 'AVDD References — 31.8 mW', 'DVDD LVDS — 33.6 mW'};

h=pie3(POWER,LABELS);
set(h(2:2:6),'FontSize',14);