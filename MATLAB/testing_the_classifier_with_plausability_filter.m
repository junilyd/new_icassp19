clear all;
addpath(genpath('util'));
mirverbose(0);
addpath mats;

guitarTypes={'martin','firebird'};%{'firebird','martin'};
for ii = 1:2
   guitarType = char(guitarTypes(ii))

%addpath ~/repositories/guitar_string_finger_and_pluck_estimation/util/smc_lib
addpath ~/repositories/guitar_string_finger_and_pluck_estimation/util/inharmonicity/performance_test

% nFFT=2^19;
% betaRes=1e-7;

for trainingFret = 0:12

strings=1:6;
fretIndex = 0:12;
testFrets = setdiff((fretIndex),trainingFret);

% load training File
%fileName = strcat(sprintf('~/repositories/guitar_string_finger_and_pluck_estimation/mats/betaMean'),guitarType,sprintf('_40ms_from_%1.0fth_fret_betares%1.2fu_nFFT2^%1.0f.mat',trainingFret,betaRes*1e6,log2(nFFT)));
fileName = strcat(sprintf('trained_model_of_firebird_from_%1.0fth_fret',trainingFret));
load(fileName)
clear pitchEstimate BEstimate fretEstimate stringEstimate;
% Figure out something else...
%EStringTuning = est_f0(1);

% LOpen=64.3;
% muModel = mu;
% [mu]  = [muModel].*[normalizationConstant];
% mu(:,1) = log(mu(:,1));
% mu(:,2) = log((mu(:,2).^(1/2)));
% normalizationConstantClassifier = [max(abs(mu))];
% mu = mu./normalizationConstantClassifier;

testDirs =dir(strcat('~/Dropbox/pluck_position/testfiles/',guitarType,'*'));
numTestDirs=size(testDirs,1);

errorMatrix = zeros(6,13,numTestDirs);
runs = 1;
errorCounter = 0;
stringEstimate=zeros(length(strings),length(fretIndex),numTestDirs);
fretEstimate=zeros(length(strings),length(testFrets),numTestDirs);
%pluckCmFromBridge=zeros(length(strings),length(fretIndex),numTestDirs);

for recDir=1:numTestDirs
for trueString = strings
for trueFret = testFrets
    fretNdx=trueFret+1;
    %recording = strcat(testDirs(recDir).folder,'/',testDirs(recDir).name,'/','string',mat2str(trueString),'/',mat2str(trueFret),'.wav' );
    %recording
    recordingPath = strcat('~/Dropbox/pluck_position/testfiles/',guitarType,num2str(recDir),'/string',num2str(trueString),'/',num2str(trueFret),'.wav');
    [recording,fs] = audioread(recordingPath);
    recording=recording./max(abs(recording));
    [sig] = icassp19_segment_from_all_onsets(recording,fs,segmentDuration);
    % Hilbert transform and windowing
    x = icassp19_hilbert_transform(sig);
    x = icassp19_apply_gaussian_window(x);            
    %% Feature extraction with the inharmonic pitch estimator
    % The implementation of Eq. (17) is done with one FFT, since it is fast
    % Hence, it is equivalent to harmonic summation which the in the proposed 
    % method is extended to inharmonic summation.
    % See details on harmonic summation in Christensen and Jakobsson [27].
    [~,X] = icassp19_fft(x, fs, nFFT);
    omega0Initial = icassp19_harmonic_summation(X, f0Limits, MInitial, fs);
    %M = min(54,floor(fs/2/omega0Initial));
    [pitchEstimate(trueString,fretNdx,recDir), BEstimate(trueString,fretNdx,recDir)] ...
    = icassp19_inharmonic_summation(X, omega0Initial, M, fs, BSearchGrid,nFFT) ;

    phi = [(pitchEstimate(trueString,fretNdx,recDir)) (BEstimate(trueString,fretNdx,recDir))]./normalizationConstant;

    %% Classifation of String and Fret (maximum likelihood w. uniform prior)
    % with plausability filter (see Abesser et al. [7])
    [sC, fC] = icassp19_obtain_pitch_candidates(pitchEstimate(trueString,fretNdx,recDir),pitchModelOriginalUnits');
    ndx = (sC*13)-12+fC;
    euclideanDistance   =  sqrt( (log(phi(:,1))-log(mu([ndx],1))).^2 + (phi(:,2)-mu([ndx],2)).^2 );
    [C,I] = min(euclideanDistance);
    stringEstimate(trueString,fretNdx,recDir) = sC(I);
    fretEstimate(trueString,fretNdx,recDir) = fC(I);

% without plausability filtering
%     euclideanDistance   =  sqrt( (log(phi(:,1))-log(mu(:,1))).^2 + (phi(:,2)-mu(:,2)).^2 );
%     [C,I] = min(euclideanDistance);
%     fretEstimate(trueString,fretNdx,recDir) = mod(I,13)-1; % <-- due to a matrix structure (13x6)
%     stringEstimate(trueString,fretNdx,recDir) = floor((I+13)/13);
% 
%     if fretEstimate(trueString,fretNdx,recDir) == -1, 
%         fretEstimate(trueString,fretNdx,recDir)=fretOptions(end-1); 
%         stringEstimate(trueString,fretNdx,recDir)=stringEstimate(trueString,fretNdx,recDir)-1;
%     end
%sprintf('\n est string: %1.0f (%1.0f) ',stringEstimate(trueString,fretNdx,recDir),trueString)
%sprintf('\n est fret  : %1.0f (%1.0f) ',fretEstimate(trueString,fretNdx,recDir),trueFret)

    %% Estimate the amplitudes (alpha vector)
   % Z = icassp19_Z(pitchEstimate(trueString,fretNdx,recDir),length(x),fs,M,BEstimate(trueString,fretNdx,recDir));
   % alpha = inv(Z'*Z)*Z'*x;
   % amplitudesAbs = abs(alpha)'; % absolute values for the estimator

    %% Plucking Position Estimator (minimizer of log spectral distance)
    %L = LOpen * 2^(-fretEstimate(trueString,fretNdx,recDir)/12); %
    %[pluckCmFromBridge(trueString,fretNdx,recDir)] = icasssp19_plucking_position_estimator_LSD(amplitudesAbs,L);% icasssp19_plucking_position_estimator_LSD


    % extract 40ms from onset.
    %x=x/max(abs(x));
    %[x] = pluck_position_segment_from_all_onsets(x,fs,40e-3);
    
% 
%     [stringEstimate(trueString,fretNdx,recDir), fretEstimate(trueString,fretNdx,recDir), BEstimate(trueString,fretNdx,recDir), f0_HS(trueString,fretNdx,recDir), f0_iHS(trueString,fretNdx,recDir), fAxis, XplotdB, Xlin,L_iHS] = ...
%     smc_string_and_fret_classifier(x, EStringTuning, fs, betaModelApproximation,betaRes, nFFT);
%     
    % move this one to /util
    [errorMatrix(:,:,recDir), errorCounter] = ...
        icassp19_count_and_localize_errors(trueString, trueFret, stringEstimate(trueString,fretNdx,recDir), fretEstimate(trueString,fretNdx,recDir), errorMatrix(:,:,recDir), errorCounter);

    errorRate = errorCounter/runs;
    runs = runs + 1;
    
    % plucking position
   % Z = smc_Z_inharmonic(f0_iHS(trueString,fretNdx,recDir),length(x),fs,L_iHS,BEstimate(trueString,fretNdx,recDir)); % L_iHs was 13.
   % amplitudes = inv(Z'*Z)*Z'*smc_hilbert(x);
    %amplitudes = (amplitudes/max(amplitudes))';
   % [pluckCmFromBridge(trueString,fretNdx,recDir)] = ...
   %     smc_minimize_ideal_amplitudes(amplitudes,64*2^(-fretEstimate(trueString,fretNdx,recDir)/12));
end
end
end

%% make confusion matrix for strings
es=reshape(stringEstimate, numTestDirs*(length(testFrets)+1)*length(strings),1)';
es(es==0)=[];
es=reshape(es,6,numTestDirs*(length(testFrets)))';

for string=strings
confMatStrings(string,:) =[ sum(es(:,string)==1) sum(es(:,string)==2) sum(es(:,string)==3) sum(es(:,string)==4) sum(es(:,string)==5) sum(es(:,string)==6)]/(size(es,1))*100;
end

    print_matrix(confMatStrings,'Confusion Matrix');

    outputFileName = strcat(sprintf('~/repositories/guitar_string_finger_and_pluck_estimation/icassp_plucking_estimation/MATLAB/mats/results_BFretModel'),guitarType,sprintf('_40ms_from_%1.0fth_fret_betares%1.2fu_nFFT2^%1.0f.mat',trainingFret,betaRes*1e6,log2(nFFT)));

    save(outputFileName);
end
end