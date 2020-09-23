% Master file for CCLM calibration suite eample for documentation
% on methodology
% NAME
%   calmo.m
% PURPOSE
%   Definitions for calibration, I/O of data, calling routines
% HISTORY
%   First version: 11.10.2013
% AUTHOR
%   Omar Bellprat (omar.bellprat@gmail.com)

% Three data structures are defined:
%
% - Parameters: Contains all default parameter information
%               and settings of experiments
%
% - Datamatrix: Contains all data of experiments and validation
%               runs. Defines if a score is computed out of the
%               data or if directly a score is read
%
% - Metamodel:  Contains the metamodel parameters which are fitted
%
%
%  This script you run to get the OPT set of parameters. When you hav got
%  the OPT set of parameters, you run the calibrate_master_OPT.m script
%
%
%--------------------------------------------------------------------
% DEFINE Calibration structures (Parameters,Datamatrix,Metamodel)
%--------------------------------------------------------------------

clear all; close all;
% Add polyfitn library
addpath('PolyfitnTools')

% To run the testcase with the data that already exist, you can load this
% file:
OPT_matfile='/hymet/ssilje/cosmopompa_calibration/meta_model/data/opt_5.mat';
% Remember to set optrun=true; 

% Otherwise, you first have to run with optrun=false; to get the OPT
% parameters. Make sure you're saving the run with you OPT-parameters OPT_matfile='calibration_OPT_';
% When you have done the simulation, you set optrun=true; and load the
% correct OPT_matfile. 

optrun=true; % only set this to true if you are running after having the OPT run
%optrun=false; % only set this to true if you are running after having the OPT run

%OPT_matfile='calibration_OPT_';
% If you want to run the calibration several times to get differnet
% sets of OPT parameters
ntimes_opt=1; % number of times to run the calibration. It can be good to do this several times

% file with constants for the simlations. Needs to be set depending on
% the experiemntal design
const_param;

parameters=struct('name',paramn,'range',range','default',default,'name_tex',paramnt);

expval=create_neelin_exp(parameters); % Experiment values to fit metamodel

parameters=struct('name',paramn,'range',range','default',default,'experiments', ...
    expval,'name_tex',paramnt,'validation',valdata');

load('stddata_2000-2009.mat');
iv=iv_n; stdobs=stdobs_n; err=err_n;

%% Description see Bellprat et al. 2012
% iv: std of ensemble of five initial pertubations
% stdobs:interannual std for the reference obs
% err: std for three different obs dataset
%%

% If only the last five years are used in the calibration

iv=iv(nyearstart:nyearend,:,:,:); stdobs=stdobs(nyearstart:nyearend,:,:,:); err=err(nyearstart:nyearend,:,:,:);

stddata=sqrt(err.^2+iv.^2+stdobs.^2);

% Define Datamatrix

moddata=[];
valdata=[];
obsdata=[];
refdata=[];
variables={4,'T2M','PR','CLCT'}; % Index of variables in moddata,
% and name of each model variable
% if no score data used
scoren='ps'; % If scoren [], no computation of score assumed
% and data values corresponding to score values

datamatrix=struct('moddata',moddata,'refdata',refdata,'valdata',valdata,'obsdata', obsdata,'stddata',stddata,'score',scoren);

%-----------------------------------------------------------------
% READ DATA
%-----------------------------------------------------------------

read_data;
datamatrix.moddata=moddata; datamatrix.refdata=refdata; datamatrix.obsdata=obsdata;
datamatrix.valdata=valdata;

datamatrix.variables={4,'T2M [K]','PR [mm/day]','CLCT [%]'};

if optrun
    datamatrix.optdata=optdata;
    eval(['load ' OPT_matfile ';' ])
    histplot_opt(lhscore,datamatrix)
    
else
    
    for teller_opt=1:ntimes_opt
        %-----------------------------------------------------------------
        % FIT METAMODEL
        %-----------------------------------------------------------------
        %
        % in the code-package there are two methods to fit the metamodel
        % (neelin_e_analytic and neelin_e). They give slightly different
        % results, and it is not quite clear. For the calibration performed by
        % Omar, he used the neelin_e_analytic, but in the CALMO-max they
        % use the neelin_e method
        %
        %
        
        % (1) Method Neelin to estimate MetaModel
        
        metamodel=neelin_e_analytic(parameters,datamatrix,iv);
        
        % (2) Method CALMO to estimate MetaModel
        %
        
        %metamodel=neelin_e(parameters,datamatrix,iv);
        
        %-----------------------------------------------------------------
        % VALIDATION METRICS
        %-----------------------------------------------------------------
        
        % The fitted metamodel is analysed in terms of accuracy and non-linearity
        % Different functions can be used for this purpose as described in
        % Bellprat et al. (2012) JGR.
        
        %% (1) Estimate the error of independent simulations and plot scattorplots
        %%
        
        % [errstd]=errmeta(metamodel,parameters,datamatrix);
        
        %% (2) Visualize mean metamodel parameters for linear, quadratic and
        %%     interaction terms
        
        %metaparam(metamodel,parameters,datamatrix);
        
        %% (3) Visualize performance landscape for each parameter pair
        %%     between all experiments
        
        % planes(metamodel,parameters,datamatrix);
        
        
        %% (4) Plot routine to visualize experiments for a Neelin fit
        %%
        %  exppattern(parameters,datamatrix)
        %
        %-----------------------------------------------------------------
        % OPTIMIZATION OF PARAMETERS
        %-----------------------------------------------------------------
        
        % The validated metamodel can now be used to find optimal parameter
        % values and to perform a perfect model experiment.
        
        % (1) Find optimal model parameters using a latin hypercube
        % optimisation
        
        %lhacc=3000000;
        lhacc=30000;
        % Number of experiments to sample parameter space, for
        % means of speed a low number of parameter combinations
        % is used.
        
        
        
        % lhscore: Modelscore for all experiments;
        % lhexp: Latin hypercube parameter experiments
        % popt: Parameter setting with highest score
        
        [lhscore lhexp popt]=lhopt(metamodel,parameters,datamatrix,lhacc);
        
        %% (5) Plot performance range covered  by the metamodel and compare to
        %% reference simulation
        
        histplot(lhscore,datamatrix)
        
        %% (6) Plot optimised parameter distributions
        errm=0.015; % Uncertainty of the metamodel, is currently set from
        % experience, needs to be computed from error of
        % independent simulations
        
        % optparam(parameters,lhscore,lhexp,popt,errm)
        
   
        eval(['save data/' OPT_matfile '_' num2str(teller_opt) '.mat lhexp lhscore metamodel popt'])
    end
end