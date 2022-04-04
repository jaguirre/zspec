;_________________________________________________________________
;*****************************************************************
;updated by LE April 2008
;
;Variables mars_obs, uranus_obs, and neptune_obs in the resulting
;save file have values of 0 or 1, indicating if observations of these
;planets exist in the current calibration file.  This will help avoid
;errors when doing linear fits to each of the planets separately.
;
;Setting the keyword /chop_fudge will make the signal voltage higher
;by a factor of chop_fac (determined in save_spectra).  Otherwise,
;chop_fac is set to 1, i.e. no change to the demodulated vbolo.
;
;updated by LE August 2007
;written by LE June 2007
;
;takes in a text file of planet calibrations and computes V/Jy as
;function of the low frequency bolometer voltage (using the quadrature
;sum)
;
;for starters look at spring 2007 data (all observations were done at
;mult 25 = 10 mV bias)
;
;dc voltage, flux calibration, airmass and tau are all computed per
;nod
;
; JRK 10/21/10: Added keywords apex and run for filename convention.
; REL 01/04/11: make it compatible with new paths; use pwv from the
; .sav file
;___________________________________________________________________
;******************************************************************

pro flux_calibration,cal_file,chop_fudge=chop_fudge,apex=apex,run=run

cal_file=!zspec_pipeline_root+'/calibration/'+cal_file

savefilename=change_suffix(cal_file,'.sav')

;_________________________________________________________________
;READ IN TEXT FILE DEFINING WHICH CALIBRATION OBSERVATIONS TO USE

if ~keyword_set(apex) then $
  readcol,cal_file,date,obs,planet,flag,format='(a8,a3,a,i1)' $
else readcol,cal_file,date,obs,planet,flag,format='(a8,a5,a,i1)'
  n_obs=n_e(date)

  ;break up the date into year, month, night
    a=0L & b=0L & c=0L
    year=strarr(n_obs) & month=year & night=year
    for i=0,n_obs-1 do begin
        reads,date[i],a,b,c,format='(a4,a2,a2)'
        year[i]=a & month[i]=b & night[i]=c
    endfor

  ;get rid of observations with flag 0
    wantdata=where(flag eq 1)
    n_obs=n_e(wantdata)
    year=year(wantdata)
    month=month(wantdata)
    night=night(wantdata)
    obs=obs(wantdata)
    planet=planet(wantdata)
    date=date(wantdata)

;________________________________________________________________
;SOME NEW STORAGE VAIRABLES

    nods_per_obs=[0]
    source=intarr(n_obs)

;_________________________________________________________________
;RESTORE DEMODULATED DATA FILE AND FIND APPROPRIATE NETCDF FILE

for i=0,n_obs-1 do begin
    if ~keyword_set(apex) then begin
                                ;first unzip file if zipped

        ncdffile=get_ncdfpath(year[i],month[i],night[i],obs[i])
        file=change_suffix(ncdffile,'_spectra.sav')

        zippedfile=ncdffile+'.gz'
        zippedspectra=file+'.gz'

        maligned=file_search(ncdffile)
        zipped=file_search(zippedfile)

        save_spec=file_search(file)
        save_spec_zipped=file_search(zippedspectra)

        if maligned eq '' and zipped eq zippedfile then begin
            print,'Gunzipping netCDF file....'
            spawn,'gunzip '+zippedfile
        endif

        if save_spec eq '' and save_spec_zipped eq zippedspectra then begin
            print,'Gunzipping save_spectra file....'
            spawn,'gunzip '+zippedspectra
        endif
    endif else begin ; APEX file convention
        xmain_data_dir = !zspec_data_root + PATH_SEP()
        ;xdate_str=STRING(year[i], F='(I04)')+STRING(month[i],F='(I02)')+$
        ;  STRING(night[i],F='(I02)')
        xobs_str=STRING(obs[i],F='(I05)')
        print,!zspec_data_root+PATH_SEP()+$
                     'apexnc/*/APEX-'+obs[i]+'*_spec.sav'
        file= file_search(!zspec_data_root+PATH_SEP()+$
                     'apexnc/*/APEX-'+obs[i]+'-*_spec.sav')
        
    endelse

    ;restore spectra.sav file

    restore,file
    case planet[i] of
        'Mars': source[i]=0
        'Uranus': source[i]=1
        'Jupiter': source[i]=2
        'Neptune': source[i]=3
    endcase
    
;______________________________________________________________________
;GET TAU, AIRMASS, & BATH TEMP FOR EACH NOD

if ~keyword_set(apex) then begin
    ticks=read_ncdf(ncdffile,'ticks')
    elevation=read_ncdf(ncdffile,'elevation')
    tbath=get_temps(ncdffile)
;; remove the GRT filters MB 6 October 2014
    tgrt1=(tbath.grt1)  ;filter out grt oscillations
    tgrt2=(tbath.grt2)  ;filter out grt oscillations
;    tgrt1=grt_filter(tbath.grt1)  ;filter out grt oscillations
;    tgrt2=grt_filter(tbath.grt2)  ;filter out grt oscillations

endif else begin
    ticks=nc_ticks
    elevation=nc_elevation
    ; It seems we DON'T need grt temps?
endelse

    nod_start=nod_struct.i
    nod_end=nod_struct.f
    
    if ~keyword_set(apex) then datestring=strmid(file_basename(ncdffile),0,8) $
      else datestring=date[i]

    for nod=0,n_nods-1 do begin

        median_ut=$
          median(ticks[nod_start[nod]:nod_end[nod]])/3600.
        
;----------- not sure about this, JRK 10/20/10
        if ~keyword_set(apex) then begin
          thistau_temp=tau225smooth(datestring,median_ut)
      endif else thistau_temp=pwv2tau(nc_pwv[nod])
;;;outdated part below
;begin
          ;;the values for each scan are in the observing logs, but a pain to read in
;;read in pwv  from .dat files and use pwv2tau
 ;         readcol,'/home/zspec/data/obs_logs/zspec_search.dat',xa,xb,xc,xd,xe,xf,xg,xh,xi,xj,format='(A19,A18,L5,A13,A6,A5,A7,A5,A4,F4.2)'
  ;        wtau=where(xc eq obs[i])
   ;       if wtau(0) ne -1 then thistau_temp=pwv2tau(xj(wtau(0))) else print,'Scan number not found. Make sure to copy the latest logs.'
    ;  endelse
;------------
        
        median_elev=$
          median(elevation[nod_start[nod]:nod_end[nod]])
        median_airmass_temp=$
          1./sin(median_elev*(!pi/180.))
        trans_this_nod=$
          trans_zspec_fts_incl_airmass(thistau_temp,median_airmass_temp)

        if ~keyword_set(apex) then begin
        tbath_this_nod1=median(tgrt1[nod_start[nod]:nod_end[nod]])
        tbath_this_nod2=median(tgrt2[nod_start[nod]:nod_end[nod]])
        endif
        
        if nod eq 0 then begin
            thistau=thistau_temp 
            median_airmass=median_airmass_temp
            transmission=trans_this_nod
            if ~keyword_set(apex) then t_bath1=tbath_this_nod1
            if ~keyword_set(apex) then t_bath2=tbath_this_nod2
        endif else begin
            thistau=[thistau,thistau_temp]
            median_airmass=[median_airmass,median_airmass_temp]
            transmission=[[transmission],[trans_this_nod]]
            if ~keyword_set(apex) then t_bath1=[t_bath1,tbath_this_nod1]
            if ~keyword_set(apex) then t_bath2=[t_bath2,tbath_this_nod2]
        endelse
   
    endfor

    if i eq 0 then begin
        tau_total=thistau
        airmass_total=median_airmass
        transmission_total=transmission
        if ~keyword_set(apex) then t_grt1=t_bath1
        if ~keyword_set(apex) then t_grt2=t_bath2
    endif else begin
        tau_total=[tau_total,thistau]
        airmass_total=[airmass_total,median_airmass]
        transmission_total=[[transmission_total],[transmission]]
        if ~keyword_set(apex) then t_grt1=[t_grt1,t_bath1]
        if ~keyword_set(apex) then t_grt2=[t_grt2,t_bath2]
    endelse
  
;_________________________________________________________________________
;COMPUTE CALIBRATION
    
    print,'obs is currently'+file

    if ~keyword_set(apex) then begin
        spectra_ave,vopt_spectra
        spectra_ave,vopt_psderror
    endif
    ;jy_per_planet=cal_vec(year[i],month[i],night[i],source=source[i],unit=0)
    jy_per_planet=cal_vec(year[i],month[i],night[i],source[i],apex=apex)

    if ~keyword_set(chop_fudge) then chop_fac=1.
    calibration_array=$
      spectra_div(vopt_spectra,(jy_per_planet*transmission)/chop_fac)
    calibration_psderror=$
      spectra_div(vopt_psderror,(jy_per_planet*transmission)/chop_fac)

    if i eq 0 then begin
        cal_total=calibration_psderror.in1.nodspec
        err_total=calibration_psderror.in1.noderr
    endif else begin
        cal_total=[[cal_total],[calibration_psderror.in1.nodspec]]
        err_total=[[err_total],[calibration_psderror.in1.noderr]]
    endelse

;_________________________________________________________________________
;COMPUTE QUADRATURE SUM OF BOLO VOLTAGES

    if ~keyword_set(apex) then begin
        vbolo_quad=get_quad_sum(year[i],month[i],night[i],obs[i])
    endif else begin
        ; at APEX, this job has already been done for us
        tempfile=strsplit(file,'_',/extract)
        vdcfile=tempfile[0]+'_vdc.sav'
        restore,vdcfile
    endelse

    if i eq 0 then vbolo_quad_total=vbolo_quad else $
      vbolo_quad_total=[vbolo_quad_total,vbolo_quad]    
    
;__________________________________________________________________________    
;DO SOME NOD HOUSEKEEPING

    ;keep track of number of nods per observation
    if i eq 0 then nods_per_obs=n_nods else $
      nods_per_obs=[nods_per_obs,n_nods]

    ;keep track of which nods belong in which observation
        if i eq 0 then $
            which_obs=replicate(i,nods_per_obs[i]) $
        else begin
            which_obs_temp=replicate(i,nods_per_obs[i])
            which_obs=[which_obs,which_obs_temp]
        endelse

    
endfor  ;end of for loop over all observations

;___________________________________________________________________________
;SAVE TAU*AIRMASS FOR ALL NODS

  ttam=tau_total*airmass_total
  
;___________________________________________________________________________
;SORT DATA BY PLANET

      
     ;mars
        marsobs=where(source eq 0)
        if total(marsobs) ne -1 then begin
            mars_obs=1
            for i=0,n_e(marsobs)-1 do begin
                if i eq 0 then begin
                    plotmars=where(which_obs eq marsobs[i])
                endif else begin
                    plotmars_temp=where(which_obs eq marsobs[i])
                    plotmars=[plotmars,plotmars_temp]
                endelse
            endfor
        endif else begin
         plotmars='none'
         mars_obs=0
     endelse


    ;uranus
         uranusobs=where(source eq 1)
         if total(uranusobs) ne -1 then begin
             uranus_obs=1
             for i=0, n_e(uranusobs)-1 do begin
                 if i eq 0 then begin
                     ploturanus=where(which_obs eq uranusobs[i])
                 endif else begin
                     ploturanus_temp=where(which_obs eq uranusobs[i])
                     ploturanus=[ploturanus,ploturanus_temp]
                 endelse
             endfor
         endif else begin
             ploturanus='none'
             uranus_obs=0
         endelse


    ;neptune
        neptuneobs=where(source eq 3)
        if total(neptuneobs) ne -1 then begin
            neptune_obs=1
            for i=0, n_e(neptuneobs)-1 do begin
                if i eq 0 then begin
                    plotnep=where(which_obs eq neptuneobs[i])
                endif else begin
                    plotnep_temp=where(which_obs eq neptuneobs[i])
                    plotnep=[plotnep,plotnep_temp]
                endelse
            endfor
        endif else begin
            plotnep='none'
            neptune_obs=0
        endelse


;___________________________________________________________________________
;CREATE SAV FILE OF ABOVE DATA

if ~keyword_set(apex) then begin
save,date,obs,source,flag,n_obs,cal_total,t_grt1,t_grt2,$
  vbolo_quad_total,which_obs,tau_total,airmass_total,ttam,$
  transmission_total,err_total,plotmars,plotnep,ploturanus,$
  mars_obs,uranus_obs,neptune_obs,$
  filename=savefilename,/verbose
endif else begin
save,date,obs,source,flag,n_obs,cal_total,$
  vbolo_quad_total,which_obs,tau_total,airmass_total,ttam,$
  transmission_total,err_total,plotmars,plotnep,ploturanus,$
  mars_obs,uranus_obs,neptune_obs,$
  filename=savefilename,/verbose
endelse

;stop

end
