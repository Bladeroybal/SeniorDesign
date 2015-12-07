clear all; close all; clc

%> USER INPUT
DataIN = csvread('Test1_895mm_Data.csv');

N = size(DataIN,1);   % Implementation: Avoid hardwiring values 

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%%patch data goes freq, phase, linear, log 

%{
NOTE: This step is not necessary in MATLAB. Also, you can just say 
       test_true(:,ColumnNumber).
%}

% MUTEDMUTEDMUTED MUTEDMUTEDMUTED MUTEDMUTEDMUTED MUTEDMUTEDMUTED MUTEDMUT%
% Frequency = transpose(test_true(1:points,1));  %%frequency matrix
% Mag_21 = transpose(test_true(:,2));            %%amplitude matrix
% Phase_21 = transpose(test_true(1:points,3)); 
% Mag_Lin = transpose(test_true(1:points,4));
% MUTEDMUTEDMUTED MUTEDMUTEDMUTED MUTEDMUTEDMUTED MUTEDMUTEDMUTED MUTEDMUT%

Frequency = DataIN(:,1);                           % [Hz]
Phase_21    = DataIN(:,2);                           % Amplitude
Mag_Lin  = DataIN(:,3);
Mag_21   = DataIN(:,4);

%%Averaging filter on initial data
%smoothes data by ay(x)= b[sum of 0 to n-1](y(n))
a = 1;
b = (1/N)*ones(300,1);
Mag_Lin2=filter(b,a,Mag_Lin);




%%display magnitude and phase data
figure (1)
plot(Frequency/1E9,Phase_21)
title('Phase Spectrum')
xlabel('Frequency [GHz]')
ylabel('Phase')
axis tight

figure(2)
plot(Frequency/1E9, Mag_Lin2)
title('Amplitude Spectrum')
xlabel('frequency[GHz]')
ylabel('Mag')
axis tight


%%> COMPLEX SIGNAL DEFINITION
%{
Using Eurler's since phase seems to be given in degrees. Recall that 
Euler's Idendity states that exp(ip) = cos(p)+isin(p). cosd => that input
is given in terms of degrees and not radiants. 
%}

New_signal_Linear = Mag_Lin.*(cosd(Phase_21)+sqrt(-1)*sind(Phase_21));
New_signal_Log = Mag_21.*(cosd(Phase_21)+sqrt(-1)*sind(Phase_21));


%%IFFT
% FFT_newsignal = ifft((New_signal_Log));
FFT_newsignal_Li = ifftshift(ifft((ifftshift(New_signal_Linear))));
FFT_newsignal_Lo = ifftshift(ifft((ifftshift(New_signal_Log))));


%> Defining Time Axis
% Using: df = f_s/N = 1/(N*dt) 

df = Frequency(2)-Frequency(1);         % df = f(i+1) - f(i)
dt = 1/(N*df);
time = 0:dt:dt*(N-1);
velocity = 3E8;        % EM wave in free space [m/s]                  

figure(3)
plot(time*1E6,abs(FFT_newsignal_Li))
title('Amplitude vs. Time')
xlabel('Time [\muS]')
ylabel('Amplitude')
axis tight


figure(4)
plot(time*1E6,abs(FFT_newsignal_Lo))
title('Amplitude (for Log Data) vs. Time')
xlabel('Time [\muS]')
ylabel('Amplitude')
axis tight

distance = time.*(1E-3)*velocity; 

figure(5)
plot(distance,abs(FFT_newsignal_Li))
title('Amplitude (for Log Data) vs. Time')
xlabel('Distance [m]')
ylabel('Amplitude')
axis tight

figure(6)
plot(Frequency,New_signal_Log)
title('Amplitude (for Log Data) vs. Time')
xlabel('Distance [m]')
ylabel('Amplitude')
axis tight



return




% exp(1*i.*Phase_21);
% New_signal_Log = Mag_21.*exp(1*i.*Phase_21);

%figure, plot(Frequency, New_signal);

%%Filter complex signal
%New_signal_filtered = Mag_Lin2.*exp(1*i.*Phase_21); %%here
%FFT_newsignal_filtered = abs((ifftshift(((New_signal_filtered))))));

%%filter after IFFT using savistzky golay filter
%%Improves SNR using convolution
%savitzky_golay = sgolayfilt(FFT_newsignal,3,41);

%figure, plot(time,New_signal),axis([.0008  .001 -.04 .04]);
%figure, plot(Frequency,Phase_21);
%figure, plot(Frequency,Mag_21);
%figure, plot(Frequency,Mag_Lin),title('Received Power'),xlabel('frequency'),ylabel('linear magnitude');
%figure, plot(Frequency,Mag_Lin2),title('Received Power Filtered'),xlabel('frequency'),ylabel('linear magnitude');
figure, plot(time,FFT_newsignal),xlabel('time'),title('Scattering Coefficient'),ylabel('Scattering Coefficient');%axis([.0015  .004 0 6
%figure, plot(time,FFT_newsignal_filtered),title('Scattering Coefficient Filtered Input'),xlabel('time'),ylabel('Scattering Coefficient');%axis([0  3E-6 0 1]);
%figure, plot(time,savitzky_golay),title('Scattering Coefficient Filtered Golay Filter'),xlabel('time'),ylabel('Scattering Coefficient');%axis([.2E-5 .4E-5 0 3.5E-3]);
%%transfer to spatial domain
distance = velocity.*time;

figure, plot(distance,FFT_newsignal);%axis([100 700 0 1]),xlabel('depth');
%figure, plot(distance,savitzky_golay),title('Depth Golay Filtered'),xlabel('depth(m)'),ylabel('Scattering Coefficient');;


