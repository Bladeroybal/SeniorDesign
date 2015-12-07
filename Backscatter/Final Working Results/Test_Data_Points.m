clear, clc

test_true = csvread('s21.csv');

Frequency = transpose(test_true(2:200,1));  %%frequency matrix
Mag_21 = transpose(test_true(2:200,2)); %%amplitude matrix
Phase_21 = transpose(test_true(2:200,3)); 
%Mag_Lin = transpose(test_true(2:200,4));
%figure, plot(Frequency,Phase_21),title('Phase'),xlabel('frequency'),ylabel('phase');


Fs = 7.5E6; %%Sampling Frequency
N = 198;  %% number of Steps
dt = (1/Fs)*2;%(10E-6); %%Change in time between samples
time = 0:(dt/N):dt;
velocity = 1.224E8;


%%Averaging filter on initial data
%smoothes data by ay(x)= b[sum of 0 to n-1](y(n))
a = 1;
b = (1/N)*ones(500,1);
Mag_Lin2=filter(b,a,Mag_21);

%%Inverse Fast Fourier Transform

New_signal = Mag_21.*exp(1*i.*Phase_21);

%figure, plot(Frequency, New_signal);
New_signal_filtered = Mag_21.*exp(1*i.*Phase_21); %%here
FFT_newsignal = abs(ifft(New_signal));
FFT_newsignal_filtered = abs(ifftshift(ifft(ifftshift((New_signal_filtered)))));

%%filter after IFFT using savistzky golay filter
%%Improves SNR using convolution
savitzky_golay = sgolayfilt(FFT_newsignal_filtered,3,41);

%figure, plot(time,New_signal),axis([.0008  .001 -.04 .04]);
figure, plot(Frequency,Mag_Lin2),xlabel('magnitude filtered');
figure, plot(Frequency,Mag_21),xlabel('magnitude plot');
%%figure, plot(Frequency,Mag_Lin),title('Received Power'),xlabel('frequency'),ylabel('linear magnitude');
%%figure, plot(Frequency,Mag_Lin2),title('Received Power Filtered'),xlabel('frequency'),ylabel('linear magnitude');
%figure, plot(time,FFT_newsignal),xlabel('time'),title('Scattering Coefficient'),ylabel('Scattering Coefficient');%axis([.0015  .004 0 6
%%figure, plot(time,FFT_newsignal_filtered),title('Scattering Coefficient Filtered Input'),xlabel('time'),ylabel('Scattering Coefficient');%axis([0  3E-6 0 1]);
figure, plot(time,savitzky_golay),title('Scattering Coefficient Filtered Golay Filter'),xlabel('time'),ylabel('Scattering Coefficient');
%%transfer to spatial domain
distance = velocity.*time;

figure, plot(distance,FFT_newsignal_filtered);%axis([100 700 0 1]),xlabel('depth');
figure, plot(distance,savitzky_golay),title('Depth Golay Filtered'),xlabel('depth(cm)'),ylabel('Scattering Coefficient');;

