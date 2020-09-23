function optparam(parameters,lhscore,lhexp,popt,errm)  

%   Plot posterior parameter distributions given the uncertainty of
%   the metamodel prescribed in errm
% NAME 
%   optparam
% PURPOSE 
%   Plot parameter distributions which lead to best model results
%   given the uncertainty of the metamodel
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

N=length(parameters);
range={parameters.range}; % Parameter ranges

%--------------------------------------------------------------------
% DEFINE Additional needed vectors
%--------------------------------------------------------------------

% New colors
pr=([206 81 77])./255; 
pb=([184 210 237])./255;
pbd=([184 210 237]-100)./255;
prd=([206 81 77]-50)./255;


% Compute index vector for all possible pairs
pqn=allcomb(1:N,1:N);
cnt=1;
for i=1:length(pqn)
  if pqn(i,1)>=pqn(i,2)
   cind(cnt)=i;
   cnt=cnt+1;
  end
end
pqn(cind,:)=[];

%--------------------------------------------------------------------
% FIND Parameter combination that lead to best model results
%--------------------------------------------------------------------

poptr=lhexp(find(lhscore>max(lhscore)-errm),:);

% find optimal parameter configuration closest to highest densitiy

% for i=1:N
% prange=linspace(range{i}(1),range{i}(2),25);
% hh=hist(poptr(:,i),prange);
% [d ind]=max(hh);
% pk(i)=range{i}(1)+(range{i}(2)-range{i}(1))/25*ind;
%end
%
%for i=1:N
%  for j=1:length(poptr)
%    ds(j)=sqrt(sum((poptr(j,i)-pk(i)).^2/var(range{i})));
%  end
%end

%[d ind]=min(ds);
%popt=poptr(ind,:);
%popt=pk;

figure;
for i=1:N
  subplot(2,N/2,i);
  prange=linspace(range{i}(1),range{i}(2),25);
  hh=hist(poptr(:,i),prange);
  bar(prange,hh,'FaceColor',pb,'EdgeColor',pb);
  [d ind]=max(hh);
  pk(i)=range{i}(2)+(range{i}(2)-range{i}(1))/25*ind;
  hold on
  title(char(parameters(i).name_tex),'Fontsize',16)
  rp=abs(range{i}(2)-range{i}(1));
  xlim([range{i}(1)-rp*0.1 range{i}(2)+rp*0.1]);

  if i==1
    ylabel('Density','Fontsize',16)
  end
  
  ylims=get(gca,'Ylim');
  
  if i==1
    ylim2=ylims(2);
  end
  
  ylims(2)=ylim2;
  set(gca,'Ylim',ylims);
 
  hb1=plot(ones(1,100)*range{i}(1),linspace(0,ylims(2),100),'color',pbd, ...
       'Linewidth',2);
  plot(ones(1,100)*range{i}(2),linspace(0,ylims(2),100),'color',pbd, ...
       'Linewidth',2);
  [d ind]=max(hh);

  hr=plot(ones(1,100)*parameters(1).default(i),linspace(0,ylims(2),100),'color',pr,'Linewidth',2);

  hopt=plot(ones(1,100)*popt(i),linspace(0,ylims(2),100),'k--','Linewidth',2);
 
  if i==1
    %hl=legend([hb1,hr,hopt],'Parameter range','Default values',...
	      %'Optimal values',2);
%    set(hl,'Box','off','Fontsize',16)
  end
  clear ylims; 
end

set(gcf,'PaperPosition',[1 1 10 4]);
print('-f1','-depsc','optparam');


