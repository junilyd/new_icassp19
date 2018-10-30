
%%
E = 82.41312312343412341234231;

stringFrequencies = [E E*2^(5/12) E*2^(10/12) E*2^(15/12) E*2^(19/12) E*2^(24/12)]';
equally_tempered_Matrix = stringFrequencies*2.^([0:12]/12);

observed_f0 = ((540-82))*rand+82
observed_f0/E
%%
F=1./(abs((equally_tempered_Matrix-observed_f0)).^(100));

prior = F./sum(sum(F));


figure(1); 
surf(prior);
xlabel('Fret index');
ylabel('String index');
zlabel('P(\gamma_k)');

figure(2); 
surf(log2(prior));
xlabel('Fret index');
ylabel('String index');
zlabel('ln P(\gamma_k)');