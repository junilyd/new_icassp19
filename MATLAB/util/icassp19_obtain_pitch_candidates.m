%   --------------------------------------------------------
%   Estimates overlapping fundamental frequency candidates
%   for standard guitar tuning.
%   --------------------------------------------------------
%   INPUTS:
%              f0 :		Fundamental frequency in Hz 
%	EStringTuning :     Tuning of E-string fret 0 in Hz (optional)   
%
%   OUTPUTS:
%       candidates:     Vector containing possible overlaps to check
%						these are given as (string,fret) 
%										   (string,fret) 
%										   (string,fret) in MATLAB indeces
%						(i.e. string 1, fret 3 = (1,4))
% 
% There can be between one and three candidates, so that should be checked
% version 1.1 (7/4-2015 - jmhh)
% E can now be used as 2nd input or else E=82.4 Hz
% returns string and fret candidates and number of candidates
% --------------------------------------------------------
% [string, fret, numCandidates] = smc_find_f0_candidates(f0, EStringTuning)
% --------------------------------------------------------
function [stringCandidates, fretCandidates, numCandidates] = icassp19_obtain_pitch_candidates(observedPitch, frequencyReference)
% if nargin < 2
% 	EStringTuning = 82.41;
% end
% E = EStringTuning;
% make a lookup table for fundamental frequencies
% and estimate candidate 1
%frequencyReference = [E E*2^(5/12) E*2^(10/12) E*2^(15/12) E*2^(19/12) E*2^(24/12)]';
%frequencyReference([1:6],:) = frequencyReference([1:6])*2.^([0:12]/12)
[tmp, candidates(1,2)] = min(min(abs(frequencyReference-observedPitch)));
[tmp, candidates(1,1)] = min(abs(frequencyReference(:,candidates(1,2))-observedPitch));

% translate to human understandable string and fret.
string = candidates(1,1);
candidates(1,2) = candidates(1,2)-1;
fret   = candidates(1,2);

% Find all candidates
if string == 1 && (fret > 4 && fret < 10)
    candidates(2,1) = string+1;
    candidates(2,2) = fret-5;
end
if string == 1 && fret > 9
	candidates(2,1) = string+1;
    candidates(2,2) = fret-5;
    candidates(3,1) = string +2;
    candidates(3,2) = fret-10;
end
if string == 2 && fret < 5 
	candidates(2,1) = string-1;
	candidates(2,2) = fret+5;
end
if string == 2 && (fret > 4 && fret < 8)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
	candidates(3,1) = string-1;
	candidates(3,2) = fret+5;
end
if string == 2 && (fret > 7 && fret < 10)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
end
if string == 2 && (fret > 9)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
	candidates(3,1) = string+2;
	candidates(3,2) = fret-10;
end

if string == 3 && fret < 5 
	candidates(2,1) = string-1;
	candidates(2,2) = fret+5;
end
if string == 3 && fret < 3 
	candidates(3,1) = string-2;
	candidates(3,2) = fret+10;
end
if string == 3 && (fret > 4 && fret < 8)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
	candidates(3,1) = string-1;
	candidates(3,2) = fret+5;
end
if string == 3 && (fret > 7 && fret < 10)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
end
if string == 3 && (fret > 8)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
	candidates(3,1) = string+2;
	candidates(3,2) = fret-9;
end

if string == 4 && fret < 4 
	candidates(2,1) = string-1;
	candidates(2,2) = fret+5;
end
if string == 4 && fret < 3 
	candidates(3,1) = string-2;
	candidates(3,2) = fret+10;
end
if string == 4 && (fret > 3 && fret < 8)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-4;
	candidates(3,1) = string-1;
	candidates(3,2) = fret+5;
end
if string == 4 && (fret > 7 && fret < 10)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-4;
end
if string == 4 && (fret > 8)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-4;
	candidates(3,1) = string+2;
	candidates(3,2) = fret-9;
end

if string == 5 && fret < 5 
	candidates(2,1) = string-1;
	candidates(2,2) = fret+4;
end
if string == 5 && fret < 4 
	candidates(3,1) = string-2;
	candidates(3,2) = fret+9;
end
if string == 5 && (fret > 4 && fret < 9)
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
	candidates(3,1) = string-1;
	candidates(3,2) = fret+4;
end
if string == 5 && fret > 8
	candidates(2,1) = string+1;
	candidates(2,2) = fret-5;
end 

if string == 6 && fret < 4 
	candidates(2,1) = string-1;
	candidates(2,2) = fret+5;
	candidates(3,1) = string-2;
	candidates(3,2) = fret+9;
end
if string == 6 && (fret > 3 && fret < 8) 
	candidates(2,1) = string-1;
	candidates(2,2) = fret+5;
end
% translate to MATLAB indexing>0
candidates(:,2)=candidates(:,2)+1;
candidates=candidates';
% sort string-wise ascending
[tmp,ndx] = sort(candidates(1,:));
candidates = candidates(:,ndx);

	    fretCandidates   = candidates(2,:)-1;
	    stringCandidates = candidates(1,:);
	    numCandidates = length(stringCandidates);
end