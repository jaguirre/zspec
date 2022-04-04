;_________________________________________________________________
;*****************************************************************
;
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
;resulting plot is color and symbol coded by planet and mean GRT
;temperature per nod
;
;if keyword /compute is not used it will simply restore the sav file
;created from the last instance this routine was run on that
;particular list of calibration observations (cal_file) and plot the
;results.
;
;___________________________________________________________________
;******************************************************************

pro flux_calibration_plots,cal_file,compute=compute,sky=sky

cal_file=!zspec_pipeline_root+'/calibration/'+cal_file

savefilename=change_suffix(cal_file,'.sav')

;__________________________________________________________________
;BEGIN CALCULATIONS

if keyword_set(compute) then begin

;_________________________________________________________________
;READ IN TEXT FILE DEFINING WHICH CALIBRATION OBSERVATIONS TO USE

  file=cal_file
  readcol,file,date,obs,planet,flag,format='(a8,a3,a,i1)'
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
    temps=fltarr(n_e(obs))

;_________________________________________________________________
;RESTORE DEMODULATED DATA FILE AND FIND APPROPRIATE NETCDF FILE

for i=0,n_obs-1 do begin

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

    ;restore spectra.sav file

    restore, file    

    case planet[i] of
        'Mars': source[i]=0
        'Uranus': source[i]=1
        'Jupiter': source[i]=2
        'Neptune': source[i]=3
    endcase

;_____________________________________________________________________
;READ IN GRT TEMPERATURES FROM NETCDF FILE

;************GRT temps showing weirdo sinusoidal shape*************
;*************just using average for now***************************

    ;read GRT temp info and average over observation
    t=get_temps(ncdffile)
    temps[i]=(mean(t.grt1)+mean(t.grt2))/2.
    
;___________________________________________________________________________
;GET TAU, AIRMASS, & EMISSIVITY  INFORMATION FOR EACH NOD

    ticks=read_ncdf(ncdffile,'ticks')
    elevation=read_ncdf(ncdffile,'elevation')
    tbath=get_temps(ncdffile)

    nod_start=nod_struct.i
    nod_end=nod_struct.f
    
    datestring=strmid(file_basename(ncdffile),0,8)

    for nod=0,n_nods-1 do begin

        median_ut=$
          median(ticks[nod_start[nod]:nod_end[nod]])/3600.
        thistau_temp=tau225smooth(datestring,median_ut)
        median_elev=$
          median(elevation[nod_start[nod]:nod_end[nod]])
        median_airmass_temp=$
          1./sin(median_elev*(!pi/180.))
        trans_this_nod=$
          trans_zspec_fts_incl_airmass(thistau_temp,median_airmass_temp)

        tbath_this_nod1=median(tbath.grt1[nod_start[nod]:nod_end[nod]])
        tbath_this_nod2=median(tbath.grt2[nod_start[nod]:nod_end[nod]])
        tbath_this_nod=(tbath_this_nod1+tbath_this_nod2)/2.
        
        if nod eq 0 then begin
            thistau=thistau_temp 
            median_airmass=median_airmass_temp
            transmission=trans_this_nod
            t_bath=tbath_this_nod
        endif else begin
            thistau=[thistau,thistau_temp]
            median_airmass=[median_airmass,median_airmass_temp]
            transmission=[[transmission],[trans_this_nod]]
            t_bath=[t_bath,tbath_this_nod]
        endelse
   
    endfor

    if i eq 0 then begin
        tau_total=thistau
        airmass_total=median_airmass
        transmission_total=transmission
        t_bath_total=t_bath
    endif else begin
        tau_total=[tau_total,thistau]
        airmass_total=[airmass_total,median_airmass]
        transmission_total=[[transmission_total],[transmission]]
        t_bath_total=[t_bath_total,t_bath]
    endelse
   
;_________________________________________________________________________
;COMPUTE CALIBRATION
    
    spectra_ave,vopt_spectra
    jy_per_planet=cal_vec(year[i],month[i],night[i],source=source[i],unit=0)
    calibration_array=spectra_div(vopt_spectra,jy_per_planet)          
    calibration_array_sky=spectra_div(calibration_array,transmission)

    if i eq 0 then begin
        cal_total=calibration_array.in1.nodspec
        cal_total_sky=calibration_array_sky.in1.nodspec
        err_total=calibration_array.in1.noderr
        err_total_sky=calibration_array_sky.in1.nodspec
    endif else begin
        cal_total=[[cal_total],[calibration_array.in1.nodspec]]
        cal_total_sky=[[cal_total_sky],[calibration_array_sky.in1.nodspec]]
        err_total=[[err_total],[calibration_array.in1.noderr]]
        err_total_sky=[[err_total_sky],[calibration_array_sky.in1.noderr]]
    endelse

;_________________________________________________________________________
;COMPUTE QUADRATURE SUM OF BOLO VOLTAGES

    vbolo_quad=get_quad_sum(year[i],month[i],night[i],obs[i])
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
;CREATE SAV FILE OF ABOVE DATA OR RESTORE EXISTING ONE

save,date,obs,source,flag,n_obs,temps,cal_total,t_bath_total,$
  vbolo_quad_total,which_obs,tau_total,airmass_total,ttam,$
  transmission_total,cal_total_sky,err_total,err_total_sky,$
  filename=savefilename,/verbose

endif else  restore,savefilename  ;if keyword /compute is not used

;_________________________________________________________________________
;PLOT

set_plot,'ps'
!p.multi=[0,1,2]

if keyword_set(sky) then begin
  filename=!zspec_pipeline_root+'/calibration/spring07_fluxcal_plots_skycorr.ps'
  yaxist='V/Jy!Ccorrected for sky transmission'
  cal_to_plot=cal_total_sky
endif else begin
  filename=!zspec_pipeline_root+'/calibration/spring07_fluxcal_plots.ps'
  yaxist='V/Jy'
  cal_to_plot=cal_total
endelse

device,file=filename,/color,/portrait,xsize=7.5,ysize=8,/inches,$
  xoffset=0.5,yoffset=0.5

for bolo=0,159 do begin

         pagetitle='Freq ID '+strcompress(bolo)+'!C'
           
         
;mV/Jy versus dc voltage on top half of page

        ;create axes
          plot,vbolo_quad_total[*,bolo],$
            cal_to_plot[bolo,*],/yno,/nodata,$
            title=pagetitle,xtit='Bolometer DC Voltage',$
            ytit=yaxist,$
            thick=2.5,charthick=2.5,charsize=1.5,$
            min_value=0

          xyouts,0.2,0.91,'Mars',col=2,/normal,charsize=1.2
          xyouts,0.2,0.89,'Uranus',col=3,/normal,charsize=1.2
          xyouts,0.2,0.87,'Neptune',col=4,/normal,charsize=1.2

          temp_labels=[ $
              textoidl('75 mK < T_{GRT} \leq 77 mK'),$
              textoidl('77 mK < T_{GRT} \leq 79 mK'),$               
              textoidl('79 mK < T_{GRT} \leq 81 mK'),$ 
              textoidl('81 mK < T_{GRT} \leq 83 mK'),$
              ;textoidl('83 mK < T_{GRT} \leq 85 mK'),$ 
              textoidl('85 mK < T_{GRT} \leq 87 mK'),$ 
              ;textoidl('87 mK < T_{GRT} \leq 89 mK'),$ 
              textoidl('89 mK < T_{GRT} \leq 91 mK')]
              ;textoidl('91 mK < T_{GRT} \leq 93 mK')]

        ;oplot each observation

          for obsnum=0,n_obs-1 do begin
              
              plotdata=where(which_obs eq obsnum)
              
              ;color-code by planet
              case source[obsnum] of 
                  0:rangi=2
                  1:rangi=3
                  2:rangi=5
                  3:rangi=4
              endcase

              ;symbol-code by temperature
              case 1 of 
                  temps[obsnum] gt 0.075 and temps[obsnum] le 0.077:sym=1
                  temps[obsnum] gt 0.077 and temps[obsnum] le 0.079:sym=2
                  temps[obsnum] gt 0.079 and temps[obsnum] le 0.081:sym=4
                  temps[obsnum] gt 0.081 and temps[obsnum] le 0.083:sym=5
                  ;temps[obsnum] gt 0.083 and temps[obsnum] le 0.085:sym=1
                  temps[obsnum] gt 0.085 and temps[obsnum] le 0.087:sym=6
                  ;temps[obsnum] gt 0.087 and temps[obsnum] le 0.089:sym=2
                  temps[obsnum] gt 0.089 and temps[obsnum] le 0.091:sym=7
                  ;temps[obsnum] gt 0.091 and temps[obsnum] le 0.093:sym=4
              endcase

              oplot,vbolo_quad_total[plotdata,bolo],$
                cal_to_plot[bolo,plotdata],col=rangi,psym=sym

          endfor

;mV/Jy  versus tau*airmass on bottom half of page 
          
        ;create axes
          plot,ttam[*],$
            cal_to_plot[bolo,*],/yno,/nodata,$
            xtit=textoidl('\tau_{225GHz} x airmass'),$
            ytit=yaxist,$
            thick=2.5,charthick=2.5,charsize=1.5,$
            min_value=0,xrange=[0.22,0.05],/xst,symsize=1.2

          legend,temp_labels,psym=[1,2,4,5,6,7],charsize=0.8,$
            charthick=2.0

        ;oplot each observation

          for obsnum=0,n_obs-1 do begin
              
              plotdata=where(which_obs eq obsnum)
              
              ;color-code by planet
              case source[obsnum] of 
                  0:rangi=2
                  1:rangi=3
                  2:rangi=5
                  3:rangi=4
              endcase

              ;symbol-code by temperature
              case 1 of 
                  temps[obsnum] gt 0.075 and temps[obsnum] le 0.077:sym=1
                  temps[obsnum] gt 0.077 and temps[obsnum] le 0.079:sym=2
                  temps[obsnum] gt 0.079 and temps[obsnum] le 0.081:sym=4
                  temps[obsnum] gt 0.081 and temps[obsnum] le 0.083:sym=5
                  ;temps[obsnum] gt 0.083 and temps[obsnum] le 0.085:sym=1
                  temps[obsnum] gt 0.085 and temps[obsnum] le 0.087:sym=6
                  ;temps[obsnum] gt 0.087 and temps[obsnum] le 0.089:sym=2
                  temps[obsnum] gt 0.089 and temps[obsnum] le 0.091:sym=7
                  ;temps[obsnum] gt 0.091 and temps[obsnum] le 0.093:sym=4
              endcase

              oplot,ttam[plotdata],$
                cal_to_plot[bolo,plotdata],col=rangi,psym=sym

          endfor

endfor

!p.multi=0
device,/close
set_plot,'x'

stop

end
