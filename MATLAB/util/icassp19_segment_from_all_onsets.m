function [segment,peakInSeconds] = icassp19_segment_from_all_onsets(x,fs,durationSec)

x=[zeros(1000,1); x];
a = miraudio(x);
o=mironsets(a,'filter','diff','contrast',0.2);
seg = mirsegment(a,o);

peakInSeconds = mirgetdata(o);
peakInSamples = floor(peakInSeconds*fs)+1;

%% segment signal in to 40 ms durations
for n = 1: length(mirgetdata(o))
    segment(:,n) = x(peakInSamples(n):peakInSamples(n)+floor(durationSec*fs)+1);
    segment(:,n) = segment(:,n)/max(segment(:,n));
end
end

