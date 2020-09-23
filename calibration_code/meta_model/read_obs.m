function obsdata = read_obs(obsname)
const_param;

varn={'tg','rr','cld'};
varf={'t2m','rr','clct'};
exppath=obsdir;

%[dim year month regions variables]
obsdata=NaN(nyear,12,8,3);

for ii=1:3
    for r=1:8
        dat=ncread([exppath,varf{ii},'_',num2str(r),'.nc'],varn{ii});
        if (ii==3  && strcmp(obsname,'observations_alt2'))
            dat2=NaN(1,1,120);
            dat2(1,1,3:120)=dat;
            dat=dat2;
        elseif (ii==3  && strcmp(obsname,'observations_alt3'))
            dat2=NaN(1,1,120);
            dat2(1,1,1:107)=dat;
            dat=dat2;
        end
        obsdata(:,:,r,ii)=reshape(dat,12,nyear)';
    end
end
end



