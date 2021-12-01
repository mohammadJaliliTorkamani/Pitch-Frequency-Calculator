%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Mohammad Jalili Torkamani   %
%     Student No : 9523783     %
%       Speech Processing      %
%     Kh.N.Toosi University    %
%          Dr.R.Doost          %
%           JUN 2020           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear screen
clc
%clear local variables
clear all
%declare TO-PROCESS frame number (should be less than numberOfSamples later)
FRAME_NUMBER=129
%declare file name
fileName='a.wav'
%read audio and store samples and sampling frequency
[samples,FS] = audioread(fileName);
%calculate number of samples
numberOfSamples = length(samples);
%display number of Samples
disp(numberOfSamples)
%declare N in high pass liftering
liftering_N=20
%declare desired frame length
fl=400;
%declare frame shifting length
fs=fl*0.4;
%calcualte number of frames with shifting in mind
FN=(numberOfSamples-fl)/fs+1;
FN=round(FN)-1;
%declare an empty array to store pitch frequency(ies)
pitches=zeros(1,FN);
%define hamming windowing
w=hamming(fl);
%for """"JUST THE SELECTED FRAME_NUMBER""" do processing
for i=FRAME_NUMBER:FRAME_NUMBER
    %do slicing to get i'th frame
    s0=samples((i-1)*fs+1:(i-1)*fs+fl);
    %hamming window declaration
    s=w.*s0;
    %calculate time with dividing by FS (NOTE : time is relative to zero (and starts from 0))
    t = (1/FS)*(1:fl)
    %%%%%%%%%%%%% plot frame in (time domain) %%%%%%%%%%%%%%%%
    %prepare for plot
    figure
    %plot signal in time domain
    plot(t,s)
    %label x-axis as "Time (s)"
    xlabel("Time (s)")
    %label y-axis as "Amplitude"
    ylabel("Amplitude")
    %choose title for plot
    title("Frame (Time Domain)")
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %move signal to frequency domain and calculate it's absolute value
    s_fft = abs(fft(s))
    %discard half of it (because it's periodic nad repetetive)
    s_fft = s_fft (1:fl/2);
    %calculate frequency by multiplying to FS/fl
    f = FS*(0:fl/2-1)/fl;
    
    %%%%%%%%%%%%%%%% plot frame (frequency domain) %%%%%%%%%%%%%%%%%%%
    %prepare for plot
    figure
    %plot signal in frequency domain
    plot(f,s_fft )
    %label x-axis as "Frequency (Hz)"
    xlabel("Frequency (Hz)")
    %label y-axis as "Amplitude"
    ylabel("Amplitude")
    %choose plot title as "Frequency Domain"
    title("Frame (Frequency Domain)")
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %calculate logarithm with base 10 of absolute values of signal
    s_fft_log10=log10(s_fft)    
    %inverse FFT (move signal to time domain) and store absolute values
    s_fft_log10_inverse=abs(ifft(s_fft_log10))
    %High pass liftering
    s_fft_log10_inverse=s_fft_log10_inverse(liftering_N:length(s_fft_log10_inverse))
    
    %%%%%%%%%%%%%%%%%%%%%%   plot Cepstrum %%%%%%%%%%%%%%%%%%%%%%%%%
    %prepare for plot
    figure
    %plot logarithm diagram
    plot(1+liftering_N:length(s_fft_log10_inverse)+liftering_N,s_fft_log10_inverse)
    %label x-axis as "Quefrency (Samples)"
    xlabel("Quefrency (Samples)")
    %label y-axis as "Amplitude"
    ylabel("Amplitude")
    %showing plot title as "Cepstrum (High Pass Liftered)"
    title("Cepstrum (High Pass Liftered)")
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %smooth the diagram for easy extremum finding(note : maximums will bed remained as maximum !)
    s_fft_log10_inverse = smooth(s_fft_log10_inverse,6);
    %find all local and global extremum booleans with at least 0.01 as the
    %minimum prominence distance
    TF = islocalmax(s_fft_log10_inverse,'MinProminence',0.01);
    %declare all possible indices
    x=(1:fl)
    %get all local maxima indices
    xtf=x(TF)
    %declare Quefrencies
    s=1+liftering_N:length(s_fft_log10_inverse)+liftering_N
    
    %%%%%%%%%%%%%%%%%%%  plot Cepstru with peaks %%%%%%%%%%%%%%%%%%
    %prepare for plot
    figure
    %plot smooth cepstrum liftered with peaks on it
    plot(s,s_fft_log10_inverse,s(xtf),s_fft_log10_inverse(xtf),"r*")
    %label x-axis as ""
    xlabel("Quefrency (Samples)")
    %label y-axis as
    ylabel("Amplitude")
    %title plot
    title("Smooth Liftered Cepstrum With Peaks")
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %if found indices
    if length(xtf) >0
        %get the max one
        iPos=liftering_N+min(xtf)
        %calculate pitch frequencty
        pitches(i)=FS/iPos;
    else %othersiwe , put zero as pitch frequency
        pitches(i)=0;
    end
end
%%%%%%%%%%%%%%%%%%% plot frame pitch frequency %%%%%%%%%%%%%%%%%
%prepare for plotting
figure
%plot "Frame" as x-axis and "pitch values" as y-axis
%by 'o' drawing  on it.
plot((1:FN),pitches,'o');
%label x-axis as "Frame"
xlabel('Frame')
%label y-axis as "pitch frequency (Hz)"
ylabel('Pitch Frequency (Hz)')
%title whole the plot as the average value(avera pitch in all frames)
title("Pitch Frequency : "+sum(pitches)+" Hz")