pro make_coadd_cso, list_file_name, MS_decorr=MS_decorr, plotfile=plotfile, t_shift=t_shift, $
                savefile=savefile,ignore_cal_corr=ignore_cal_corr, $
                re_save=re_save, diagnostics=diagnostics, $
                plot_obs=plot_obs, outflag=outflag,test_gausses=test_gausses,$
                zemcov=zemcov, noderr_flag=noderr_flag,$
                errflag=errflag, flag_gauss=flag_gauss, $
                poly_subtract=poly_subtract, PCA_decorr=PCA_decorr, filt=filt


coadd_file=file_search(!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+$
                       list_file_name)

if strtrim(coadd_file[0]) eq '' then begin
    print, list_file_name+': No such coadd list'
    return
endif

openr, unit, coadd_file, /GET_LUN

while ~eof(unit) do begin

    line=''
    readf, unit, line
    split=strsplit(line, ' '+string(9b), /extract)

    if n_e(split) lt 3  then continue else begin
    
        date=''
        scan_str=''
        flag=0
        phase=''
        
        date=split[0]  
        scan_str=split[1]
        flag=long(split[2])
        phase=split[3]
            
        year=long(strmid(date, 0,4))
        month=long(strmid(date, 4, 2))
        night=long(strmid(date,6,2))
        scan=long(scan_str)

        if phase ne 1 then begin
            phase_date=strmid(phase, 0,8)
            phase_year=long(strmid(phase_date, 0,4))
            phase_month=long(strmid(phase_date, 4, 2))
            phase_night=long(strmid(phase_date, 6,2))
            phase_scan=long(strmid(phase_date, 10,2))
        endif
        
        if flag then begin
            
            
            s=file_search(!zspec_data_root+'/ncdf/'+date+'/'+date+'_0'+scan_str+'_spectra.sav')
            
            if ~keyword_set(re_save) and s[0] ne '' then continue        
            
            if phase eq 1 then a=save_spectra(year, month, night, scan, 1,  $
              MS_decorr=MS_decorr, PCA_decorr=PCA_decorr, filt=filt) else begin
                
                phase_file = file_search(strcompress(!zspec_data_root+'/ncdf/'+phase_date+'/'+phase))
                if phase_file eq '' then begin
                    a=save_spectra(phase_year, phase_month, phase_night, phase_scan, 1)
                endif 
              
                a=save_spectra(year, month, night, scan, phase,MS_decorr=MS_decorr, PCA_decorr=PCA_decorr, filt=filt)
            endelse 
        endif  
  
    endelse     
endwhile

catch, /cancel
close, unit
free_lun, unit

customName=''
if keyword_set(noderr_flag) then customName+='_noderr_flag'
if keyword_set(zemcov) then customName+='_zemcov'
if keyword_set(MS_decorr) then customName+='_MS'
if keyword_set(quad) then customName+='_quad'
if keyword_set(outflag) then customName+='_outflag'
if keyword_set(errflag) then customName+='_errflag'
if keyword_set(flag_gauss) then customName+='_flag_gauss'
if keyword_set(PCA_decorr) then customName+='_PCA'

uber_spectrum, list_file_name, /corr, savefile=savefile,test_gausses=test_gausses,$
  ignore_cal_corr=ignore_cal_corr, diagnostics=diagnostics,  $
  plot_obs=plot_obs, zemcov=zemcov,  noderr_flag=noderr_flag, $
  outflag=outflag,errflag=errflag,customName=customName, flag_gauss=flag_gauss,$
  poly_subtract=poly_subtract, MS_decorr=MS_decorr, PCA_decorr=PCA_decorr

if ~keyword_set(plotfile) then begin
    a=strsplit(savefile, './', /extract)
    plotfile=a[1]
    ;if keyword_set(decorr) then plotfile+='_decorr'
    plotfile+='.eps'
endif

plot_uber_spectrum_jk, savefile, plotfile, /plot_sig, /plot_sens

end
