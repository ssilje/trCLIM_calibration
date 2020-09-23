function histplot(lhscore,datamatrix)  

%   Plot full performance range sampled with the latin hypercube
%   experiment as a histogramm
% NAME 
%   neelin_p
% PURPOSE 
%   Predict data using the metamodel for a parameter matrix
% INPUTS 
%   From the structure metamodel, parameters and datamatrix the following fields are
%   processed (mind the same naming in the input)
%   
%   datamatrix.reffdata:
%            
%            Modeldata using default parameter settings to
%            determine/compute the model score of the reference
% OUTUTS 
%   Plot: Histogram plot 
% HISTORY 
% First version: 11.10.2013
% AUTHOR  
%   Omar Bellprat (omar.bellprat@gmail.com)


%--------------------------------------------------------------------
% READ Input values from structures
%--------------------------------------------------------------------

obsdata=datamatrix.obsdata;
stddata=datamatrix.stddata;
refd=datamatrix.refdata; % Reference data
optd=datamatrix.optdata;

%--------------------------------------------------------------------
% DETERMINE/COMPUTE Score of the reference simulation
%--------------------------------------------------------------------

if datamatrix.score
  [pi PSref]=pscalc(refd,obsdata,stddata);
  [pi PSopt]=pscalc(optd,obsdata,stddata);
else
  PSref=refd;
end



%--------------------------------------------------------------------
% DEFINE Additional needed vectors
%--------------------------------------------------------------------

% New colors
pr=([206 81 77])./255; 
pb=([184 210 237])./255;
  

%--------------------------------------------------------------------
% PLOT Metamodel range
%-------------------------------------------------------------------- 

figure;
[hi hx]=hist(lhscore,200);
hi=hi/sum(hi);
fhy=[hi,zeros(1,length(hi))];
fhx=[hx,flipdim(hx,2)];
hhi=fill(fhx,fhy,pb, 'EdgeColor',pb,'Linewidth',2);
hold on
lht=max(hi);
href=plot(ones(1,100)*PSref,linspace(0,lht,100),'Linewidth',2,'color','k');
text(PSref,lht+0.0005,'REF','Rotation',90,'Fontsize',12);
hopt=plot(ones(1,100)*PSopt,linspace(0,lht,100),'Linewidth',2,'color','r');
text(PSopt,lht+0.0005,'OPT','Rotation',90,'Fontsize',12);
set(gca,'Fontsize',18,'YTick',[],'Layer','top','Box','on','TickDir','in', 'Linewidth',1)
ylabel('Relative densitiy','Fontsize',18)
xlabel('Score','Fontsize',18)
title('Objective calibration','Fontsize',18)
ylim([0 lht+.004])
xlim([0 1])
%hl=legend([href,hhi],'Rerefence','Metamodel Range',2)    
%set(hl,'Box','off')
set(gcf,'Paperposition',[1 1 10 3])
set(gcf, 'Renderer', 'painters')
print('-f1','-depsc','histplot')


