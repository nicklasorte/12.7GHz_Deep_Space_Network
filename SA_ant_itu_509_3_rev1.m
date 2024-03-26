function [array_ant_gain]=SA_ant_itu_509_3_rev1(app,g_not,beamwdith_3dB)



phi=0:0.1:180; %%%%Off- axis anlge (degrees)
phi_not=beamwdith_3dB/2;  %%%%%1/2 of the 3dB beamwidth of the antenna
phi1=phi_not*sqrt(17/3);
phi2=10^((49-g_not)/25);
num_angles=length(phi);
gain_SA_509=NaN(num_angles,1);
for i=1:1:num_angles
    temp_phi=phi(i);

    if 0<=temp_phi && temp_phi<phi1
        gain_SA_509(i)=g_not-3*(temp_phi/phi_not)^2;
    elseif phi1<=temp_phi && temp_phi<phi2
        gain_SA_509(i)=g_not-17;
    elseif phi2<=temp_phi && temp_phi<48
         gain_SA_509(i)=32-25*log10(temp_phi);
    elseif 48<=temp_phi && temp_phi<80
        gain_SA_509(i)=-10;
    elseif 80<=temp_phi && temp_phi<120
        gain_SA_509(i)=-5;
    elseif 120<=temp_phi && temp_phi<=180
        gain_SA_509(i)=-10;
    else
        'Outside of phi range.'
        pause;

    end

end
array_ant_gain=horzcat(phi',gain_SA_509);


end