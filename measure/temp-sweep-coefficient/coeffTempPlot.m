TEMP   = [-20 -10 0 10 20 30 40 50 60 70 80 90                         ];

GRP0C1 = [2 1    1.6   2    2    2    2   2   2   2   2    2.44        ];
GRP1C1 = [2 1    1.66  2    2    2    2   2   2   2   2    2           ];
GRP2C1 = [2 1.8  2     2    2    2    2   2   2   2   2.21 2.66        ];
GRP3C1 = [2 1    1     1.6  1.8  2    2   2   2   2   2    2           ];
GRP4C1 = [2 2    2     2    2    2    2   2   2   2   2.55 3           ];
GRP5C1 = [2 1    1     2    2    2    2   2   2   2   2.21 2.77        ];
GRP6C1 = [2 1.8  2     2    2    2    2   2   2   2   2    2.89        ];
GRP7C1 = [2 1    2     2    2    2    2   2   2   2   2    2.44        ];

GRP0C2 = [2 2    2     2    2    2    2   2.21 2.66    3   3    3      ];
GRP1C2 = [2 2    2     2    2    2    2   2    2.21    3   3    3      ];
GRP2C2 = [2 2    2     2    2    2    2   2    2       2   3    3      ];
GRP3C2 = [2 2    2     2    2    2    2   2    2       2   3    3      ];
GRP4C2 = [2 2    2     2    2    2    2   2    2       2.55 3   3      ];
GRP5C2 = [2 2    2     2    2    2    2   2    3       3   3    3      ];
GRP6C2 = [2 2    2     2    2    2    2   2    2.66    3   3    3      ];
GRP7C2 = [2 2    2     2    2    2    2   2    3       3   3    3      ];

GRP0C3 = [2 2    2     2    2    2    2   2    2.5    2.71  3    3     ];
GRP1C3 = [2 2    2     2    2    2    2   2.5  3       3    3    3     ];
GRP2C3 = [2 2    2     2    2    2    2   2    3       3    3    3     ];
GRP3C3 = [2 2    2     2    2    2    2   2    3       3    3    3     ];
GRP4C3 = [2 2    2     2    2    2    2   2    3       2.71 3    3     ];
GRP5C3 = [2 2    2     2    2    2    2   3    3       3    3    3     ];
GRP6C3 = [2 2    2     2    2    2    2   3    2.66    3    3    3     ];
GRP7C3 = [2 2    2     2    2    2    2   3    3       3    3    3     ];


figure();


ax1 = subplot(8,1,1);
plot(ax1,TEMP,GRP0C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax1,TEMP,GRP0C2,'-o');
plot(ax1,TEMP,GRP0C3,'-o');
ylabel('ADC Group 0');

title('Correction Coefficient vs Temperature');

ax2 = subplot(8,1,2);
plot(ax2,TEMP,GRP1C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax2,TEMP,GRP1C2,'-o');
plot(ax2,TEMP,GRP1C3,'-o');
ylabel('ADC Group 1');

ax3 = subplot(8,1,3);
plot(ax3,TEMP,GRP2C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax3,TEMP,GRP2C2,'-o');
plot(ax3,TEMP,GRP1C3,'-o');
ylabel('ADC Group 2');

ax4 = subplot(8,1,4);
plot(ax4,TEMP,GRP3C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax4,TEMP,GRP3C2,'-o');
plot(ax4,TEMP,GRP3C3,'-o');
ylabel('ADC Group 3');

ax5 = subplot(8,1,5);
plot(ax5,TEMP,GRP4C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax5,TEMP,GRP4C2,'-o');
plot(ax5,TEMP,GRP4C3,'-o');
ylabel('ADC Group 4');

ax6 = subplot(8,1,6);
plot(ax6,TEMP,GRP5C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax6,TEMP,GRP5C2,'-o');
plot(ax6,TEMP,GRP5C3,'-o');

ylabel('ADC Group 5');

ax7 = subplot(8,1,7);
plot(ax7,TEMP,GRP6C1,'-o');
ylim([0 4]);
grid on;
hold on;
plot(ax7,TEMP,GRP6C2,'-o');
plot(ax7,TEMP,GRP6C3,'-o');

ylabel('ADC Group 6');

ax8 = subplot(8,1,8);
plot(ax8,TEMP,GRP7C1,'-o');
grid on;
hold on;
plot(ax8,TEMP,GRP7C2,'-o');
plot(ax8,TEMP,GRP7C3,'-o');
hL = legend('Chip 1','Chip 2','Chip 3');
ylim([0 4]);
ylabel('ADC Group 7');
xlabel('Die Temperature [deg C]');


newPosition = [0.825 0.05 0.1 0.1];

newUnits = 'normalized';

set(hL,'Position', newPosition,'Units', newUnits);
