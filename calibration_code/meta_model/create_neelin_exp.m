function paramlist=create_neelin_exp(parameters)

% Creates parameter list and writes into a text file for a neelin calibration
% NAME 
%   calmo.m
% PURPOSE 
%   Definitions for calibration, I/O of data, calling routines
% HISTORY 
%   First version: 11.10.2013
% AUTHOR  
%   Omar Bellprat (omar.bellprat@gmail.com)


range={parameters.range}; % Parameter ranges
N=length(parameters); % Number of model parameters
refp=parameters(1).default; % Default modelparameters

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

ds=2*N+4*N*(N-1)/2;

paramlist=repmat(refp,[ds 1]);

for i=1:N
  paramlist((i-1)*2+1,i)=range{i}(1);
  paramlist((i-1)*2+2,i)=range{i}(2);
end

for i=1:length(pqn)
  % Minimum / Minimum
  paramlist(2*N+(i-1)*4+1,pqn(i,1))=range{pqn(i,1)}(1);
  paramlist(2*N+(i-1)*4+1,pqn(i,2))=range{pqn(i,2)}(1);
  
  % Minimum / Maximum
  paramlist(2*N+(i-1)*4+2,pqn(i,1))=range{pqn(i,1)}(1);
  paramlist(2*N+(i-1)*4+2,pqn(i,2))=range{pqn(i,2)}(2);
  
  % Maximum / Minimum
  paramlist(2*N+(i-1)*4+3,pqn(i,1))=range{pqn(i,1)}(2);
  paramlist(2*N+(i-1)*4+3,pqn(i,2))=range{pqn(i,2)}(1);
  
  % Maximum / Maximum
  paramlist(2*N+(i-1)*4+4,pqn(i,1))=range{pqn(i,1)}(2);
  paramlist(2*N+(i-1)*4+4,pqn(i,2))=range{pqn(i,2)}(2);
end

dlmwrite('paramlist.txt',paramlist,'\t')
