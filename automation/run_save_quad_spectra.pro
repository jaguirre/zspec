;Created 2007 05 02 by LE

;Run_save_spectra can be used in 2 ways:
;
; 1) run save_spectra on observations listed in a .txt file.  Make
; this file in zspec_svn/processing/spectra/coadd_lists/ and set
; keyword obs_list='YOURLIST.txt'  See UGC5101.txt for sample.  It
; will automatically check for and gunzip and gzipped netCDF files as
; needed. Obsnum_start & obsnum_end are optional if you want to start
; or end somewhere in the middle of the list.  If it can't find the
; netCDF file it will skip that one and tell you at the end which ones
; were skipped.
;
; 2) The keyword /cont let you run save_spectra continuously to
; demodulate new observations as they become available.  Must specify
; date keyword as 'YYYYMMDD' to use /cont. You must specify the 
; rel_phase to be either 0 (no correction), 1 (compute based on obs),
; a rel_phase array (computed from another observation), or a 
; 'YYYYMMDD_###_chopphase.sav' filename containing rel_phase.
;________________________________________________________________

; HISTORY 05 JUN 07 BN Added _EXTRA keyword to pass keywords to save_spectra
;                      Don't use DEGLITCH which is automatically set.

pro run_save_quad_spectra, rel_phase=rel_phase, cont=cont, obs_list=obs_list,$
                           obsnum_start=obsnum_start,$
                           obsnum_end=obsnum_end,date=date, $
                           _EXTRA = EXTRA
                    

case 1 of 
    keyword_set(cont): begin

        ;break up date into YYYY, MM, DD
          year=0L & month=0L & night=0L
          reads,date,year,month,night,format='(a4,a2,a2)'

        if keyword_set(obsnum_end) then obs_end=obsnum_end else obs_end=999
        if keyword_set(obsnum_start) then obsnum=obsnum_start else obsnum=0
        carry_on=1
        
        ;get rel_phase
        if rel_phase ne [0] and rel_phase ne [1] then begin
            rel_size=size(rel_phase)
            if rel_size[1] eq 7 and rel_size[2] eq 1 then begin
            rel_file=!zspec_data_root+'/ncdf/'+strcompress(date)+$
              '/'+rel_phase
            restore,rel_file
            endif
        endif
        rel_phase_local = rel_phase ; use this to retain rel_phase after
                                    ; calls to save_spectra

        while (carry_on) do begin
            print,'Looking for observation '+strcompress(obsnum,/rem)          
            ncdf_file=get_ncdfpath(year,month,night,obsnum)
            this_obs_file=ncdf_file
            if file_search(this_obs_file) ne '' then begin
                print,'Demodulating observation # '+strcompress(obsnum,/rem)
                rel_phase = rel_phase_local 
                mogul=save_quad_spectra(year,month,night,obsnum,rel_phase,$
                                   /deglitch, _EXTRA = EXTRA)
                if obsnum eq obs_end then begin
                    print,'Demodulated observations '+$
                          strcompress(obsnum_start,/rem)+$
                      ' through '+strcompress(obsnum,/rem)
                    carry_on=0
                endif
                obsnum = obsnum + 1
            endif else begin
                message,/info,'No new files.  Waiting 15 seconds.'
                message,/info,'Current observation is '+strcompress(obsnum,/rem)
                wait,15

            endelse
        endwhile

    end ;end of 1st case (/cont)

    keyword_set(obs_list): begin
        
        if ~keyword_set(obsnum_start) then $
           obs_start=0 $
        else obs_start=obsnum_start
       
        ;read text file here
          file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+$
            obs_list
          readcol,file,date,obs,flag,rel_file,format='(a8,a3,i1,a30)'
          readcol,file,header,format='(a)'
          source=header[0] & z=header[1]
          n_obs=n_e(date)

        ;break up the date into year, month, night        
          a=0L & b=0L & c=0L
          year=strarr(n_obs) & month=year & night=year
          for i=0, n_obs-1 do begin
              reads,date[i],a,b,c,format='(a4,a2,a2)'
              year[i]=a & month[i]=b & night[i]=c
          endfor

        ;now run save_spectra on all of them
          missing_ncdf_list=[' ']
          first_one_done=0
          for i=obs_start,n_obs-1 do begin
              if flag[i] eq 1 then begin
                  ;check to make sure netCDF file exists
                  ncdf_file=get_ncdfpath(year[i],month[i],night[i],obs[i])
                  maligned=file_search(ncdf_file)
                  if maligned eq '' then begin
                      zippedmaligned=file_search(ncdf_file+'.gz')
                      if zippedmaligned eq '' then begin
                          print,'Cannot find netCDF file for '+$
                            strcompress(date,/rem)+' Obs # '+$
                            strcompress(obs[i],/rem)
                          print,'Please malign'
                          missing_ncdf_list=[missing_ncdf_list,ncdf_file]
                      endif else begin
                          goto,demod
                      endelse
                  endif else begin
                      demod:
                      mogul=save_quad_spectra(year[i],month[i],night[i],$
                                              obs[i],rel_file[i],$
                                 /deglitch, _EXTRA = EXTRA)
                  endelse
              endif
          endfor
          if n_e(missing_ncdf_list) gt 1 then begin
              print, 'The following files are missing and could not be demodulated:'
              print,missing_ncdf_list
          endif

    end
endcase

end
