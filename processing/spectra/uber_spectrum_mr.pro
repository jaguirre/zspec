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
;KSS 1/12/10: Updated to read in calcorr file.
;KSS 1/13/10: Fixed bug with reading calcorr file.
;KSS 3/39/10: Fixed bug in reading calcorr file when using multiple ones.
;TPEB 5/25/10: Added step to check for the proper number of nods in
;  the input spectra.
;KSS 09/03/10: Added keywords listnum and dateobs_format for ease in
;handling lots of spectra flat data.
;REL 10/18/10: Hacking to work with APEX data. Introduced keywords apex and run.
; apex is just a flag keyword. run must be written as 'E-086.A-0793A-2010',
; or similar project number from the APEX file names

;JRK 10/22/10: Keyword /ignore_cal_corr will make uber_spectrum not
;use the cal_corr corrections at all even if there is a 5th column in
;the coadd list.  Adds "nocalcorr" to filename in that case.
;
;REL 10/23/10: Note for the future: scan numbers get reset on Jan 1st.
; Make sure to account for that in the indexing.
;
;REL 01/03/11: removed the need for the "run" keyword. The tau
;correction is now made for each subscan, using the pwv recorded in
;the ncdf files (from mbfits), and then propagated to the .sav files. Now you can run it without the
;/at_telescope keyword
;
;REL 01/03/11: added badflag variable in the sav files, to exclude
;scans where all subsacans are unusable
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
;   taken under poor tau and the first few channels should be
;   excluded.
;
; CHECK_NODS adds a quick check by printing to the screen the numbner
;   of nods in each of the input spectra save files for comparison
;   with the Observing Logs.  Shouldn't be needed most of the time.
; 
; IGNORE_CAL_CORR forces uber_spectrum to NOT do use the cal_corr
; files even if they are listed in the coadd.  Resulting filename has
; extra suffix _nocalcorr in that case.
;
; BROKEN_DB - hack added by TC to be able to run when the
;             apexSearchScansDB application is dead.  Basically, it
;             assumes the pwv hasn't changed since the last scan in
;             the DB.  Data should get re-processed when the DB is
;             available again.
;______________________________________________________________________
;**********************************************************************

pro uber_spectrum_mr,obs_list,at_telescope=at_telescope,$
                  chop_fudge=chop_fudge,plot_obs=plot_obs,ERRBIN=ERRBIN,$
                  OUTLIERCUT=OUTLIERCUT,message=message,exclude=exclude,$
                  SIGMA_CUT=SIGMA_CUT, NOD_CUT_THRESHOLD = NOD_CUT_THRESHOLD,$
                  SAVENAME = savename, CHECK_NODS = check_nods, $
                  listnum=listnum, dateobs_format=dateobs_format,$
                  apex=apex, run=run, ignore_cal_corr=ignore_cal_corr, $
                  broken_db=broken_db, discard=discard

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
     comment=';',/sil
endif

;_______________________________________________________________________
;READ IN TEXT FILE DEFINING OBSERVATIONS

  file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+obs_list
  ;***ADDED 01/11/10 BY KSS
  ;count the number of columns in the file
  
  tempstruct = read_ascii(file, data_start=4, num_records=1)
  ncol = n_elements(tempstruct.field1)
                                ;if #columns equal to 5, user has
                                ;supplied a calibration correction
                                ;file for spectral flattening, so read
                                ;this in
;chopper phase not needed for uber_spectrum, only run_save_spectra
;For APEX data the obs number is actually the scan number
if keyword_set(apex) then rformat='(a8,a6,i1,a26,a)' else rformat='(a8,a3,i1,a26,a)'
if keyword_set(apex) then rformat2='(a8,a6,i1)' else rformat2='(a8,a3,i1)'
if (ncol eq 5) then readcol,file,date,obs,flag,chop_file,cal_corr_file,$
    format=rformat,comment=';',/sil $
  else readcol,file,date,obs,flag,chop_file,format=rformat2,comment=';',/sil

if keyword_set(ignore_cal_corr) then cal_corr_file=0

;  stop;***
  readcol,file,header,format='(a)',comment=';',/sil

  source_name=header[0] & z=header[1]

  ;just coadd/calibrate one observation?
  if keyword_set(listnum) then begin
      date = date[listnum-1]
      obs = obs[listnum-1]
      flag = flag[listnum-1]
      chop_file = chop_file[listnum-1]
      if keyword_set(cal_corr_file) then $
        cal_corr_file = cal_corr_file[listnum-1]
  endif

  n_obs=n_e(date)

  ;break up the date into year, month, night        
     a=0L & b=0L & c=0L
     year=strarr(n_obs) & month=year & night=year
     for i=0, n_obs-1 do begin
       reads,date[i],a,b,c,format='(a4,a2,a2)'
       year[i]=a & month[i]=b & night[i]=c
     endfor

     ;only use observations flagged 1
     wantdata=where(flag eq 1, n_obs)
     if (n_obs eq 0) then begin
         message, /cont, 'No good observations found. Quitting...'
         return
     endif
     year=year(wantdata)
     month=month(wantdata)
     night=night(wantdata)
     obs=obs(wantdata)
     chop_file=chop_file[wantdata]
     if keyword_set(cal_corr_file) then cal_corr_file=cal_corr_file[wantdata]

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
;    device,/portrait,filename=psfile,/inches,/color,$
;      xsize=7.5, ysize=10.5, xoffset=0.5, yoffset=0.5
    device, filename=psfile, /color, /landscape, /inches
    !p.multi=[0,1,3]
    nu=freqid2freq()

endif

;_______________________________________________________________    
;CHECK TO MAKE SURE DEMODULATED DATA FILES EXIST

     file_list=strarr(n_obs)
     if ~keyword_set(apex) then ncfile_list=strarr(n_obs)
     for i=0,n_obs-1 do begin
         ;do not want nc files for APEX data; but check for .sav files
         if ~keyword_set(apex) then begin
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
             stop
         endif
;;END CSO data start APEX
	endif else begin
	xmain_data_dir = !zspec_data_root + PATH_SEP()
                                ; JRK 10/21/10 - don't use date string
                                ;                from file b/c of UT/filedir ambiguity
;xdate_str = STRING(year[i], F='(I04)') + STRING(month[i], F='(I02)') + STRING(night[i], F='(I02)')
	xobs_str = STRING(obs[i], F='(I05)')
	;scannostr = string(obs,format='(I5)')
;	save_spectra_file= file_search(xmain_data_dir + xdate_str +
;	PATH_SEP() + 'APEX-'+obs[i]+'*'+'-'+run +'-'+ STRING(year[i],
;	F='(I04)')+ '_spec.sav')
	;save_spectra_file= file_search(
        fsrch=xmain_data_dir + 'apexnc/*/APEX-'+obs[i]+'*_spec.sav';)
	spawn,'ls '+fsrch,save_spectra_file
        if (save_spectra_file(0) eq '') then begin
	print,'Cannot find save_spectra file for scan '+obs[i];+' in '+xdate_str
	print,'When processing APEX data, please run *zapex* on all observations first, or whatever the newest incarnation of *save_spectra* is!...'
	stop
	endif
	endelse


         
         file_list[i]=save_spectra_file
         if ~keyword_set(apex) then ncfile_list[i]=ncfile
     endfor
;;check again for bad scans in APEX data
if keyword_set(apex) then begin
    flagobs=intarr(n_obs)
    for i=0,n_obs-1 do begin    ;loop over all observations
                restore,file_list[i]
                if badflag then begin
                    flagobs(i)=1
                    print,'Excluded file '+file_list[i]
                endif
    endfor
uobs=where(flagobs ne 1,n_obs)
oldlist=file_list
file_list=oldlist(uobs)
endif


;_________________________________________________________________________
;SHOVE THEM ALL TOGETHER

     print,'Performing uber-concatenation....'

     ;keep track of how many observations in each nod & total time
        nods_in_obs=intarr(n_obs)
        total_n_sec=0.


        ;; Debugging step -- check to see that the # of nods reported
        ;;                   match the value in the observing log!
        ;;                   -- TPEB 5/25/10
        IF KEYWORD_SET( check_nods ) THEN BEGIN
            for i=0,n_obs-1 do begin ;loop over all observations
                restore,file_list[i]
                nods_in_obs[i]=n_e(vopt_spectra.in1.nodspec[0,*])
            endfor
            message,string(obs_list,format="('For observations in ',A0)"),/inf
            print,nods_in_obs
            
            message,'Type .continue to continue with the processing...',/inf
            STOP
        ENDIF
        

        for i=0,n_obs-1 do begin  ;loop over all observations

            restore,file_list[i]
            
            nods_in_obs[i]=n_e(vopt_spectra.in1.nodspec[0,*])
            total_n_sec+=n_sec
            flagsinobs=bytarr(160,nods_in_obs[i])+1
         
            ;get transmission
                nod_start=nod_struct.i
                nod_end=nod_struct.f
                run=strmid(file_list[i],26,18,/reverse_offset)
                if ~keyword_set(apex) then datestring=strmid(file_basename(ncfile_list[i]),0,8)
		if ~keyword_set(apex) then vdc='N/A'
                if ~keyword_set(apex) then ticks=read_ncdf(ncfile_list[i],'ticks') else ticks=nc_ticks
                if ~keyword_set(apex) then elevation=read_ncdf(ncfile_list[i],'elevation') else elevation=nc_elevation
          
                for nod=0,nods_in_obs[i]-1 do begin

                    if (keyword_set(at_telescope)) then begin
                        if ~keyword_set(apex) then thistau_temp = median(rpc_params.tau_225) else begin
;;the values for each scan are in the observing logs, but a pain to read in
			;;read in pwv  from .dat files and use pwv2tau
readcol,'/home/zspec/data/obs_logs/zspec_search_'+run+'.dat',xa,xb,xc,xd,xe,xf,xg,xh,xi,xj,format='(A19,A18,L5,A13,A6,A5,A7,A5,A4,F4.2)',/sil
wtau=where(xc eq obs[i])
if wtau(0) ne -1 then begin
    thistau_temp=pwv2tau(xj(wtau(0))) 
    lasttau_temp = thistau_temp
endif else begin 
    if keyword_set(broken_db) then begin
        thistau_temp = lasttau_temp
    endif else begin
        print,'Scan number not found for computing tau. Make sure to copy the latest logs.'
    endelse
endelse
;sstop
			endelse
                    endif else begin
;;;ugh, need to fix this for APEX...
                        if ~keyword_set(apex) then begin
                            median_ut=median(ticks[nod_start[nod]:nod_end[nod]])/3600.
                            thistau_temp=tau225smooth(datestring,median_ut) 
                        endif else thistau_temp=pwv2tau(nc_pwv[nod])
;print,'This part of tau calculation is not yet functional.'
;print,'Please use the keyword \at_telescope.'
;finally, we have the pwv in the sav files!                    
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
                ;***ADDED 01/11/10 BY KSS
                ;if cal_corr_file is provided, use it, otherwise don't
              if keyword_set(cal_corr_file) then begin
                  newcalstruct=get_cal(fix(year[i]),fix(month[i]), $
                                       fix(night[i]),fix(obs[i]), $
                                       cal_corr_file=cal_corr_file[i],apex=apex,vdc=vdc)
                  numnods=nods_in_obs[i]
                  newcal=dblarr(160,numnods,2)
                  tempvec=replicate(1.d,numnods) 
                  newcal[*,*,0]=newcalstruct.cal#tempvec
                  newcal[*,*,1]=newcalstruct.rmsdev#tempvec  
              endif else begin             ;***
                  newcalstruct=get_cal(fix(year[i]),fix(month[i]),$
                                       fix(night[i]),fix(obs[i]),apex=apex,vdc=vdc)
                  numnods=nods_in_obs[i] ;***
                  newcal=dblarr(160,numnods,2)
                  newcal[*,*,0]=newcalstruct.cal
                  tempvec=replicate(1.d,numnods)
                  newcal[*,*,1]=newcalstruct.rmsdev#tempvec
              endelse        
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

             if ~keyword_set(apex) then obs_id=strmid(file_basename(ncfile_list[i]),0,12) else obs_id=STRING(obs[i], F='(I05)')
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
;plot,freqid2freq(),uber_spectra.in1.noderr[*,0],/xlog,/ylog,/xst,/yst
;oplot,freqid2freq(),uber_psderror.in1.noderr[*,0],psym=3

;for kk=1,n_elements(uber_spectra.in1.noderr[0,*])-1 do begin
;oplot,freqid2freq(),uber_spectra.in1.noderr[*,kk],color=kk mod 5
;oplot,freqid2freq(),uber_psderror.in1.noderr[*,kk],color=kk mod 5,psym=3

;end

;stop
;;;;;;;;;;;;;;;;;;
;________________________________________________________________________
;now average over all the nods & take out bad nods

if keyword_set(discard) then begin
    uber_spectra=discardnods3(uber_spectra)
    uber_psderror=discardnods3(uber_psderror)
endif

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
if keyword_set(listnum)+keyword_set(dateobs_format) eq 2 then begin
    if keyword_set(apex) then suffix=string(date,obs,format='(I8,"_",I05)') $
      else suffix=string(date,obs,format='(I8,"_",I03)')
endif else begin
    suffix=string(now[0],now[1],now[2],now[3],now[4],$
                  format='(i4,i2.2,i2.2,"_",i2.2,i2.2)')
endelse

ubername=want_dir+source_name+'_'+suffix+'.sav'

timestamp=suffix

if keyword_set(ignore_cal_corr) then ubername=change_suffix(ubername,'_nocalcorr.sav')

save,uber_spectra,uber_psderror,transmission_total,$
  total_n_sec,tau_total,ubername,uber_airmass,$
  file_list,source_name,uber_bolo_flags,z,obs_labels,$
  outliercut,errbin,timestamp,message,uber_excl_flags,filename=ubername
print,'Spectra saved at '+change_suffix(ubername,'.sav')+'.'

IF ARG_PRESENT(savename) THEN $
    savename = change_suffix(ubername,'.sav')

end
