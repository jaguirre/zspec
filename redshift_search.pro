
pro redshift_search, source_name, reduc, png=png, local=local, $
                     MS_decorr=MS_decorr,PCA_decorr=PCA_decorr, spectra=spectra, jackknife=jackknife,$
                     psderror=psderror, mol=mol, suffix=suffix, zrange=zrange

co_freqs = [115.2712018, $
            230.5380000, $
            345.7959899, $
            461.0407682, $
            576.2679305, $
            691.4730763, $
            806.6518060, $
            921.7997000, $
            1036.9123930, $
            1151.9854520, $
            1267.0144860, $
            1381.9951050, $
            1496.9229090, $
            1611.7935180, $
            1726.6025057, $
            1841.3455060, $
            1956.0181390, $
            2070.6159930, $
            2185.1346800]
;rest-frame nu, other species
cii = 1900.5369
nii = [1461.1318 ,2459.38010085]
oi = 2060.06886000


;reduc = $
;  'FLS3_20100318-20100501_noflags'
;  'FLS3_ks20110601'
;  'FLS3_ks20100411_spectra'

if ~keyword_set(local) then $
                                ;restore,!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+$
restore, '/home/local/zspec/zspec_data_svn/coadded_spectra/'+$
  source_name+'/'+$
  reduc+'.sav' $
else restore, reduc+'.sav'

nu = freqid2freq()

if keyword_set(spectra) then begin
    if keyword_set(ms_decorr) and keyword_set(pca_decorr) then begin
        spec = both_decorr_spectra.in1.avespec
        err = both_decorr_spectra.in1.aveerr 
    endif else if keyword_set(MS_decorr) then begin
        spec = MS_decorr_spectra.in1.avespec
        err = MS_decorr_spectra.in1.aveerr 
    endif else if keyword_set(PCA_decorr) then begin
        spec = PCA_Decorr_spectra.in1.avespec 
        err = PCA_Decorr_spectra.in1.aveerr 
    endif else begin
        spec = uber_spectra.in1.avespec 
        err = uber_spectra.in1.aveerr
    endelse
endif else if keyword_set(jackknife) then begin
    if keyword_set(ms_decorr) and keyword_set(pca_decorr) then begin
        spec = both_decorr_jackknife.in1.avespec
        err = both_decorr_jackknife.in1.aveerr 
    endif else if keyword_set(MS_decorr) then begin
        spec = MS_decorr_jackknife.in1.avespec
        err = MS_decorr_jackknife.in1.aveerr 
    endif else if keyword_set(PCA_decorr) then begin
        spec = PCA_Decorr_jackknife.in1.avespec 
        err = PCA_Decorr_jackknife.in1.aveerr 
    endif else  begin
        spec = uber_jackknife.in1.avespec 
        err = uber_jackknife.in1.aveerr
    endelse
endif else begin
    if keyword_set(ms_decorr) and keyword_set(pca_decorr) then begin
        spec = both_decorr_psderror.in1.avespec
        err = both_decorr_psderror.in1.aveerr 
    endif else if keyword_set(MS_decorr) then begin
        spec = MS_decorr_psderror.in1.avespec
        err = MS_decorr_psderror.in1.aveerr 
    endif else if keyword_set(PCA_decorr) then begin
        spec = PCA_Decorr_psderror.in1.avespec 
        err = PCA_Decorr_psderror.in1.aveerr 
    endif else  begin
        spec = uber_psderror.in1.avespec 
        err = uber_psderror.in1.aveerr
    endelse
endelse


good = lonarr(160)+1
good[81] = 0
good[0:15]=0
whgood = where(good and finite(spec) and finite(err))
nu = nu[whgood]
spec = spec[whgood]
err = err[whgood]
good=good[whgood]

if keyword_set(mol) then begin
	if keyword_set(suffix) then suffix+='_'+mol[0] $
	else suffix=mol[0]

	for i=1, n_e(mol)-1 do suffix+='_'+mol[i]
endif	

if ~keyword_set(suffix) then suffix=''
if keyword_set(PCA_decorr) and keyword_set(MS_decorr) then suffix+='_Both' $
else if keyword_set(MS_decorr) then suffix+='_Mean_Subtract' $
else if keyword_set(PCA_decorr) then suffix+='_PCA'
if suffix ne '' then suffix='_'+suffix

zearch,nu,spec,err,z,sn,snpair,cont,fp1=fp1,fp2=fp2,fp3=fp3,name=reduc, png=png,suffix=suffix, mol=mol, zrange=zrange, snave = snave
zzearch = fp2[1]

stop

snspec = (spec-cont)/err

wh = where(snspec gt 2.0)
if wh[0] ne -1 then $
  print,nu[wh]

zguess = zzearch


cleanplot,/sil
@~/.idl_startup_zspec
load_plot_colors

if ~keyword_set(png) then begin
    set_plot,'ps'
    device,file=reduc+suffix+'.eps',/color,/encap
endif else erase

multiplot,[1,2],/init

multiplot
m1=mean(spec/good, /nan)
m2=mean((spec/good)^2, /nan)
s=sqrt(m2-m1^2)

ploterror,nu,spec/good,err/good,psy=10,/xst,tit=reduc+suffix,ytit='Flux (Jy)',/yst,$
  yr=[0,m1+2*s]

oplot,nu,cont,col=!cols.pink,thick=4
legend,/top,/left,box=0,textoidl('z_{zearch} = ')+$
  string(zzearch,format='(F5.3)')
legend,/bottom,/right,$
;  ['[NII](205)', '[CII](158)', '[OI](145)', 
['[CII](158)', 'CO', textoidl('2 \sigma peaks')],$
  textcolor=[!cols.green,!cols.red,!cols.grey]
;[!cols.red,!cols.green,!cols.blue,!cols.red,!cols.grey]
vline,co_freqs/(1.+zguess),col=!cols.red,thick=4
vline,cii/(1.+zguess),col=!cols.green,thick=4
if wh[0] ne -1 then $
  vline,nu[wh],col=!cols.grey,thick=4,line=2

multiplot
plot,nu/good,snspec/good,psy=10,/xst,ytit='S/N (spectra)',xtit='Frequency (GHz)',$
  thick=2

vline,co_freqs/(1.+zguess),col=!cols.red,thick=4
vline,cii/(1.+zguess),col=!cols.green,thick=4
if wh[0] ne -1 then $
  vline,nu[wh],col=!cols.grey,thick=4,line=2
vline,nii/(1.+zguess),col=!cols.red,thick=2
vline,oi/(1.+zguess),col=!cols.blue,thick=2

if ~keyword_set(png) then begin
    device,/close
    set_plot,'x'
endif else x2png, reduc+suffix+'_zearch_spec.png', /color,/rev

cleanplot,/sil

spawn,'gv '+reduc+suffix+'.eps &'
spawn,'gv '+reduc+suffix+'_zearch.eps &'

end
