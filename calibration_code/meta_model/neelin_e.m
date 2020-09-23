function [metamodel intcontout nointp]=neelin_e(parameters, datamatrix, nl)

% Quadratic regression metamodel as described in Neelin et al. (2010) PNAS
% NAME 
%   neelin_f
% PURPOSE 
%   Estimate a mutlivariate quadratic metamodel which estimates quadratic
%   regressions in each parameter dimensions and computes interaction
%   terms for all pair of parameter experiments
% INPUTS 
%   From the structure parameters and datamatrix the following fields are
%   processed (mind the same naming in the input)
%  
%   parameters.experiments:
%
%            Parameter values for each experiment with the
%            dimension of [N, 2*N+N*(N-1)/2]
%            The structure NEEDS to be as follows
%            Example for 2 parameters (p1,p2)
%           
%            [p1_l dp2 ] ! Low parameter value for p1 default dp2
%            [p1_h dp2 ] ! High parameter value for p1 default dp2
%            [dp1  p2_l] ! Low parameter value for p2 default dp1
%            [dp1  p2_h] ! Hihg parameter value for p2 default dp1
%            [p1_l p2_h] ! Experiments with interaction (no default)
%                        ! Additional experiments used to
%                        constrain interaction terms
%   parameters.range:
%
%            Range of values for each paramter to normalize the
%            scale.
%
%   parameters.default:
%
%            Default values of parameters to center the scale
% 
%   datamatrix.moddata:
%           
%            Modeldata corresponding to the dimenoins of
%            parameter.experiments
%    
%   datamatrix.reffdata:
%
%            Modeldata of when using default parameter values to 
%            to center the datamatrix
%            fitted. Not needed if metamodel fits score data directly
% OUTUTS 
%   structure metamodel.
%   a: Metamodel parameter for linear terms [N,1]
%   B: Metamodel parameter for quadratic and interaction terms
%      [N,N]. Quadratic terms in the diagonal, interaction terms
%      in the off-diagonal. Matrix symetric, B(i,j)=B(j,i).
% HISTORY 
% First version: 11.10.2013
% AUTHOR  
%   Omar Bellprat (omar.bellprat@gmail.com)

%--------------------------------------------------------------------
% READ Input values from structures
%--------------------------------------------------------------------

N=length(parameters); % Number of model parameters
refp=parameters(1).default; % Default modelparameters
range={parameters.range}; % Parameter ranges

dm=2*N; % Number of experiments for one-dimensional quadratic regression
ds=2*N+N*(N-1)/2; % Number of experiments required to estimate the metamodel
di=N*(N-1)/2; % Number of all possible pairs

pmatrix=parameters(1).experiments;  % Parameter values 
dmat=datamatrix.moddata;

sd=size(dmat);

% Add zero as the reference
pmatrix(end+1,:)=zeros(1,N);
dmat(:,:,:,:,end+1)=zeros(sd(1:end-1));

sd=size(dmat);
dp=size(pmatrix); % Number of parameter experiments
nd=prod(sd(1:end-1)); % Number of datapoints 

% Liearize all dimensions 
refd=datamatrix.refdata(:);
nl=nl(:);
dvector=reshape(dmat,[prod(sd(1:end-1)),sd(end)]);

%--------------------------------------------------------------------
% ALLOCATE Output variables
%--------------------------------------------------------------------

metamodel=NaN;
dnoint=NaN;

%--------------------------------------------------------------------
% CHECK Input consistency
%--------------------------------------------------------------------

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

% Construct Neelin Model for polyfitn
modelterms=zeros(ds+1,N);
modelterms(1:N,1:N)=eye(N,N);
modelterms(N+1:2*N,1:N)=eye(N,N)*2;

ii1=sub2ind(size(modelterms),2*N+1:ds,pqn(:,1)');
ii2=sub2ind(size(modelterms),2*N+1:ds,pqn(:,2)');
modelterms(ii1)=1; modelterms(ii2)=1;

if dp(2)~=N
  error('Dimension of pmatrix does not correspond to number of parameters')
elseif dp(1)<dm
  error('Linear set of equations is underdetermined, parameter matrix too short')
elseif dp(1)>=dm && dp(1)<ds
  display(['Not enough experiments specified, interaction parameters not determined'])
elseif dp(1)>ds
  display(['Linear system of equations overdetermined, addtional experiments'...
           'used to constrain interaction terms unsing least-squares'])
end

% Check if default value is in the center of the parameter ranges
lwb=false(1,N);upb=false(1,N);

for i=1:N
  if sum(find(pmatrix(:,i)<refp(i)))==0
    lwb(i)=true;
    display(['Default of parameter ' parameters(i).name ...
	     ' is taken at the lower bound'])
  end
  if sum(find(pmatrix(:,i)>refp(i)))==0
    upb(i)=true;
    display(['Default of parameter ' parameters(i).name ...
             ' is taken at the upper bound'])
  end
end

% Normalize parameter values by the total range and center around
% default value

for i=1:N
  varp(i)=abs(diff(range{i}));
end

pmatrix=roundn((pmatrix-repmat(refp,[dp(1),1]))./repmat(varp,[dp(1),1]),-3);
dvector=dvector-repmat(refd,[1,sd(end)]);

%--------------------------------------------------------------------
% DETERMINE PARAMETERS FOR MULTIVARIATE QUADRATIC MODEL
%--------------------------------------------------------------------

a=zeros(nd,N,1); B=zeros(nd,N,N); c=zeros(nd,1,1);
metamodel=struct;

for i=1:nd % Estimate metamodel for each datapoint
  metamodel.fit{i}=polyfitn(pmatrix,dvector(i,:),modelterms);
  a(i,:,1)=metamodel.fit{i}.Coefficients(1:N);
  B(i,:,:)=diag(metamodel.fit{i}.Coefficients(N+1:2*N));
  for j=1:di
    B(i,pqn(j,1),pqn(j,2))=metamodel.fit{i}.Coefficients(dm+j);
  end
  c(i,1,1)=metamodel.fit{i}.Coefficients(end);
end 

metamodel.a=reshape(a,[sd(1:end-1),N]);
metamodel.B=reshape(B,[sd(1:end-1),N,N]);
metamodel.c=reshape(c,[sd(1:end-1)]);



