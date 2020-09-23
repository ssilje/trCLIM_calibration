function moddata = read_model(expname)

const_param;

varn={'T_2M','TOT_PREC','CLCT'};
varf={'t2m','rr','clct'};

exppath=[simdir,expname,'/'];
% dim [year month regions variables]
moddata=NaN(nyear,12,8,3);



for ii=1:3
    for r=1:8
        moddat=ncread([exppath,varf{ii},'_mod_',num2str(r),'.nc'],varn{ii});
        %      if length(moddat) > 120
        if length(moddat) > nmonths
            display(['Too much data for ', expname, ' variable ', varf{ii}])
            %      elseif  length(moddat) < 120
            length(moddat)
        elseif  length(moddat) < nmonths
            display(['Too little data for ', expname, ' variable ', varf{ii}])
            length(moddat)
        end
        moddata(:,:,r,ii)=reshape(moddat(1,1,1:nmonths),12,nyear)';
    end
end
moddata(:,:,:,1)=moddata(:,:,:,1)-273.15;
moddata(:,:,:,3)=moddata(:,:,:,3)*100;
end


