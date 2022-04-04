;written by LE
;
;Modified by MB August 2008, to carry keyword ERRBIN which is fed to
;spectra_ave to determine the weights.  Default is 10.
;
;Modified by JRK March 2009: keyword outliercut is fed to spectra_ave
;to determine how to deal with outliers.  See below.
;
;JRK 4/16/09: Files are now saved to 
;/zspec_svn/processing/spectra/coadded_spectra/SOURCE_NAME/.
;Also, timestamp, errbin, and outlier cut are included in .sav file.
;Optional keyword message saves a string to the .sav file.
;
;JRK 5/18/09: You can now exclude entire channels from certain observations.
;See keyword "EXCLUDE" below.
;
;LE 6/25/09: obs_labels is a new structure with 2 tags:
;
; obs_labels.names = vector of length equal to total number of nods in
; the observations list, and each element is a date/obs# ID correponding to
; each nod
;
; obs_labels.nnods = vector of length equal to number of observations,
; and each element containing the number of nods in the corresponding
; observation
;
; Observations whose flags are set to '0' in the coadd list are excluded.
;
;JRK 7/21/09: outliercut and sigma_cut are both 2 element vectors to
; be passed into spectra_ave.
;
;_____________________________________________________________________
;*********************************************************************
;This routine calibrates and coadds a list of observations, which can
;be from different observing runs.  It creates a savefile of the
;coadded spectrum and its errors.  The routine plot_uber_spectrum can
;then be used to plot the results.
;
;;OBS_LIST is a text file, created in
;;zspec_svn/processing/spectra/coadd_lists (see UGC5101_spr07.txt for
;;example),defining which observations to use
;'
;KEYWORDS
;
; AT_TELESCOPE bypasses the tau225smooth step and simply uses the
; median tau reported in the rpc data.  This is appropriate for use
; during observing runs when the svn archive has not yet been updated
; with the necessary tau data files from the CSO.
;
; CHOP_FUDGE settting this keyword will multiply the demodulated
; signal amplitudes by a factor of chop_fac (which comes from
; save_spectra).
;
; PLOT_OBS setting this keyword to a postscript filename plots each
; observation going into the coadd separately. This is just to have a
; visual of all the spectra going in.  Plotting of the resulting coadd
; has to be done separately, using plot_uber_spectrum.pro.
;
; OUTLIERCUT is a 2 element vector of integers telling spectra_ave how to 
;    deal with outliers for the preliminary and final cuts, in that order.
;    The default for both is 2.
;    0 = Do not cut any outlying nods.  Use all nods in weighted average.
;    1 = Cut out 3 sigma outliers with one pass.
;    2 = Recursively cut out 3 sigma outliers until none are left to be cuts
;
; SIGMA_CUT is a 2 element vector of explaining the sigma level at which
;    to cut outliers in spectra_ave for the preliminary and final cuts, respectively.
;    The default is [10,3].  The first one should be at least > 5.
;
; NOD_CUT_THRESHOLD is a fractional value that represents the
;    percentage of channels needed to mark a nod as bad for all
;    channels.  For example, if NOD_CUT_THRESHOLD is set to 0.1, then
;    if a nod is flagged as bad in more than 16 bolometers, then it is
;    flagged out for all bolometers in the final co-add.
;    Investigation with Jan09 M82 data suggested that 0.1 is a good
;    value for this but it is off by default.  BJN suggests further 
;    investigation before turning it on by default.
;
; EXCLUDE is a text file in the coadd_lists folder which contains 3 columns: 
;   observation date, observation ID, and channel ID number (starting at 0).
;   All observations/channels in this list will be excluded from the final 
;   coadd by being set to NaN before being passed into spectra_ave.  
;   Example of a good use: when a few of the observations in a coadd were
;   taken under poor tau and the first few channels should be excluded.
;______________________________________________________________________
;**********************************************************************

pro uber_spectrum,obs_list,at_telescope=at_telescope,$
                  chop_fudge=chop_fudge,plot_obs=plot_obs,ERRBIN=ERRBIN,$
                  OUTLIERCUT=OUTLIERCUT,message=message,exclude=exclude,$
                  SIGMA_CUT=SIGMA_CUT, NOD_CUT_THRESHOLD = NOD_CUT_THRESHOLD

;_______________________________________________________________________
;APPLY DEFAULTS IF KEYWORDS NOT SET (ERRBIN done later)

if ~keyword_set(message) then message=''

if ~keyword_set(OUTLIERCUT) then OUTLIERCUT=[2,2]

if ~keyword_set(SIGMA_CUT) then SIGMA_CUT=[10,3]

;_______________________________________________________________________
;READ IN TEXT FILE DEFINING OBSERVATIONS/CHANNELS TO EXCLUDE

if keyword_set(exclude) then begin
  excl_file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+exclude
  readcol,excl_file,excl_date,excl_obs,excl_id,format='(a8,a3,i3)',$
     comment=';'
endif

;_______________________________________________________________________
;READ IN TEXT FILE DEFINING OBSERVATIONS

  file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+obs_list
;if no_cal_corr then readcol,file,date,obs,flag,format='(a8,a3,i1)',$  


  readcol,file,date,obs,flag,chop_file,cal_corr_file,format='(a8,a3,i1,a26,a)',$
    comment=';'
  ; above changed december 1, 2009, MB
  
  readcol,file,header,format='(a)',comment=';'

  source_name=header[0] & z=header[1]

  n_obs=n_e(date)

  ;break up the date into year, month, night        
     a=0L & b=0L & c=0L
     year=strarr(n_obs) & month=year & night=year
     for i=0, n_obs-1 do begin
       reads,date[i],a,b,c,format='(a4,a2,a2)'
       year[i]=a & month[i]=b & night[i]=c
     endfor

     ;only use observations flagged 1
     wantdata=where(flag eq 1)
     n_obs=n_e(wantdata)
     year=year(wantdata)
     month=month(wantdata)
     night=night(wantdata)
     obs=obs(wantdata)
     cal_corr_file=cal_corr_file(wantdata)

;______________________________________________________________
;CREATE SOURCE DIRECTORY IF NECESSARY 

want_dir=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+source_name+'/'
test=file_search(want_dir)
if (test eq '') then spawn, 'mkdir '+want_dir

;______________________________________________________________
;SET UP DEVICE FOR PLOTTING EACH OBSERVATION IS KEYWORD IS SET

if keyword_set(plot_obs) then begin

cleanplot

    psfile=want_dir+plot_obs
    set_plot,'ps'
    device,/portrait,filename=psfile,/inches,/color,$
      xsize=7.5, ysize=10.5, xoffset=0.5, yoffset=0.5
    !p.multi=[0,1,3]
    nu=freqid2freq()

endif

;_______________________________________________________________    
;CHECK TO MAKE SURE DEMODULATED DATA FILES EXIST

     file_list=strarr(n_obs)
     ncfile_list=strarr(n_obs)
     for i=0,n_obs-1 do begin
         
         ncfile=get_ncdfpath(year[i],month[i],night[i],obs[i])
         
         ;gunzip netCDF file if necessary
         zippedfile=ncfile+'.gz'
         maligned=file_search(ncfile)
         zipped=file_search(zippedfile)
         if maligned eq '' and zipped eq zippedfile then begin
             print,'Gunzipping....'
             spawn,'gunzip '+zippedfile
         endif

         save_spectra_file=change_suffix(ncfile,'_spectra.sav')
         test_nc=file_search(save_spectra_file)
         if (test_nc eq '') then begin
             print,'Cannot find: '+save_spectra_file+'.'
             print,'Please run save_spectra on all observations first!'
             stop
         endif
         file_list[i]=save_spectra_file
         ncfile_list[i]=ncfile
     endfor

;_________________________________________________________________________
;SHOVE THEM ALL TOGETHER

     print,'Performing uber-concatenation....'

     ;keep track of how many observations in each nod & total time
        nods_in_obs=intarr(n_obs)
        total_n_sec=0.

        for i=0,n_obs-1 do begin  ;loop over all observations

            restore,file_list[i]
            nods_in_obs[i]=n_e(vopt_spectra.in1.nodspec[0,*])
            total_n_sec+=n_sec
            flagsinobs=bytarr(160,nods_in_obs[i])+1
         
            ;get transmission
                nod_start=nod_struct.i
                nod_end=nod_struct.f
         
                datestring=strmid(file_basename(ncfile_list[i]),0,8)

                ticks=read_ncdf(ncfile_list[i],'ticks')
                elevation=read_ncdf(ncfile_list[i],'elevation')
          
                for nod=0,nods_in_obs[i]-1 do begin

                    median_ut=$
                      median(ticks[nod_start[nod]:nod_end[nod]])/3600.
                    if (keyword_set(at_telescope)) then begin
                        thistau_temp = median(rpc_params.tau_225)
                    endif else begin
                        thistau_temp=tau225smooth(datestring,median_ut)
                    endelse
                    median_elev=$
                      median(elevation[nod_start[nod]:nod_end[nod]])
                    median_airmass_temp=1./sin(median_elev*(!pi/180.))
                    trans_this_nod=$
                      trans_zspec_fts_incl_airmass(thistau_temp,median_airmass_temp)

                    if nod eq 0 then begin
                        thistau=thistau_temp
                        median_airmass=median_airmass_temp
                        transmission=trans_this_nod
                    endif else begin
                        thistau=[thistau,thistau_temp]
                        median_airmass=[median_airmass,median_airmass_temp]
                        transmission=[[transmission],[trans_this_nod]]
                    endelse

                endfor  ;end of loop over all nods in this observation
                ;now we have the transmission for each nod for this observation

            ;get calibration for each nod for this observation 
                newcalstruct=$
;                  get_cal(fix(year[i]),fix(month[i]),fix(night[i]),fix(obs[i]))
                get_cal(fix(year[i]),fix(month[i]),fix(night[i]),fix(obs[i]),cal_corr_file=cal_corr_file[i])
     ;           numnods=n_e(newcalstruct.cal[0,*])
                numnods=nods_in_obs[i]
                newcal=dblarr(160,numnods,2)
                tempvec=replicate(1.d,numnods) 
;               newcal[*,*,0]=newcalstruct.cal
                newcal[*,*,0]=newcalstruct.cal#tempvec
                newcal[*,*,1]=newcalstruct.rmsdev#tempvec              
;;;  MB made change in the above to get this to work 
       
            ;divide by calibration
                vopt_spectra=spectra_div(vopt_spectra,newcal)
                vopt_psderror=spectra_div(vopt_psderror,newcal)

            ;divide by transmission
                vopt_spectra=spectra_div(vopt_spectra,transmission)
                vopt_psderror=spectra_div(vopt_psderror,transmission)

            ;multiply by scaling factor if keyword is set
                if keyword_set(chop_fudge) then begin
                    factor=replicate(1./chop_fac,160)
                    vopt_spectra=spectra_div(vopt_spectra,factor)
                    vopt_psderror=spectra_div(vopt_spectra,factor)
                endif

            ;plot this spectrum if keyword plot_obs is set
                if keyword_set(plot_obs) then begin
                    spectra_ave,vopt_spectra
                    spectra_ave,vopt_psderror
                    plot,nu,vopt_psderror.in1.avespec,$
                      /yno,/yst,tit=strcompress(file_list[i]),$
                      ytit='Flux Density [Jy]',$
                      xtit=textoidl('\nu [GHz]'),$
                      xthick=3,ythick=3,charthick=3,$
                      charsize=1.5,/nodata
                    oploterror,nu,vopt_psderror.in1.avespec,$
                      vopt_psderror.in1.aveerr,psym=10,$
                      col=2,errcol=4,thick=3,errthick=1
                      
                endif
                
            ; Setup a flag for channels that should be excluded from text file.
            ; 0 means keep, 1 means exclude because this is flagging the excluded ones.
                excl_flags=INTARR(nbolos,nods_in_obs[i])
                if keyword_set(exclude) then begin
                   ; First see if this date and observation is flagged
                   whereisdate=WHERE(excl_date EQ datestring,nwhereisdate)
                   whereisobs=WHERE(excl_obs EQ obs[i],nwhereisobs)
                   match,whereisdate,whereisobs,date_id,obs_id,count=nmatch
                   ; If it is, continue...
                   if nmatch GT 0 then begin  ; If there are channels to exclude.
                      matchrows=whereisdate[date_id]
                      channelstoexcl=excl_id[matchrows]
                      excl_flags[channelstoexcl,*]=1
                   endif
                endif ; if exclude was set
                                 

            ;concatenate the arrays    
             if i eq 0 then begin
                uber_spectra=vopt_spectra
                uber_bolo_flags=bolo_flags
                transmission_total=transmission
                tau_total=thistau
                uber_psderror=vopt_psderror
                uber_airmass=median_airmass
                uber_excl_flags=excl_flags   ; New addition
             endif else begin
                uber_spectra=$
                  combine_spectra(uber_spectra,vopt_spectra)
                uber_bolo_flags*=bolo_flags
                transmission_total=[[transmission_total],[transmission]]
                tau_total=[tau_total,thistau]
                uber_psderror=$
                  combine_spectra(uber_psderror,vopt_psderror)
                uber_airmass=[uber_airmass,median_airmass]
                uber_excl_flags=[[uber_excl_flags],[excl_flags]]   ; New addition
             endelse                

             obs_id=strmid(file_basename(ncfile_list[i]),0,12)
             if i eq 0 then begin
                 names=replicate(obs_id,nods_in_obs[i])
                 nods_in_obs_arr=nods_in_obs[i]
             endif else begin
                 names=[names,replicate(obs_id,nods_in_obs[i])]
                 nods_in_obs_arr=[nods_in_obs_arr,nods_in_obs[i]]
             endelse
                
         endfor                 ;loop over all observations

obs_labels=create_struct('names',names,$
                         'nnods',nods_in_obs)


;ntotal=n_e(uber_spectra.in1.nodspec[0,*])
;tags=tag_names(uber_spectra) & ntags=n_tags(uber_spectra)
;subtags=tag_names(uber_spectra.(0)) & n_subtags=n_tags(uber_spectra.(0))
;for tag=0,ntags-1 do begin
;    for subtag=0,n_subtags-1 do begin
;        if subtag eq 0 then temp=create_struct(subtags[subtag],uber_spectra.(tag).(subtag))
;        else temp=create_struct(temp,subtags[subtag],uber_spectra.(tag).(subtag))
;    end
;    temp=create_struct(temp,'weights',fltarr(ntotal
;    temp=create_struct(subtags[0],uber_spectra.(tag).(0)
;temp_str=create_struct(uber_spectra.in1,'weights',fltarr(160,ntotal))
;temp_uber_spectra=create_struct(


;;;;;;;;;;;;;;;;;;;;;
;; MB DEBUGGING HERE
plot,freqid2freq(),uber_spectra.in1.noderr[*,0],/xlog,/ylog,/xst,/yst
oplot,freqid2freq(),uber_psderror.in1.noderr[*,0],psym=3

for kk=1,n_elements(uber_spectra.in1.noderr[0,*])-1 do begin
oplot,freqid2freq(),uber_spectra.in1.noderr[*,kk],color=kk mod 5
oplot,freqid2freq(),uber_psderror.in1.noderr[*,kk],color=kk mod 5,psym=3

end






;stop
;;;;;;;;;;;;;;;;;;
;________________________________________________________________________
;now average over all the nods & take out bad nods

if ~keyword_set(ERRBIN) then ERRBIN=obs_labels.nnods

spectra_ave,uber_spectra,ERRBIN=errbin,OUTLIERCUT=outliercut,$
            EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=SIGMA_CUT,$
            NOD_CUT_THRESHOLD = NOD_CUT_THRESHOLD ;,WEIGHTS_OUT=WEIGHTS_OUT

;weights_out_spec=weights_out
uber_spectra.in1.avespec*=uber_bolo_flags
;stop
spectra_ave,uber_psderror,ERRBIN=errbin,OUTLIERCUT=outliercut,$
            EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=SIGMA_CUT,$
            NOD_CUT_THRESHOLD = NOD_CUT_THRESHOLD ;,WEIGHTS_OUT=WEIGHTS_OUT
;weights_out_psd=weights_out
uber_psderror.in1.avespec*=uber_bolo_flags

;totalnods=n_e(uber_spectra.in1.nodspec[0,*])

;STOP

;________________________________________________________________________
;CLOSE OUT THE DEVICE IF PLOTTING WAS DONE

if keyword_set(plot_obs) then begin

    !p.multi=0
    device,/close
    set_plot,'x'

print,'Individual observations are plotted at:'
print,psfile

cleanplot

endif

;_________________________________________________________________________
;create save file of all of the above

now=bin_date(systime(0,/utc))
suffix=string(now[0],now[1],now[2],now[3],now[4],$
              format='(i4,i2.2,i2.2,"_",i2.2,i2.2)')

ubername=want_dir+source_name+'_'+suffix+'.sav'

timestamp=suffix

save,uber_spectra,uber_psderror,transmission_total,$
  total_n_sec,tau_total,ubername,uber_airmass,$
  file_list,source_name,uber_bolo_flags,z,obs_labels,$
  outliercut,errbin,timestamp,message,uber_excl_flags,filename=ubername
print,'Spectra saved at '+change_suffix(ubername,'.sav')+'.'

end
