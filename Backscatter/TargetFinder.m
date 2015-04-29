%%create a pulse waveform
%%Sampling rate is 1MHz
%%Pulsewidth must be less than 1/PRF
%%PRF is the frequency of the pulses
%%Output format is the output signal determinate, set to be pulses
%%number of pulses is how many pulses will be generated

hwav = phased.RectangularWaveform('PulseWidth',1e-6,'PRF',5e3,'OutputFormat','Pulses','NumPulses',1);

%%Set properties for the antenna
%%Frequency range is the range of the operating frequencies for the antenna
%%BackBaffled is set to false, so that all angles above 90 degrees response
%%is zero

hant = phased.IsotropicAntennaElement('FrequencyRange',[1e5,10e8]);

%%Set the target properties
%%Polarized waves are disabled, RCS is surface area of target (m)
%%Nonfluctuating sets the target to be a flat surface, constant
%%velocity through sand is 1.5e8 m/s
%%Operating frequency is the frequency of the antenna, set to be 300MHz
htgt = phased.RadarTarget('Model','Nonfluctuating','MeanRCS',.5,'PropagationSpeed',1.5e8,'OperatingFrequency',3e8);

%%Set up the targets
%%1st target is the antenna which is stationary and set to the following
%%coordinates in space
%%2nd target is the stationary root underground
htxplat = phased.Platform('InitialPosition',[0;0;0],'Velocity',[0;0;0],'OrientationAxes',[1 0 0;0 1 0;0 0 1]);
htgtplat = phased.Platform('InitialPosition',[7; 5; 0],'Velocity',[0;0;0]);

%%find the range and direction from the origin to the target
%%get positions of antenna and target and measure distance
%%the angle is 35.5 degrees and the distance is 8602 meters
[tgtrng,tgtang] = rangeangle(htgtplat.InitialPosition,htxplat.InitialPosition);

%%calculate signal to noise ratio
%%Pd is the probability of noise signal detection 
%%Pfa is the probability of the signal being false
%%False alarms occur whenever the noise voltage excees a defined threshold
%%voltage.  
Pd = 0.9;
Pfa = 1e-6;
numpulses = 10;
SNR = albersheim(Pd,Pfa,10);

disp(SNR);  %%display the calculated SNR

maxrange = 10;  %%calculated range of the antenna signal in meters
lambda = 1.5e8/3e8; %%wavelength of the antenna
tau = hwav.PulseWidth; %%length of each pulse
%%use range equation to help calculate transsmitted power, including
%%calculated gain and loss equation
L = .0398;
G = 25.13;
Pt = radareqpow(lambda,maxrange,SNR,tau,'RCS',.5,'Gain',G,'Loss',L);
disp(Pt);

%%setup waveform transmitter properties
%%peak transmitted power was calculated beofre and given some extra power
%%just to be sure
%%InUseOutputPort allows for constant status updates of the transmitter, 1
%%meaning that it is on and 0 is the transmitter off
%%CoherentOnTransmit means that there is no random phase give to
%%transmitted signals
htx = phased.Transmitter('PeakPower',2e-11,'Gain',G,'LossFactor',L,'InUseOutputPort',true,'CoherentOnTransmit',true);

%%setupt properties of the generator of the narrowband signal attenuator
hrad = phased.Radiator('Sensor',hant,'PropagationSpeed',1.5e8,'OperatingFrequency',3e8);

%%setup the receiver properties, sets the reflected waves to be received as
%%a plane wave instead of relying on sensors
hcol = phased.Collector('Sensor',hant,'PropagationSpeed',1.5e8,'Wavefront','Plane','OperatingFrequency',3e8);

%%setup reflected wave properties
%%gain, loss of receiver
%%Helps to add noise into the input signal with NoiseMethod 
%%NoiseFigure is the nosie received as a scalar
%%sample rate is the sampling of the incoming signal
%%EnableInputPort creates this object to be a receiver of signals which
%%outputs the signal received
%%Seed is used to generate random noise
hrec = phased.ReceiverPreamp('Gain',G,'NoiseFigure',2,'SampleRate',1e6,'EnableInputPort',true,'SeedSource','Property','Seed',1e3);

%%model the propagation from the antenna to the target in sand
%%twowaypropagation false sets the propagation to be strictly to the target 
hspace = phased.FreeSpace('PropagationSpeed',1.5e8,'OperatingFrequency',3e8,'TwoWayPropagation',false,'SampleRate',1e6);

% Time step between pulses
T = 1/hwav.PRF;
% Get antenna position
txpos = htxplat.InitialPosition;
% Allocate array for received echoes
rxsig = zeros(hwav.SampleRate*T,numpulses);

for n = 1:numpulses
    % Update the target position
    [tgtpos,tgtvel] = step(htgtplat,T);
    % Get the range and angle to the target
    [tgtrng,tgtang] = rangeangle(tgtpos,txpos);
    % Generate the pulse
    sig = step(hwav);
    % Transmit the pulse. Output transmitter status
    [sig,txstatus] = step(htx,sig);
    % Radiate the pulse toward the target
    sig = step(hrad,sig,tgtang);
    % Propagate the pulse to the target in free space
    sig = step(hspace,sig,txpos,tgtpos,[0;0;0],tgtvel);
    % Reflect the pulse off the target
    sig = step(htgt,sig);
    % Propagate the echo to the antenna in free space
    sig = step(hspace,sig,tgtpos,txpos,tgtvel,[0;0;0]);
    % Collect the echo from the incident angle at the antenna
    sig = step(hcol,sig,tgtang);
    % Receive the echo at the antenna when not transmitting
    rxsig(:,n) = step(hrec,sig,~txstatus);
end

%%noncoherently integrate the number of pulses
rxsig = pulsint(rxsig,'noncoherent');
%%return a uniformly sampled semi open grid for the interval
t = unigrid(0,1/hrec.SampleRate,T,'[)');
%%set axes 
rangegates = (1.5e8*t)/2;
%%plot the line and the integrated pulses
plot(rangegates,rxsig); 
hold on;
xlabel('Meters'); ylabel('Power');
ylim = get(gca,'YLim');
plot([tgtrng,tgtrng],[0 ylim(2)],'r');

