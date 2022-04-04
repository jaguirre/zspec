;pro quick_look

dir='/home/zspec/zspec_svn/processing/spectra/coadded_spectra/'

SPT2004=dir+'SPT_2004-44/SPT_2004-44_20101022_0349.sav'
SPT3=dir+'SPT_2332-53/SPT_2332-53_20101022_0438.sav'
SPT2134_50=dir+'SPT_2134-50/SPT_2134-50_20101022_0351.sav'
NGC1068=dir+'NGC1068/NGC1068_20101020_1816.sav'
SPT0538_50=dir+'SPT_0538-50/SPT_0538-50_20101022_1940.sav'

SPT2031_51=dir+'SPT_2031-51/SPT_2031-51_20101022_2015.sav'
SPT0027_50=dir+'SPT_0027-50/SPT_0027-50_20101022_2001.sav'
SPT0532_50=dir+'SPT_0532-50/SPT_0532-50_20101022_1959.sav'
;SPT0346_52=dir+
SPT0103_45=dir+'SPT_0103-45/SPT_0103-45_20101022_1936.sav'

;obs=[SPT2004,SPT3,SPT2134_50,SPT0538_50,SPT2031_51,SPT0027_50,SPT0532_50,SPT0103_45,SPT2103_60,SPT0512_59,SPT2132_58,SPT2353-50,SPT2357_51]
;above part is now obsolete


names=['SPT2004','SPT3','SPT2134_50','SPT0538_50','SPT2031_51','SPT0027_50','SPT0532_50','SPT0103_45','SPT2103-60','SPT2103_60_lp','SPT0512_59','SPT2132_58','SPT2353_50','SPT2357_51','SPT0202_61_lp']
;this is just for back-compatibility
objname=['SPT_2004-44','SPT_2332-53','SPT_2134-50','SPT_0538-50','SPT_2031-51','SPT_0027-50','SPT_0532-50',$
'SPT_0103-45','SPT_2103-60','SPT_2103-60_lp','SPT_0512-59','SPT_2132-58','SPT_2353-50','SPT_2357-51','SPT_0202-61_lp']
sptpt=[0.,36.9,28.4,31.3,25.0,47.9,42.2,38.6,29.3,29.3,24.7,33.9,21.7,22.6,50.9]/1000.
nuspt=3.e5/1360.
nobs=n_elements(objname)

flags=intarr(160)+1
cflags=[81,86,128,156,158]
flags[cflags]=0
flags(157:159)=0
flags(0:25)=0

wu=where(flags ne 0)
;mars=dir+'Mars/Mars_20101019_2108.sav'
;plot_uber_spectrum_ks,'Mars/Mars_20101019_2108.sav',/mars,xflat=xflat
;restore,SPT2134_50
;restore,SPT0538_50
;restore,SPT2031_51
;restore,SPT0027_50
;restore,SPT0532_50
;restore,SPT0103_45
;restore,SPT3
;restore,SPT2004
;restore,NGC1068
set_plot,'ps'
device,filename='./quick_look/SPT_coadds.ps',/landscape,/color

for j=0,nobs-1 do begin

dir = '/home/zspec/zspec_svn/processing/spectra/coadded_spectra/'+objname(j)
saves = FILE_SEARCH( dir+'/'+objname(j)+'_20*.sav', COUNT=nsav )
uber_sav = saves[nsav-1]
  print,uber_sav
message,'Restoring file...',/inf
restore,uber_sav;,VERBOSE=verbose

;restore,obs(j)
;uber_sav=obs(j)

spec_in=uber_psderror.in1.avespec
specerr=uber_psderror.in1.aveerr
int_time=total_n_sec
print,'Source: ',objname(j)
print,'Integration time: ',int_time/3600.,' hours'
print,'Median RMS (Jy): ',median(specerr(wu))
print,'Sensitivity in Jy sqrt(s): ', median(specerr(wu)*sqrt(int_time))

nu=freqid2freq()

;try a continuum fit
r1=0.0 ;;initial guess for redshift
speci=['12CO']
transition=['2-1']
lfwhm=400. ;;km/s
fun=zspec_fit_lines_cont(flags,spec_in,specerr,r1,speci,transition,lw_value=lfwhm,/z_fixed,/lw_fixed,/lw_tied,cont_type='PWRLAW')
;fun.cspec is the continuum fit

;restore,mars
;spec_flat=spec_in/xflat
;spec_flat_err=specerr/xflat
;this is where I was using Mars to calibrate

;stop
;window,1,xsize=1100,ysize=700
!p.multi=[0,1,3]
loadct,39
;ploterror,nu,spec_in/flags,specerr,psym=10,yst=1,yr=[-0.,0.2]
;hline,0,line=2
!p.charsize=1.5
ploterror,nu,spec_in,specerr,psym=10,yr=[-0.03,0.15],yst=1,ytit='Flux Density (Jy)',tit=uber_sav,xtit='Frequency (GHz)'
oplot,nu,fun.cspec,color=240
oplot,[nuspt,nuspt],[sptpt(j),sptpt(j)],psym=5,color=80,thick=5
hline,0,line=2
vline,nu(cflags),line=2
plot,nu,spec_in/specerr,ytit='S/N',psym=10,xtit='Frequency (GHz)'
hline,[-1,0,1],line=2
vline,nu(cflags),line=2

plot,nu,(spec_in-fun.cspec)/specerr,ytit='S/N, continuum subtracted',psym=10,xtit='Frequency (GHz)',tit=sstr(int_time/3600.,prec=2)+' hrs, Median RMS: '+$
sstr(median(specerr(wu)),prec=3)+' Jy, Sensit. '+sstr(median(specerr(wu))*sqrt(int_time),prec=2)+' Jy sqrt(s)'
hline,[-1,0,1],line=2
vline,nu(cflags),line=2


;x2png,'./quick_look/'+names(j)+'.png',/rev,/color
save,nu,spec_in,specerr,flags,filename='./quick_look/'+names(j)+'_spec.sav'
endfor
device,/close
set_plot,'x'

co_freqs = [115271.20200, $
            230538.00000, $
            345795.99000, $
            461040.76800, $
            576267.93100, $
            691473.07600, $
            806651.80100, $
            921799.70400, $
            1036912.38500, $
            1151985.44300, $
            1267014.48200, $
            1381995.10200, $ 
	    1496922.9090, $
            1611793.5180, $ 
	    1726602.5057, $
	    1841345.5060, $
	    1956018.1390]/1.d3

z=2.3
;vline,co_freqs/(1.+z)
end
