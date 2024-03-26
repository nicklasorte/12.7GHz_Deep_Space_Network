clear;
clc;
close all;
app=NaN(1);  %%%%%%%%%This is to allow for Matlab Application integration.
format shortG
top_start_clock=clock;
folder1='C:\Local Matlab Data\12.7GHz';
cd(folder1)
addpath(folder1)
addpath('C:\Local Matlab Data\General_Terrestrial_Pathloss')  
addpath('C:\Local Matlab Data\Generic_Bugsplat')
pause(0.1)


'NASA DSN (Goldstone) 12.75GHz'

%%%%%%%%%%%%%%%%%%%%%%%%%70m Antenna
g_not=78.49;  %%%%%%Max gain dBi
beamwdith_3dB=0.02; %%%%%degrees
[array_ant_gain_70m]=SA_ant_itu_509_3_rev1(app,g_not,beamwdith_3dB);

%%%%%%%%%%%%%%%%%%%%%%%%%34m Antenna
g_not=72.25;  %%%%%%Max gain dBi
beamwdith_3dB=0.04; %%%%%degrees
[array_ant_gain_34m]=SA_ant_itu_509_3_rev1(app,g_not,beamwdith_3dB);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Gold Stone Data
base_pts=vertcat(horzcat(35.4267,-116.8900,73),horzcat(dms2degrees([35,20,22.37]),dms2degrees([-116,52,19.71]),35),horzcat(dms2degrees([35,20,23.61416]),dms2degrees([-116,52,29.25993]),35),horzcat(dms2degrees([35,20,15.40306]),dms2degrees([-116,52,31.30754]),35),horzcat(dms2degrees([35,20,8.48118	]),dms2degrees([-116,52,22.85938]),35)) %%%%%%%Goldstone
multi_array_ant_gain_vertical=horzcat(array_ant_gain_70m(:,2),array_ant_gain_34m(:,2),array_ant_gain_34m(:,2),array_ant_gain_34m(:,2),array_ant_gain_34m(:,2),array_ant_gain_34m(:,1));
%%%%%%%%1-5 is the antenna gain for each protection point, and #6 is the elevation degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Simulation Input Parameters to change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rev=5001; %%%%%%Goldstone Example
str_location_name='Goldstone'
str_system_id='DSN'  %%%%%%%%%%%System Nomenclature
sim_radius_km=301; %%%%%%%%Placeholder distance --> Simplification: This is an automated calculation, but requires additional processing time.
grid_spacing=50;  %%%%km:
bs_eirp=75; %%%%%EIRP [dBm/100MHz] 
bs_height=30;
min_rx_ant_elevation=6; %%%%%% Minimum Elevation Degrees (6)
%%%%%%%%%%%%%%%%%%%%%First, pull all the non-ITM terrain dB reductions in the base stations EIRP (excluding the federal antenna pattern)
array_mitigation=0:10:50;
array_bs_eirp_reductions=bs_eirp; %%%%%%No reductions at this point, just moved all of them to mitigations
receiver_threshold=-110
tf_calc_rx_angle=1  %%%%%%If ==1, you will also need TIREM.
sim_folder1=folder1
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Propagation/Monte Carlo Model Inputs
FreqMHz=12750; %%%%%%%%MHz
reliability=horzcat(0.001,50); %%%A custom ITM range where we will make rings for each reliability
array_reliability_check=reliability;
confidence=50; %%%%%%%%ITM Confidence
Tpol=1; %%%polarization for ITM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Piece together the cell_sim_data
cell_sim_data=cell(1,2);
cell_sim_data{1,1}=strcat(str_location_name,'_',str_system_id); %%%%%%Location Name and System Nomenclature
cell_sim_data{1,2}=base_pts;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Create a Rev Folder
cd(sim_folder1);
pause(0.1)
tempfolder=strcat('Rev',num2str(rev));
[status,msg,msgID]=mkdir(tempfolder);
rev_folder=fullfile(sim_folder1,tempfolder);
cd(rev_folder)
pause(0.1)


tic;
save('reliability.mat','reliability')
save('confidence.mat','confidence')
save('FreqMHz.mat','FreqMHz')
save('Tpol.mat','Tpol')
save('sim_radius_km.mat','sim_radius_km')
save('grid_spacing.mat','grid_spacing')
save('array_bs_eirp_reductions.mat','array_bs_eirp_reductions')
save('bs_height.mat','bs_height')
save('array_reliability_check.mat','array_reliability_check')
save('array_mitigation.mat','array_mitigation')
save('tf_calc_rx_angle.mat','tf_calc_rx_angle')
save('cell_sim_data.mat','cell_sim_data')
toc;


%%%%%%%%%For Loop the Locations
[num_locations,~]=size(cell_sim_data)
base_id_array=1:1:num_locations; %%%%ALL
table([1:num_locations]',cell_sim_data(:,1))

for base_idx=1:1:num_locations
    temp_single_cell_sim_data=cell_sim_data(base_idx,:)
    data_label1=temp_single_cell_sim_data{1}

    %%%%%%%%%Step 1: Make a Folder for this single Location/System
    cd(rev_folder);
    pause(0.1)
    tempfolder2=strcat(data_label1);
    [status,msg,msgID]=mkdir(tempfolder2);
    sim_folder=fullfile(rev_folder,tempfolder2);
    cd(sim_folder)
    pause(0.1)

    tic;
    base_polygon=temp_single_cell_sim_data{2}
    save(strcat(data_label1,'_base_polygon.mat'),'base_polygon')
    base_protection_pts=base_polygon
    save(strcat(data_label1,'_base_protection_pts.mat'),'base_protection_pts')
    save(strcat(data_label1,'_multi_array_ant_gain_vertical.mat'),'multi_array_ant_gain_vertical')
    save(strcat(data_label1,'_min_rx_ant_elevation.mat'),'min_rx_ant_elevation')
    save(strcat(data_label1,'_receiver_threshold.mat'),'receiver_threshold')
    toc;

    strcat(num2str(base_idx/num_locations*100),'%')
end
cd(rev_folder)
pause(0.1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Now running the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tf_server_status=0;
parallel_flag=0;
wrapper_bugsplat_rev6(app,rev_folder,parallel_flag,tf_server_status) %%%%%%%%%%%There is also a complied app that does this, specifically to run on the servers



end_clock=clock;
total_clock=end_clock-top_start_clock;
total_seconds=total_clock(6)+total_clock(5)*60+total_clock(4)*3600+total_clock(3)*86400;
total_mins=total_seconds/60;
total_hours=total_mins/60;
if total_hours>1
    strcat('Total Hours:',num2str(total_hours))
elseif total_mins>1
    strcat('Total Minutes:',num2str(total_mins))
else
    strcat('Total Seconds:',num2str(total_seconds))
end
cd(folder1)
'Done'





