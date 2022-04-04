;_________________________________________________________________
;*****************************************************************
;created by LE 2007-11-15
;
;This is a slightly modified version of flux_calibration.pro.  Instead
;of reading in a text file of a bunch of calibration observations,
;this function takes one planet observation and computes V/Jy as a
;function of the bolometer DC 
;
;DC level, flux calibration, and airmass are all computed per
;nod.  By default this function finds the median tau (from 
;rpc_params.tau225) over the entire observation and uses it for 
;all nods.  You can use the keyword /tausmooth to make it compute 
;a gaussian smoothed tau on a nod-by-nod basis, but this requires 
;that an appropriate text file with the tau_225 data for that 
;month exists in the zspec_svn/weather/ directory. 

;___________________________________________________________________
;******************************************************************

function flux_calibration_oneobs,year,month,night,obs,planet,$
                                 tausmooth=tausmooth

;_________________________________________________________________
;RESTORE DEMODULATED DATA FILE AND FIND APPROPRIATE NETCDF FILE

    ncdffile=get_ncdfpath(year,month,night,obs)
    file=change_suffix(ncdffile,'_spectra.sav')

    ;restore spectra.sav file

    restore, file    
    case planet of
        'Mars': source=0
        'Uranus': source=1
        'Jupiter': source=2
        'Neptune': source=3
    endcase
    
;__________________________________________________________________________
;GET AIRMASS, & BATH TEMP FOR EACH NOD

    ticks=read_ncdf(ncdffile,'ticks')
    elevation=read_ncdf(ncdffile,'elevation')
    tbath=get_temps(ncdffile)
    tgrt1=grt_filter(tbath.grt1)  ;filter out grt oscillations
    tgrt2=grt_filter(tbath.grt2)  ;filter out grt oscillations

    nod_start=nod_struct.i
    nod_end=nod_struct.f
    
    datestring=strmid(file_basename(ncdffile),0,8)

    for nod=0,n_nods-1 do begin
        median_ut=$
          median(ticks[nod_start[nod]:nod_end[nod]])/3600.
        if keyword_set(tausmooth) then $
          tau225=tau225smooth(datestring,median_ut) else $
          tau225=median(rpc_params.tau_225)
        median_elev=$
          median(elevation[nod_start[nod]:nod_end[nod]])
        median_airmass_temp=$
          1./sin(median_elev*(!pi/180.))
        trans_this_nod=$
          trans_zspec_fts_incl_airmass(tau225,median_airmass_temp)

        tbath_this_nod1=median(tgrt1[nod_start[nod]:nod_end[nod]])
        tbath_this_nod2=median(tgrt2[nod_start[nod]:nod_end[nod]])
        
        if nod eq 0 then begin
            taus=tau225
            median_airmass=median_airmass_temp
            transmission=trans_this_nod
            t_bath1=tbath_this_nod1
            t_bath2=tbath_this_nod2
        endif else begin
            taus=[taus,tau225]
            median_airmass=[median_airmass,median_airmass_temp]
            transmission=[[transmission],[trans_this_nod]]
            t_bath1=[t_bath1,tbath_this_nod1]
            t_bath2=[t_bath2,tbath_this_nod2]
        endelse
   
    endfor  
;_________________________________________________________________________
;COMPUTE CALIBRATION
    
    spectra_ave,vopt_spectra
    spectra_ave,vopt_psderror
    jy_per_planet=cal_vec(year,month,night,source=source,unit=0)
    calibration_array=spectra_div(vopt_spectra,jy_per_planet*transmission)
    calibration_psderror=spectra_div(vopt_psderror,jy_per_planet*transmission)

;_________________________________________________________________________
;COMPUTE QUADRATURE SUM OF BOLO VOLTAGES

    vbolo_quad=get_quad_sum(year,month,night,obs)
    
;_________________________________________________________________________
;SAVE THESE VARS IN A STRUCTURE TO RETURN
      
return,create_struct('cal',calibration_array.in1.nodspec,$
                     'calerr',calibration_psderror.in1.noderr,$
                     'tau',taus,$
                     'transmission',transmission,$
                     'dc',vbolo_quad,$
                     'source',source)

end
