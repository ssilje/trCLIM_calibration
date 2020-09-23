function [PSopt xstar xopt]=lhopt(metamodel,parameters,datamatrix,lhacc)

% Optimise model parameters using a latin hypercube sampling 
% NAME 
%   neelin_p
% PURPOSE 
%   Create a sample of parameters using a latin hypercube design
%   and predict the model performance of the sample using the
%   metamodel.
% INPUTS 
%   From the structure metamodel, parameters and datamatrix the following fields are
%   processed (mind the same naming in the input)
%   
%   metamodel.a:
%
%          Vector of linear terms of the metamodel [...,N,1] additional
%          data dimensions possible (ex:a~[Regions,Variables,Time,N,1])
%
%   metamodel.B: 
%
%           Matrix of quadratic and interactions terms [...,N,N] additional
%           data dimensions possible (ex:a~[Regions,Variables,Time,N,N])
%
%   parameters.range:
%
%            Range of values for each paramter to normalize the
%            scale.
%
%   parameters.default:
%
%            Default values of parameters to center the scale
%
%   datamatrix.reffdata:
%
%            Modeldata of when using default parameter values to 
%            to center the datamatrix
%
%   pvector: Parameter values for one experiment with the
%            dimension of [N,1] N=Number parameters
% OUTUTS 
%   dmatrix: Predicted data for parameter experiment
% HISTORY 
% First version: 11.10.2013
% AUTHOR  
%   Omar Bellprat (omar.bellprat@gmail.com)
% NOTE 
% Currently routine does only allow to compute one experiment at
% the time, could possibly changed by adapting matrix operations.



%--------------------------------------------------------------------
% READ Input values from structures
%--------------------------------------------------------------------

N=length(parameters); % Number of model parameters
refp=parameters(1).default; % Default modelparameters
range={parameters.range}; % Parameter ranges
refd=datamatrix.refdata; % Reference data
sd=size(datamatrix.refdata);
pmatrix=parameters(1).experiments;
obsdata=datamatrix.obsdata;
stddata=datamatrix.stddata;

%--------------------------------------------------------------------
% CREATE Latin Hypercube design
%--------------------------------------------------------------------

for i=1:N
  UB(i)=range{i}(2);
  LB(i)=range{i}(1);
end

lh=lhsdesign(lhacc,N,'criterion','correlation');
xstar=repmat(LB,[lhacc,1])+lh.*repmat((UB-LB),[lhacc,1]);


%--------------------------------------------------------------------
% PREDICT Performance of all experiments
%--------------------------------------------------------------------

%Timing variables
tic
cnt2=0;
cnt=0;
st=1000;

for p=1:length(xstar)
    qfit=neelin_p(metamodel,parameters,datamatrix,xstar(p,:));
    if strcmp(datamatrix.score,'ps')==1
      [dum ps]=pscalc(qfit,obsdata,stddata);
      PSopt(p)=ps;
    end

    %Timing code
    cnt=cnt+1;
    if cnt==st
      cnt2=cnt+cnt2;
      cnt3=length(xstar)-cnt2;
      cnt=0;
      t(cnt2/st)=toc/cnt2*st;
      display([ num2str(cnt3) ' parameter sets operations left']);
      display(['Approximately ' num2str(round(cnt3*mean(t)/st)) ' seconds left']);
    end
end


%--------------------------------------------------------------------
% FIND Best parameter set
%--------------------------------------------------------------------

xopt=xstar(find(PSopt==max(PSopt)),:);

save('data/all_data_mult')
