;2007-08 LE
;MARS SPECTRA FROM SPRING 2007 CALIBRATION OBSERVATIONS.  EACH NOD
;CORRECTED FOR SKY TRANSMISSION AND CALIBRATED USING FLUX CALIBRATION
;DERIVED FROM ALL THESE OBSERVATIONS.

pro mars_by_mars_cal

cal_file=!zspec_pipeline_root+'/calibration/calibration_obs_spring07.txt'

restore,!zspec_pipeline_root+'/calibration/calibration_obs_spring07.sav'
restore,!zspec_pipeline_root+'/calibration/cal_fit_to_mars.sav'

cal_constants=reform(fitpars[*,0,*])

plotfilename=!zspec_pipeline_root+'/calibration/mars_by_mars_cal.ps'

set_plot,'ps'
device,/portrait,/inches,/color,file=plotfilename,$
  xsize=7.5,ysize=8,xoffset=0.5,yoffset=0.5

;_______________________________________________________________
;READ IN MARS OBSERVATIONS FROM LIST OF CALIBRATION OBS

readcol,cal_file,date,obs,planet,flag,format='(a8,a3,a,i1)'

;pick out only observations of Mars with flag 1

   wantdata=where(flag eq 1 and planet eq 'Mars')
   n_obs=n_e(wantdata)
   date=date(wantdata)
   obs=obs(wantdata)

;break up date into year, month, night
   a=0L & b=0L & c=0L
   year=strarr(n_obs) & month=year & night=year
   for i=0,n_obs-1 do begin
       reads,date[i],a,b,c,format='(a4,a2,a2)'
       year[i]=a & month[i]=b & night[i]=c
   endfor

nods_per_obs=[0]
temps=fltarr(n_obs)

for i=0,n_obs-1 do begin

;________________________________________________________________
;FIND APPROPRIATE NETCDF FILE AND RESTORE DEMODULATED DATA

nc_file=get_ncdfpath(year[i],month[i],night[i],obs[i])
restore,change_suffix(nc_file,'_spectra.sav')

ticks=read_ncdf(nc_file,'ticks')
elevation=read_ncdf(nc_file,'elevation')
t_bath=get_temps(nc_file)

nod_start=nod_struct.i
nod_end=nod_struct.f

for nod=0,n_nods-1 do begin

    median_ut=$
      median(ticks[nod_start[nod]:nod_end[nod]])/3600.
    tau=tau225smooth(date[i],median_ut)
    median_elev=$
      median(elevation[nod_start[nod]:nod_end[nod]])
    median_airmass=$
      1./sin(median_elev*(!pi/180.))
    trans=trans_zspec_fts_incl_airmass(tau,median_airmass)

    tbath_1=median(t_bath.grt1[nod_start[nod]:nod_end[nod]])
    tbath_2=median(t_bath.grt2[nod_start[nod]:nod_end[nod]])
    tbath=(tbath_1+tbath_2)/2.

  if nod eq 0 then begin      
      tau_all=tau
      am_all=median_airmass
      trans_all=trans
      tbath_all=tbath
  endif else begin
      tau_all=[tau_all,tau]
      am_all=[am_all,median_airmass]
      trans_all=[trans_all,trans]
      tbath_all=[tbath_all,tbath]
  endelse

endfor

if i eq 0 then begin
   tau_total=tau_all
   am_total=am_all
   trans_total=trans_all
   tbath_total=tbath_all
endif else begin
   tau_total=[tau_total,tau_all]
   am_total=[am_total,am_all]
   trans_total=[trans_total,trans_all]
   tbath_total=[tbath_total,tbath_all]
endelse

;______________________________________________________________________
;NOW CALIBRATE OBSERVATIONS USING FIT TO THESE MARS OBSERVATIONS

cal=cal_from_dcbolo(year[i],month[i],night[i],obs[i],cal_constants)
vopt_spectra=spectra_div(vopt_spectra,cal)
vopt_spectra=spectra_div(vopt_spectra,trans_all)

if i eq 0 then begin
  for n=0,n_nods-1 do begin
      if n eq 0 then spec_all=vopt_spectra.in1.nodspec[*,n] else $
        spec_all=[[spec_all],[vopt_spectra.in1.nodspec[*,n]]]
  endfor
  total_n_nods=n_nods
endif else begin
  for n=0,n_nods-1 do begin
      spec_all=[[spec_all],[vopt_spectra.in1.nodspec[*,n]]]
  endfor
  total_n_nods=total_n_nods+n_nods
endelse

endfor

;______________________________________________________________________
;PLOT EACH NOD

for q=0,total_n_nods-1 do begin

    if q mod 5 eq 0 then begin
        multiplot,[1,5],/verbose
        if q eq 0 then i=0 else i=i+1
        pagetitle='Mars by Z-Spec, '+strcompress(date[i])+' Obs # '+$
          strcompress(obs[i])
    endif else begin
        multiplot,/verbose
        pagetitle=''
    endelse


    if (q+1) mod 5 eq 0 then begin
        plot,freqid2freq(indgen(160)),spec_all[*,q],$
          /yno,/yst,xrange=[180,310],/xst,psym=10,$
          ytit='[Jy]',xtit='[GHz]'
        multiplot,/reset
        erase
    endif else begin
        plot,freqid2freq(indgen(160)),spec_all[*,q],/yno,/yst,$
          xrange=[180,310],/xst,psym=10,ytit='[Jy]',tit=pagetitle
    endelse

endfor


device,/close

set_plot,'x'

stop

end











