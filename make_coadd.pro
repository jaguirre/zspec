pro make_coadd, list_file_name, MS_decorr=MS_decorr, plotfile=plotfile, t_shift=t_shift, $
                savefile=savefile,ignore_cal_corr=ignore_cal_corr, $
                re_zapex=re_zapex,$
                plot_obs=plot_obs, outflag=outflag,test_gausses=test_gausses,$
                zemcov=zemcov, noderr_flag=noderr_flag,$
                errflag=errflag, flag_gauss=flag_gauss, $
                poly_subtract=poly_subtract, PCA_decorr=PCA_decorr, $
                re_convert=re_convert, filt=filt


;coadd_file=file_search(!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+$
;                       list_file_name)

coadd_file=file_search(!zspec_results_root+'/coadd_lists/'+list_file_name)

if keyword_set(re_convert) then re_zapex=1

if strtrim(coadd_file[0]) eq '' then begin
    print, list_file_name+': No such coadd list'
    return
endif

tempname='temp_'+repstr(systime(), ' ', '_')+'.txt'
openr, unit, coadd_file, /GET_LUN
openw, unit2, tempname, /get_lun

while ~eof(unit) do begin

    line=''
    readf, unit, line
    pos=strpos(line, '201')
    if pos[0] eq -1 then  printf, unit2, line else begin
    
        date=0l
        scan=0l
        flag=0
        phase=0l
        extra=''
        
        a=strsplit(line, ' '+string(9b))
        if n_e(a) eq 4 then reads, line, date, scan, flag, phase $
        else reads, line, date, scan, flag, phase, extra
    
        split=strsplit(line, ' '+string(9b), /extract)
        date=split[0]
       
       ;catch, error_status
       ; if error_status ne 0 then begin
            
       ;     printf, unit2, string(date)+string(9b) +'  '+ strcompress(string(scan), /remove_all)$
       ;       +'  0'+string(phase)+extra
       ;    continue
       ; endif
        
        
        if flag then begin
                        
            s=file_search(!zspec_data_root+'/apexnc/*/APEX-'+strcompress(string(scan), /remove_all)+$
                          '-*_spec.sav')
            if ~keyword_set(re_zapex) and s[0] ne '' then begin
                printf, unit2, $
                  string(date)+string(9b) +'  '+ strcompress(string(scan), /remove_all)$
                  +'  1'+string(phase)+extra
                continue
            endif else begin

                if keyword_set(re_convert) then begin
                    fits=file_search(!zspec_data_root+'/mbfits/APEX-'+strcompress(string(scan), /remove_all)+$
                                     '-*')
                    spawn, 'convert_fits_netcdf.py '+fits[0]+' ~/data/observations/apexnc'
                endif
                
                if phase eq 1 then zapex, scan, 1, 2, $
                  MS_decorr=MS_decorr, PCA_decorr=PCA_decorr, filt=filt else begin
                    
                    
                    phase_file = file_search(strcompress(!zspec_data_root+'/apexnc/*/APEX-'$
                                                         +string(phase)+'-*chopphase.sav',/remove_all))
                    
                    if phase_file eq '' then begin
                        zapex, phase, 1, 2
                        phase_file = file_search(strcompress(!zspec_data_root+'/apexnc/*/APEX-'$
                                                             +string(phase)+'-*chopphase.sav',/remove_all))
                    endif
                    
                    
                    phase_file=strsplit(phase_file, '/', /extract)
                    phase_file=phase_file[n_e(phase_file)-1]
                    
                    oldphase=phase
                    
                    zapex, scan, phase, 2, quad=quad, MS_decorr=MS_decorr, PCA_decorr=PCA_decorr, filt=filt, status=status
                    if status eq 0 then begin
                        printf, unit2, string(date)+string(9b) +'  '+ strcompress(string(scan), /remove_all)$
                          +'  0'+string(phase)+extra
                    endif else printf, unit2, string(date)+string(9b) +'  '+ strcompress(string(scan), /remove_all)$
                      +'  1'+string(oldphase)+extra
                endelse
            endelse
        endif      

        a=file_search(strcompress(!zspec_data_root+'/apexnc/*/APEX-'$
                                  +string(scan)+'-*_spec.sav',/remove_all)) 

        ;if a[0] eq '' then printf, unit2, string(date) + string(scan)+string(0)+$
        ;  string(phase)+extra $
        ;else printf, unit2, line
        
    endelse    
    heap_gc
endwhile

catch, /cancel
close, unit
close, unit2
free_lun, unit
free_lun, unit2

spawn, 'mv '+tempname+' ' + !zspec_results_root+'/coadd_lists/'+ $;!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+$
  list_file_name
spawn, 'rm '+tempname


customName=''
if keyword_set(noderr_flag) then customName+='_noderr_flag'
if keyword_set(zemcov) then customName+='_zemcov'
if keyword_set(MS_decorr) then customName+='_MS'
if keyword_set(quad) then customName+='_quad'
if keyword_set(outflag) then customName+='_outflag'
if keyword_set(errflag) then customName+='_errflag'
if keyword_set(flag_gauss) then customName+='_flag_gauss'
if keyword_set(PCA_decorr) then customName+='_PCA'

uber_spectrum, list_file_name, /apex, /corr, savefile=savefile,test_gausses=test_gausses,$
  ignore_cal_corr=ignore_cal_corr, $
  plot_obs=plot_obs, zemcov=zemcov,  noderr_flag=noderr_flag, $
  outflag=outflag,errflag=errflag,customName=customName, flag_gauss=flag_gauss,$
  poly_subtract=poly_subtract, MS_decorr=MS_decorr, PCA_decorr=PCA_decorr

if ~keyword_set(plotfile) then begin
    a=strsplit(savefile, './', /extract)
    plotfile=a[1]
    if keyword_set(decorr) then plotfile+='_decorr'
    plotfile+='.eps'
endif

plot_uber_spectrum_jk, savefile, plotfile, /plot_sig, /plot_sens

end
