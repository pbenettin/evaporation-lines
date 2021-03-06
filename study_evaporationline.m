% code to explore the isotopic composition of evaporating water volumes
% according to the Craig-Goron (1965) model. References at the bottom of
% the file. 
% Paolo Benettin, January 2018

clc
clear variables
close all


% code organization:
% 1-case of a single evaporating water volume, following Gonfiantini 1986, pp. 117-118
start_evaporatingvolume=1; %flag to run this part of code

% 2-multiple water volumes undergoing seasonal input and evaporation variability
start_seasonaldynamics=1;  %flag to run this part of code



%--------------------------------------------------------------------------
% notation
%--------------------------------------------------------------------------
% dl: isotopic composition of the residual liquid (sometimes referred to as dS)
% dS: isotopic composition of the residual liquid (sometimes referred to as dl)
% da: isotopic composition of the ambient athmospheric vapor (atmospheric moisture)
% dE: isotopic composition of the evaporating flux
% alphae: fractionation factor at equilibrium (Rliq/Rvap)
% epse=alphae-1: equilibrium fractionation factor (expressed in permil)
% epsk: kinetic fractionation factor (expressed in permil) 
% Tc: Temperature [degree Celsius]
% Tk: Temperature [Kelvin]
% hm: relative humidity [-]
% n: aerodinamic regime parameter [-]
% theta: weight term for cases when da is influenced by dE [-]
% x: ratio evaporation/precipitation [-] or cumulative evaporation/initial volume

%--------------------------------------------------------------------------
% 1 - evaporating water volume (mostly following Gonfiantini 1986)
%--------------------------------------------------------------------------
if start_evaporatingvolume==1

% set the main PARAMETERS

% choose input isotopic composition
dp_H=-38; %example value from Gonfiantini 1986
dp_O=-6; %example value from Gonfiantini 1986

% set temperatures and relative humidity 
Tc=20; %air temperature [deg C]
hm=0.75; %relative humidity of the atmosphere [-]

% set kinetic fractionation parameter n (approach by Horita et al. 2008)
n=0.75; %n=1 for dry soils, n=0.5 for lakes and saturated soils


% implement main EQUATIONS

% get equilibrium fractionation factors from Horita and Wesolowski
Tk=Tc+273.15;
alphae_H=exp(1/1000.*(1158.8*Tk.^3/10^9-1620.1*Tk.^2/10^6+...
    794.84*Tk./10^3-161.04+2.9992*10^9./Tk.^3)); %Horita and Wesolowski (1994) 
alphae_O=exp(1/1000.*(-7.685+6.7123*10^3./Tk-1.6664*10^6./Tk.^2+...
    0.3504*10^9./Tk.^3)); %Horita and Wesolowski (1994) 
epse_H=(alphae_H-1)*1000; %permil notation
epse_O=(alphae_O-1)*1000; %permil notation

% get kinetic fractionation factors
epsk_H=n*(1-hm)*(1-0.9755)*1000; %0.9755 value from Merlivat (1978) %permil notation
epsk_O=n*(1-hm)*(1-0.9723)*1000; %0.9723 from Merlivat (1978) %permil notation

% get atmospheric composition from precipitation-equilibrium assumption (Gibson et al., 2008)
k=1; %seasonality factor 
da_H=(dp_H-k*epse_H)./(1+k*epse_H*10^-3); %if k=1 it is equivalent to da_H=(dp_H-epse_H)./alphae_H
da_O=(dp_O-k*epse_O)./(1+k*epse_O*10^-3); %if k=1 it is equivalent to da_O=(dp_O-epse_O)./alphae_O
% da_H=-86; %example value from Gonfiantini 1986, to reproduce his exact results
% da_O=-12; %example value from Gonfiantini 1986, to reproduce his exact results

% compute the useful variables m and dstar ('enrichment slope and limiting isotopic composition)
m_H=(hm-10^-3*(epsk_H+epse_H./alphae_H))./(1-hm+10^-3*epsk_H); %'enrichment slope' (Gibson et al.(2016))
m_O=(hm-10^-3*(epsk_O+epse_O./alphae_O))./(1-hm+10^-3*epsk_O); %'enrichment slope' (Gibson et al.(2016))
dstar_H=(hm.*da_H+epsk_H+epse_H./alphae_H)/(hm-10^-3*(epsk_H+epse_H./alphae_H)); %this is A/B in Gonfiantini 1986
dstar_O=(hm.*da_O+epsk_O+epse_O./alphae_O)/(hm-10^-3*(epsk_O+epse_O./alphae_O)); %this is A/B in Gonfiantini 1986

% get approximate evaporation line slopes: compute the slope of the line
% connecting the source water (dp) to the limiting isotopic composition (dstar) 
Slel=(dstar_H-dp_H)./(dstar_O-dp_O);
fprintf('approx. evaporation slope = %.2f\n',Slel)

% compute the isotopic composition of the residual liquid
x=(0.1:0.1:1); %different evaporation/watervolume ratios
dl_H=(dp_H-dstar_H).*(1-x).^m_H+dstar_H; %desiccating water body
dl_O=(dp_O-dstar_O).*(1-x).^m_O+dstar_O; %desiccating water body
%dl_H=(x.*m_H.*dstar_H+dp_H)./(1+m_H.*x); %this would be the asymptotic value for a lake/soil in the steady state case
%dl_O=(x.*m_O.*dstar_O+dp_O)./(1+m_O.*x); %this would be the asymptotic value for a lake/soil in the steady state case

% compute vapor isotopic composition (Craig and Gordon 1965 formula, with notation by Gibson 2016)
dE_H=((dl_H-epse_H)/alphae_H-hm.*da_H-epsk_H)./(1-hm+10^-3*epsk_H); %permil notation
dE_O=((dl_O-epse_O)/alphae_O-hm.*da_O-epsk_O)./(1-hm+10^-3*epsk_O); %permil notation


% make some PLOTS

% ENRICHMENT plots
% plots showing the individual enrichment of dS_H and dS_O for increasing
% evaporation (i.e. decreasing residual water)

figure(1)

% deuterium here
subplot(2,1,2); 
hold all 
p2=plot([1,1-x],[dp_H,dl_H],'-o','Color',[.2 .8 .5],'DisplayName','residual liquid');
p1=plot(1,dp_H,'p','LineWidth',0.5,'DisplayName','source',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor','y','MarkerSize',6);
p3=plot(0,dstar_H,'k^','LineWidth',0.5,'DisplayName','limit. composition',...
 'MarkerFaceColor',[.3 .5 .3],'MarkerSize',6);
set(gca,'XDir','reverse','TickDir','out','YLim',[-50 200])
box on
xlabel('fraction remaining water [-]')
ylabel(['\delta^{2}H [',char(8240),']'])
legend([p1,p2,p3],'Location','NW')

% oxygen18 here
subplot(2,1,1); 
hold all
p2=plot([1,1-x],[dp_O,dl_O],'-o','Color',[.2 .8 .5],'DisplayName','residual liquid');
p1=plot(1,dp_O,'p','LineWidth',0.5,'DisplayName','source',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor','y','MarkerSize',6);
p3=plot(0,dstar_O,'k^','LineWidth',0.5,'DisplayName','limit. composition',...
 'MarkerFaceColor',[.3 .5 .3],'MarkerSize',6);
set(gca,'XDir','reverse','TickDir','out','YLim',[-10 40])
box on
xlabel('fraction remaining water [-]')
ylabel(['\delta^{18}O [',char(8240),']'])
%legend([p1,p2,p3],'Location','NW')

% if you use the values of da, T and hm and the same fractionation factors 
% as tested by Gontiantini, this figure looks exactely like Gonfiantini 1986 figure 3.1


% DUAL-ISOTOPE plot

% compute the global meteoric water line (it will be used as LMWL)
xinterval=linspace(-90,25,10); %interval of dO18 for linear interpolation and plot) 
gmwl=10+8*xinterval; 

% evaporation line (obtained by interpolation of the residual liquid composition)
x1=dl_O; x1=x1(isnan(x1)==0);
y1=dl_H; y1=y1(isnan(y1)==0);
[lint,~]=polyfit(x1,y1,1);
ewl=polyval(lint,xinterval); %evaporation WL
%disp(['empiric slope = ',num2str(lint(1),'%.2f')])

% a few settings
mksz=6;

% build the figure
figure
hold all
gm=plot([min(xinterval),max(xinterval)],[gmwl(1),gmwl(end)],'LineWidth',1,'Color',[0 0 0],'DisplayName','LMWL');
lf=plot([min(xinterval),max(xinterval)],[ewl(1),ewl(end)],'-','Color',[.7 .7 .7],...
    'DisplayName','evaporation line');
p=plot(dp_O,dp_H,'p','LineWidth',0.5,'DisplayName','source',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor','y','MarkerSize',mksz+2);
a=plot(da_O,da_H,'d','LineWidth',0.5,'DisplayName','atmosphere',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor',[1 .7 0],'MarkerSize',mksz-1);
s=plot(dl_O,dl_H,'o','LineWidth',0.5,'DisplayName','residual liquid',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor',[.2 .8 .5],'MarkerSize',mksz);
st=plot(dstar_O,dstar_H,'^','LineWidth',0.5,'DisplayName','limit. composition',...
 'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.3 .5 .3],'MarkerSize',mksz);
e=plot(dE_O,dE_H,'x','LineWidth',0.5,'DisplayName','vapor',...
 'MarkerEdgeColor',[0 .6 1],'MarkerFaceColor',[.3 .5 .3],'MarkerSize',mksz);
axis([-35 20 -180 100])
title('\bf dual-isotope plot','FontSize',12)
xlabel(['\delta^{18}O [',char(8240),']'])
ylabel(['\delta^{2}H [',char(8240),']'])
legend([gm lf p a s st e],'Location','SE')
box on
axis square
set(gca,'TickDir','out')

end




%--------------------------------------------------------------------------
% 2 - introduce SEASONAL dynamics
%--------------------------------------------------------------------------
% here everything is done as before, but one month at the time 
% Parameters come from measured data. Evaporation x is generated using a
% sinusoidal cycle

if start_seasonaldynamics==1
    
% reset everything
clear variables


% mean monthly data (from: IAEA/WMO (2017). Global Network of Isotopes in 
% Precipitation. The GNIP Database. Accessible at: https://nucleus.iaea.org/wiser)
% long-term, weighted average LMWL suggested for the dataset is y=7.45x+2.12
Tc_list=[-0.1 1.6 5.7 10.7 15.3 18.6 20.4 19.9 15.5 10.2 5.3 1.2]; %january to december
dp_O_list=[-13.25 -12.66 -11.19 -9.34 -7.18 -7.30 -6.39 -6.43 -7.97 -9.35 -12.00 -13.47];
vpres_list=[5, 5.3, 6.4, 8.3, 11.6, 14.4, 15.7, 15.6, 13, 10 ,7.3, 5.5]; %[hPa] same dataset
%dp_H_list=[-97.3 -94.8 -83.7 -69.2 -52.5 -53.6 -45.7 -45.4 -55.8 -64.0 -85.6 -99.7]; %measured long-term dD values
dp_H_list=2.12+7.45.*dp_O_list; % computed from LMWL (this makes the plot easier to understand)
N=length(dp_O_list);

% get relative humidity [-] = vapor_pressure / saturated_vapor_pressure
% saturated vapor pressure [hPa] = 6.11*10^(7.5*T/(237.3+T)), where T is in Celsius
% (see e.g. www.weather.gov/epz/wxcalc_vaporpressure)
svpres_list=6.11*10.^(7.5.*Tc_list./(237.3+Tc_list)); %[hPa] 
hm_list=vpres_list./svpres_list;

% generate SEASONAL EVAPORATION
% the ratio x=evaporation/precipitation [-] is here computed as a sinusoid
xmean=0.1; %mean evaporation
fxampl=0.8; %fraction of seasonality. This is a number in (0,1), where 
            % 0=no seasonality (x=xmean) and 1=full seasonality (x goes from 0 to 2*xmean)
shift=0; %shift in the sinusoid [months]
x_list=xmean-xmean*fxampl*cos(2*pi*(linspace(0,(N-1)/12,N)-shift/12));


% plot the datasets
plot_datasets=1; %1=yes, 0=no
if plot_datasets==1
    mksz=4;

    figure
    subplot(3,1,1)
    plot(Tc_list,'-ok','MarkerSize',mksz)
    title('\bf Temperature')
    set(gca,'TickDir','out','XLim',[-Inf +Inf],'YLim',[-5 22])
    ylabel('[deg C]')
    subplot(3,1,2)
    plot(dp_O_list,'-ok','MarkerSize',mksz)
    title('\bf \delta^{18}O in precipitation')
    set(gca,'TickDir','out','XLim',[-Inf +Inf])
    ylabel(['[',char(8240),']'])
    subplot(3,1,3)
    plot(hm_list,'-ok','MarkerSize',mksz)
    title('\bf relative humidity')
    set(gca,'TickDir','out','XLim',[-Inf +Inf],'YLim',[0.6,0.9])
    ylabel('[-]')
    xlabel('month')

    figure(99)
    hold all
    plot(x_list,'-or','MarkerSize',mksz)
    plot(1:12,repmat(xmean,1,N),'k')
    title('\bf x = ratio Evap/Precip')
    set(gca,'TickDir','out','XLim',[-Inf +Inf],'YLim',[0 1],'box','on')
    xlabel('month')
    ylabel('[-]')
end


% now do the computations for the residual liquid in a loop (one value per
% month)

% preallocate variables
dS_H=zeros(1,N);
dS_O=zeros(1,N);
da_H=zeros(1,N);
da_O=zeros(1,N);
for i=1:N
    
    % ALL IN PERMIL NOTATION
    
    % select monthly climate values
    dp_H=dp_H_list(i);
    dp_O=dp_O_list(i);    
    Tc=Tc_list(i);
    hm=hm_list(i);

    % get equilibrium fractionation factors from Horita and Wesolowski
    Tk=Tc+273.15;
    alphae_H=exp(1/1000.*(1158.8*Tk.^3/10^9-1620.1*Tk.^2/10^6+...
        794.84*Tk./10^3-161.04+2.9992*10^9./Tk.^3)); %Horita and Wesolowski (1994) 
    alphae_O=exp(1/1000.*(-7.685+6.7123*10^3./Tk-1.6664*10^6./Tk.^2+...
        0.3504*10^9./Tk.^3)); %Horita and Wesolowski (1994) 
    epse_H=(alphae_H-1)*1000; %permil notation
    epse_O=(alphae_O-1)*1000; %permil notation

    % get kinetic fractionation factors (approach by Horita et al. 2008)
    n=0.75; %n=1 for dry soils, n=0.5 for lakes and saturated soils
    epsk_H=n*(1-0.9755)*1000*(1-hm); %0.9755 value from Merlivat (1978) %permil notation
    epsk_O=n*(1-0.9723)*1000*(1-hm); %0.9723 from Merlivat (1978) %permil notation

    % get atmospheric isotopic composition (precipitation-equilibrium assumption)
    k=1; %seasonality factor 
    da_H(i)=(dp_H-k*epse_H)./(1+k*epse_H*10^-3); %if k=1 it is equivalent to da_H=(dp_H-epse_H)./alphae_H
    da_O(i)=(dp_O-k*epse_O)./(1+k*epse_O*10^-3); %if k=1 it is equivalent to da_O=(dp_O-epse_O)./alphae_O
   
    % get the evaporation slopes for the desiccating body, derived from Gonfiantini (1986, eq.(6))
%     del_H=(hm.*(dp_H-da_H(i))-(1+dp_H*10^-3).*(epsk_H+epse_H./alphae_H))./(1-hm+epsk_H*10^-3);
%     del_O=(hm.*(dp_O-da_O(i))-(1+dp_O*10^-3).*(epsk_O+epse_O./alphae_O))./(1-hm+epsk_O*10^-3); 
%     Slel=del_H./del_O;

    % compute m and dstar
    m_H=(hm-10^-3*(epsk_H+epse_H./alphae_H))./(1-hm+10^-3*epsk_H); %'enrichment slope' (Gibson et al.(2016))
    m_O=(hm-10^-3*(epsk_O+epse_O./alphae_O))./(1-hm+10^-3*epsk_O); %'enrichment slope' (Gibson et al.(2016))
    dstar_H=(hm.*da_H(i)+epsk_H+epse_H./alphae_H)/(hm-10^-3*(epsk_H+epse_H./alphae_H));
    dstar_O=(hm.*da_O(i)+epsk_O+epse_O./alphae_O)/(hm-10^-3*(epsk_O+epse_O./alphae_O));

    % compute residual water composition (dS_O and dS_H)
    x=x_list(i);
    dS_H(i)=(dp_H-dstar_H).*(1-x).^m_H+dstar_H; %desiccating water body
    dS_O(i)=(dp_O-dstar_O).*(1-x).^m_O+dstar_O; %desiccating water body
%     dS_H(i)=(x.*m_H.*dstar_H+dp_H)./(1+m_H.*x); %lake in steady-state
%     dS_O(i)=(x.*m_O.*dstar_O+dp_O)./(1+m_O.*x); %lake in steady-state
    
    % compute vapor isotopic composition (Craig and Gordon 1965, formula with notation by Gibson 2016)
%     dl_H=dS_H; %the residual liquid composition is indeed the one just computed
%     dl_O=dS_O; %the residual liquid composition is indeed the one just computed
%     dE_H=((dl_H-epse_H)/alphae_H-hm.*da_H-epsk_H)./(1-hm+10^-3*epsk_H); %permil notation
%     dE_O=((dl_O-epse_O)/alphae_O-hm.*da_O-epsk_O)./(1-hm+10^-3*epsk_O); %permil notation

end

% compute the local meteoric water line
xinterval=linspace(-90,10,3); %interval of dO18 for linear interpolation and plot 
lmwl=2.12+7.45*xinterval;

% get the trendline slope and intercept with the LMWL 
app_fit=polyfit(dS_O,dS_H,1);
appwl=app_fit(2)+app_fit(1)*xinterval;
gmwl=10+8*xinterval; 
v1=2.12; %lmwl slope
v2=7.45; %lmwl intercept
app_intercept=[... %pure algebra computations
    (app_fit(2)-v1)/(v2-app_fit(1)),... %x value (d18O)
    app_fit(1)*(app_fit(2)-v1)/(v2-app_fit(1))+app_fit(2)... %y value (d2H)
    ];
disp(['trendline slope = ',num2str(app_fit(1),'%.2f')])


% make a DUAL-ISOTOPE plot

% create lines to plot the actual evaporation lines
x_evap=zeros(N,2);
y_evap=zeros(N,2);
l_fit=zeros(N,2);
for i=1:N
    l_fit(i,:)=polyfit([dp_O_list(i),dS_O(i)],[dp_H_list(i),dS_H(i)],1);
    x_evap(i,:)=[dp_O_list(i)-2,dS_O(i)+2];
    y_evap(i,:)=[dp_O_list(i)-2,dS_O(i)+2].*l_fit(i,1)+l_fit(i,2);
end
disp(['mean evaporation slope = ',num2str(mean(l_fit(:,1)),'%.2f')])

% settings for the plot
mksz=6;

% build the figure
figure
hold all
lm=plot([min(xinterval),max(xinterval)],[lmwl(1),lmwl(end)],'LineWidth',1,'Color',[0 0 0],'DisplayName','LMWL');
lf=plot([min(xinterval),max(xinterval)],[appwl(1),appwl(end)],'--','LineWidth',1.5,...
    'Color',[.5 1 .5],'DisplayName','trendline');
% plot the actual evaporation line for each month
for i=1:12
    if i==1 %to have this just once in the legend
        el=plot(x_evap(i,:),y_evap(i,:),'Color',[.9 .9 .9],...
            'DisplayName', 'actual evaporation lines');
    else
        plot(x_evap(i,:),y_evap(i,:),'Color',[.9 .9 .9])
    end
end
p=plot(dp_O_list,dp_H_list,'p','LineWidth',0.5,'DisplayName','source',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor','y','MarkerSize',mksz+2);
s=plot(dS_O,dS_H,'o','LineWidth',0.5,'DisplayName','residual liquid',...
 'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor',[.2 .8 .5],'MarkerSize',mksz);
in=plot(app_intercept(1),app_intercept(2),'s','MarkerEdgeColor','k','MarkerFaceColor',[1 .1 .1],...
    'DisplayName','intercept','MarkerSize',mksz);
axis([-20 2 -130 -10])
title('\bf dual-isotope plot','FontSize',12)
xlabel(['\delta^{18}O [',char(8240),']'])
ylabel(['\delta^{2}H [',char(8240),']'])
legend([lm lf el p s in],'Location','NW'); legend('boxoff')
box on
axis square
set(gca,'TickDir','out')


end



% REFERENCES

% Craig, H. and Gordon, L. I.: Deuterium and oxygen 18 variations in the
% ocean and marine atmosphere, in: Stable Isotopes in Oceanographic Studies
% and Paleotemperatures, Spoleto, Italy, edited by Tongiorgi, E., pp.
% 9�130, Consiglio nazionale delle ricerche, Laboratorio di geologia
% nucleare, 1965

% Gibson, J., Birks, S., and Yi, Y.: Stable isotope mass balance of lakes:
% a contemporary perspective, Quaternary Science Reviews, 131, 316�328,
% https://doi.org/10.1016/j.quascirev.2015.04.013, 2016.

% Gonfiantini, R.: Environmental isotopes in lake studies, in: The
% Terrestrial Environment, B, edited by Fritz, P. and Fontes, J., Handbook
% of Environmental Isotope Geochemistry, pp. 113�168, Elsevier, Amsterdam,
% https://doi.org/10.1016/B978-0-444-42225-5.50008-5, 1986.

% Horita, J. and Wesolowski, D.: Liquid-Vapor Fractionation of Oxygen and
% Hydrogen Isotopes of Water from the Freezing to the CriticalTemperature,
% Geochimica et Cosmochimica Acta, 58, 3425�3437,
% https://doi.org/10.1016/0016-7037(94)90096-5, 1994.

% Horita, J., Rozanski, K., and Cohen, S.: Isotope effects in the
% evaporation of water: a status report of the Craig�Gordon model, Isotopes
% in Environmental and Health Studies, 44, 23�49,
% https://doi.org/10.1080/10256010801887174, 2008.

% Merlivat, L.: Molecular diffusivities of H216O, HD16O, and H218O in
% gases, Journal Of Chemical Physics, 69, 2864�2871,
% https://doi.org/10.1063/1.436884, 1978.


%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%  END OF FILE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%