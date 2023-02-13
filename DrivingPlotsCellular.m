%% Plotting Driving Data
% Requires at least matlab 2018b
clc; clear; close all;
[file_name, file_path] = uigetfile('*.csv','Select Data');
file = string(file_path) + (file_name);
[sys_time,rssi,lat,long] = importCellData(file);

%%  Received Signal Strength Indicator Adjustment
for i=1:length(rssi)
    if abs(rssi(i)) > 200
        rssiAdj(i) = NaN;
    else
        rssiAdj(i) = rssi(i);
    end
end
% rssiAdj = rssiAdj.^-1;
% % rmin = min(abs(rssiAdj));
% % rmax = max(abs(rssiAdj));
% rmax = 1/30; %Excellect Cell Service
% rmin = 1/120; %Poor Cells Service
% radj = ((abs(rssiAdj) - rmin) .* (100-15)/(rmax-rmin) + 25);
% radj(isnan(radj))=0.0001;
%% Fixing Lat/Lon.......

data = [lat long, rssiAdj'];

data = data(isfinite(data(:,1)), :);
data(data(:,1) == -1, :) = [];

lat = data(:,1);
long = data(:,2);
rssiAdj = data(:,3);

%%

figure('Name','Route');
geoplot(lat(2:end),long(2:end),'b','LineWidth',3)

%%

figure('Name','Cell Service Map');
geoplot(lat(2:end),long(2:end),'k:','LineWidth',3); hold on; 
geoplot(lat(2),long(2),'k*','MarkerSize',19);
geoscatter(lat(2:end),long(2:end),95,rssiAdj(2:end),'filled','MarkerFaceAlpha',.9);

%%
cb = colorbar;                                  % create and label the colorbar
cb.Label.String = 'Celluar Signal Strength (dBm)';
legend('Route Path', 'Start Point', 'Cell Service');
set(gcf,'position',[10,40,800,600])
geobasemap topographic

%Distance Traveled
y = deg2km(lat(2:end)); x = deg2km(long(2:end));
dis = hypot(y,x); dis = dis-min(dis);
DisTrav = 0;
for i=2:length(dis)
    DisTrav(i) = DisTrav(i-1) + abs(dis(i)-dis(i-1)); 
end
figure;
plot(DisTrav,rssiAdj(2:end)); grid;
xlabel('Distance Traveled (km)'); ylabel('Cell Signal Strength (dBm)');
