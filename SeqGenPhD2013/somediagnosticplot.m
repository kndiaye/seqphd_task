%% 3. make some plots %%%%%%%%%%%%%%%%%%%%%%%%%

%    close all
%     figure, hist(dev, 400);
%     figure, hist(stddev, 400);
%     figure, plot(sort(dev));
%     figure, plot(sort(stddev));     
%     figure, hist(dev./(prop.*stddev), 400);
    
    [val, idx] = sort(dev./(stddev.*prop));           
    figure('Color', ones(3,1)), plot(dev, stddev, '.'); hold on;
    plot(dev(idx(1:NExperience)), stddev(idx(1:NExperience)), 'ro:');
    xlabel('uniformness')
    ylabel('spread')
    
    idx= idx(20);    
    
    y = sequencepred(emory(idx,:), 1:SeqLength);
    figure, hist(y(:), 100);
    xlim([-3.5 1.5])
    ylim([0 50])
    %figure, plot(y');

%% figure: probabilité en fonction N trial
Nxp=1;
figure('Color', ones(1,3));
x=[]; for i=1:8; x = cat(2, x, [Experience(Nxp).IdealSurp(i).Stim.All]); end
x = 2.^-x;
dot = mean(x');
errdot = std(x');
errorfill(1, dot, errdot);
xlabel('trial #')
ylabel('marginal proba')

%% figure: predicitibilité en fonction N trial
Nxp=1;
figure('Color', ones(1,3));
x=[]; for i=1:8; x = cat(1, x, [Experience(Nxp).IdealPred(i).Stim.Actual]); end
dot = mean(x);
errdot = std(x);
errorfill(1, dot, errdot);
xlabel('trial #')
ylabel('predictive info (bits)')

%% figure: proba predict <=0 en fonction N trial
Nxp=10;
figure('Color', ones(1,3));
hold on
x=[]; for i=1:8; x = cat(1, x, [Experience(Nxp).IdealPred(i).Stim.Actual]); end
dot = mean(x>0);
errdot = std(x>0);
errorfill(1, dot, errdot);
line(xlim, mean(dot(end-20:end)))
ylim([0 1]);
xlabel('trial #')
ylabel('proba pred pos(bits)')
text(10, 0.1, sprintf('Prop neg pred %d', sum(x(:)<=0)/numel(x)));

%% figure: Contextual Entropy en fonction N trial
Nxp=10;
figure('Color', ones(1,3));
x=[]; for i=1:8; x = cat(2, x, [Experience(Nxp).IdealCtxtEntropy{i}]); end
dot = mean(x');
errdot = std(x');
errorfill(1, dot, errdot);
xlabel('trial #')
ylabel('Context Entropy (bits)')

%% figure: Ctxt Entropy against predictability
Nxp=1;
figure('Color', ones(1,3));
x=[]; for i=1:8; x = cat(1, x, [Experience(Nxp).IdealCtxtEntropy{i}]); end
x = x';
y=[]; for i=1:8; y = cat(2, y, [Experience(Nxp).IdealPred(i).Stim.Actual]); end
plot(y,x, 'o')
xlabel('predictability (bits)')
ylabel('Context Entropy (bits)')
%%
figure('Color', ones(1,3));
hist(x(x<1), 100)
xlabel('contextual entropy (bit)');
%%
figure('Color', ones(1,3));
hist(y(:), 100)
xlabel('predictability (bit)');
hold on
p = prctile(y(:), [25 50 75]);
line(ones(3,2).*repmat(p', 1, 2), ylim, 'Color', [1 0 0], 'LineWidth', 2)
