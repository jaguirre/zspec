; quick focus analysis script for apex obs.  VERY PRELIMINARY!!!
;
; LIST is a coadd_list file with every scan in the focus obs, and
; FOCUS_POS is the Z focus position for every scan in LIST.  (A
; smarter routine would find the focus pos in some file somewhere, but
; I currently don't know where that gets written.)  On output, UFOCPOS
; will contain the unique focus positions, AMPLVEC will contain the
; average amplitude (arbitrary normalization) for each unique focus
; position, and BESTFOCUS will contain the guess at the correct focus
; position. 
;
; created 30Oct10 from focus.pro, TC
;

pro focus_apex, list, focus_pos, ufocpos, amplvec, bestfocus,proj=proj,$
    source=source
if proj eq 'SPT' then run='E-086.A-0793A-2010'
if  proj eq 'ATLAS' then run='E-087.A-0820A-2010'
if  proj eq 'HERMES' then run='E-087.A-0397A-2010'

IF N_ELEMENTS(source) EQ 0 THEN source='Uranus'

; run zapex on data 
run_zapex,list,proj=proj

; parse list to get number of scans
list_fullname = !zspec_pipeline_root+'/processing/spectra/coadd_lists/'+list
readcol,list_fullname,night,scan_numbers,flag,calscans,form='A,A,I,A',/SIL

; get unique focus positions
whgood = where(flag eq 1,ngood)
scan_numbers = scan_numbers[whgood]
fpgood = focus_pos[whgood]
sfp = sort(fpgood)
ufp = sfp[uniq(fpgood[sfp])]
ufocpos = fpgood[ufp]
whichpos = intarr(ngood)
for i=0,ngood-1 do begin
    whpos = where(ufocpos eq fpgood[i],nwhpos)
    whichpos[i] = whpos
endfor

; step through scans, fitting average spectrum to a quadratic and
; recording amplitude.  
amplvec_all = fltarr(ngood) + !values.f_nan
nu = freqid2freq(indgen(160))
nu_fit = (findgen(1000)+0.5)/1000.*(max(nu)-min(nu)) + min(nu)
for i=0,ngood-1 do begin
    j = whgood[i]
    year = strmid(night[j],0,4)
    month = strmid(night[j],4,2)
    day = strmid(night[j],6,2)
    ;thisfile = '~/data/observations/apexnc/'+source+$
    ;  '/APEX-'+scan_numbers[j]+'-'+year+'-'+month+'-'+day+'-'+run+'_spec.sav'
fsrch='~/data/observations/apexnc/*/APEX-'+scan_numbers[j]+'-*_spec.sav';)
	spawn,'ls '+fsrch,thisfile;save_spectra_file
        restore,thisfile
    ndtemp = size(vopt_psderror.in.nodspec,/n_dim)
    if ndtemp gt 1 then spec = vopt_psderror.in.avespec $
      else spec = vopt_psderror.in.nodspec
; probably not necessary, but do poly fit, then remove outliers, then
; fit again
    whg1 = where(finite(spec))
    coeffs_init = poly_fit(nu[whg1],spec[whg1],2)
    spec_sub = spec
    spec_sub[whg1] = spec[whg1]-poly(nu[whg1],coeffs_init)
    meantemp = rm_outlier(spec_sub,3.,goodmask,thisrms,/sdev,/quiet)
    whg2 = where(goodmask)
    coeffs_final = poly_fit(nu[whg2],spec[whg2],2)
    spec_fit = poly(nu_fit,coeffs_final)
    amplvec_all[i] = sqrt(total(spec_fit^2))
endfor

; if any focus positions are repeated, average amplitudes at those
; positions
nuniq = n_elements(ufocpos)
amplvec = fltarr(nuniq)
for i=0,nuniq-1 do begin
    whthispos = where(whichpos eq i,nthispos)
    amplvec[i] = mean(amplvec_all[whthispos])
endfor

; now do simple quadratic fit on amplitude vs. focus position
coeffs_focus = poly_fit(ufocpos,amplvec,2)
focpos_fit = (findgen(1000)+0.5)/1000.*(max(ufocpos)-min(ufocpos)) + min(ufocpos)
ampl_fit = poly(focpos_fit,coeffs_focus)
maxamplfit = max(ampl_fit,whmax)
bestfocus = focpos_fit[whmax[0]]

outfile=change_suffix(list_fullname,'_focus.ps')

set_plot,'x'
plot,ufocpos,amplvec,psym=4,thick=2,syms=2, $
  xtitle='Focus setting',ytitle='Signal [arb.]'
oplot,focpos_fit,ampl_fit,thick=2,line=2
oplot,[0,0]+bestfocus,[0,0]+maxamplfit,psym=1,thick=2,syms=2
oplot,[0,0]+bestfocus,[-1e6,1e6],thick=2,line=1
legend,['data','fit','best focus'],psym=[4,0,1],syms=[2,0,2], $
  thick=[2,2,2],line=[0,2,0],/bottom,/right
xyouts,bestfocus,min(amplvec) + (maxamplfit-min(amplvec))/2., $
  'Best focus = '+string(bestfocus,form='(f8.3)'),chars=1.4, $
  align=0.5

print,'Plot hardcopy is ',outfile
set_plot,'ps'
device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
  language_level=2,/encapsulated,/color
device,filename=outfile,font_size=18
plot,ufocpos,amplvec,psym=4,thick=4,syms=2, $
  xtitle='Focus setting',ytitle='Signal [arb.]',charthick=2.0
oplot,focpos_fit,ampl_fit,thick=4,line=2
oplot,[0,0]+bestfocus,[0,0]+maxamplfit,psym=1,thick=4,syms=2
oplot,[0,0]+bestfocus,[-1e6,1e6],thick=4,line=1
legend,['data','fit','best focus'],psym=[4,0,1],syms=[2,0,2], $
  thick=[4,4,4],line=[0,2,0],/bottom,/right
xyouts,bestfocus,min(amplvec) + (maxamplfit-min(amplvec))/2., $
  'Best focus = '+string(bestfocus,form='(f8.3)'),charthick=2.0, $
  align=0.5
device,/close

set_plot,'x'

end
