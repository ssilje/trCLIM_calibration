function exppattern(parameters,datamatrix)

% Plot routine to visualize experiments for a Neelin fit
% NAME 
%   exppattern
% PURPOSE 
%   Create mosaic plots for dimesensions simulation, region, and varable
% INPUTS 
%   From the structure datamatrix and paramters the
%   following fields are
%   processed (mind the same naming in the input)
%   
%   datamatrix.moddata:
%
%          Model data for all experiments
%
%   parameters.name: 
%
%          Name of parameter, parameter experiments
%
% OUTUTS 
%   Pcolor plots given the number of model variables
% HISTORY 
%   First version: 11.10.2013
% AUTHOR  
%   Omar Bellprat (omar.bellprat@gmail.com)
% NOTE 

%--------------------------------------------------------------------
% READ Input values from structures
%--------------------------------------------------------------------

N=length(parameters); % Number of model parameters
indv=datamatrix.variables{1};
ds=2*N; 
refd=datamatrix.refdata;
% Select all matrix dimensions if no score used
dd=ndims(datamatrix.refdata);
if dd>2
  for i=1:dd
    indd{i}=':';
  end
else
  indd=':';
end

diffref=repmat(refd,[ones(1,dd) ds]);
expdata=datamatrix.moddata(indd{:},1:ds)-diffref;
seassel=[12,1:2;3:5;6:8;9:11];
indc=find(size(refd)==12);

for k=1:4
 expdatas(k,:,:,:)=mean(mean(expdata(:,seassel(k,:),:,:,:),2),1);
end

climits=[-1.5 1.5;-1 1;-15 15];

seasons={'DJF','MAM','JJA','SON'};

prd=([206 81 77]-50)./255;
pbd=([184 210 237]-100)./255;
regname={'BI';'IP';'FR';'ME';'SC';'AL';'MD';'EA'};
hotcold=[linspace(pbd(1),1,100)' linspace(pbd(2),1,100)' linspace(pbd(3),1,100)';...
         linspace(1,prd(1),100)' linspace(1,prd(2),100)' linspace(1,prd(3),100)'];

names={parameters.name_tex};

for i=1:N
  pnames{1+(i-1)*2}=[names{i} '_l'];
  pnames{i*2}=[names{i} '_h'];
end

for i=1:4
  for j=1:3
    figure;
    axes('Position',[0.25 .1 .65 .8])
    tmp=zeros(ds+1,9);
    size(expdatas)
    tmp(end-1:-1:1,end-1:-1:1)=squeeze(expdatas(i,:,j,:))'
    pcolor(tmp)
    colormap(hotcold)
    colorbar
    set(gca,'XTick',[1.5:8.5],'XTickLabel',regname)
    set(gca,'YTick',[1.5:2*N+.5])
    set(gca,'Fontsize',14)
    
    [hx,hy] = format_ticks(gca,regname, pnames(end:-1:1),[1.5:8.5],[1.5:2*N+.5],[0],[45],[],'FontSize',14);
    caxis(climits(j,:))
    title([char(datamatrix.variables{j+1}) ' / ' seasons{i}],'Fontsize',18)
    set(gcf,'PaperPosition',[2 2 6 9])
    print('-f1','-depsc',['exppattern_',seasons{i},'_',num2str(j)])
    close
  end
end
