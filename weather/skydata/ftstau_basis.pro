pro ftstau_basis

; a quick file to interpolate the sky tau as a function of frequency,
; but as binned by the FTS dataset we use for the line fitting.
; MB 3 July 2007

restore,!ZSPEC_PIPELINE_ROOT+'/weather/skydata/csodry.sav'
restore,!ZSPEC_PIPELINE_ROOT+'/weather/skydata/cso2mm.sav'
tau_freq=csodry.freq

restore,!ZSPEC_PIPELINE_ROOT+'/line_cont_fitting/ftsdata/normspec_nov.sav'
;fts_freq=nu_trim
dnu_trim=nu_trim[1]-nu_trim[0]

fts_tau_dry=fltarr(n_elements(nu_trim))
fts_tau_2mm=fltarr(n_elements(nu_trim))
fts_tautrans_dry=fltarr(n_elements(nu_trim))
fts_tautrans_2mm=fltarr(n_elements(nu_trim))

for i=0,n_elements(nu_trim)-1 do begin

; these are loading-weighted taus
fts_tau_dry[i]=-1.*ALOG(1.0-$
                       MEAN(1. - $
                            EXP(-1.0*$
                                csodry.tau[WHERE(ABS(tau_freq-nu_trim[i]) LT $
                                                 dnu_trim/2)])))
fts_tau_2mm[i]=-1.*ALOG(1.0-$
                       MEAN(1. - $
                            EXP(-1.0*$
                                cso2mm.tau[WHERE(ABS(tau_freq-nu_trim[i]) LT $
                                                 dnu_trim/2)])))

; now tau-weighted taus
fts_tautrans_dry[i]=-1*ALOG(MEAN(EXP(-1*csodry.tau[WHERE(ABS(tau_freq-nu_trim[i]) LT $
                                                  dnu_trim/2)])))
fts_tautrans_2mm[i]=-1*ALOG(MEAN(EXP(-1*cso2mm.tau[WHERE(ABS(tau_freq-nu_trim[i]) LT $
                                                  dnu_trim/2)])))


end

save,fts_tau_dry,file='fts_tau_dry.sav'
save,fts_tau_2mm,file='fts_tau_2mm.sav'
save,fts_tautrans_dry,file='fts_tautrans_dry.sav'
save,fts_tautrans_2mm,file='fts_tautrans_2mm.sav'

restore,'fts_tau_dry.sav'
restore,'fts_tau_2mm.sav'
restore,'fts_tautrans_dry.sav'
restore,'fts_tautrans_2mm.sav'

plot,nu_trim,1-exp(-1*fts_tau_dry),/ylog,/xst,/yst,yrange=[1e-2,1]
oplot,nu_trim,1-exp(-1*fts_tau_2mm)
oplot,nu_trim,1-exp(-1*fts_tautrans_dry),color=2
oplot,nu_trim,1-exp(-1*fts_tautrans_2mm),color=2

stop
end
