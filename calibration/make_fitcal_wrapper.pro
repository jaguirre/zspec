;see https://casa.colorado.edu/zspec_wiki/index.html/SpectralFlats for
;information on how to use this. Will write a proper header one day.

;Created 09/06/10 by KSS.
; 09/06/10 - KSS - Fixed minor bugs with count # of observations and
;            array indices.
;                - Fixed so that correction for flagged channels is 1.0

pro make_fitcal_wrapper, coadd_list, at_telescope=at_telescope, $
                         plot_obs=plot_obs, $
                         skip_save_spectra=skip_save_spectra, $
                         skip_uber_spectrum=skip_uber_spectrum, $
                         skip_fit=skip_fit, $
                         version_num=version_num, $
                         flags=flags, nthresh=nthresh, $
                         mean_calfile_basename=mean_calfile_basename, $
                         flag_bolo_obs=flag_bolo_obs, $
                         boloind=boloind, obsind=obsind

;initial setup
coadd_list_fp = !zspec_pipeline_root+'/processing/spectra/coadd_lists/'+coadd_list
coadd_spectra_path = !zspec_pipeline_root+'/processing/spectra/coadded_spectra/'
calcorr_path = !zspec_pipeline_root+'/calibration/cal_corr_files/'
if not keyword_set(version_num) then version_num=1

;define addtional things
ts = read_ascii(coadd_list_fp, data_start=4)
nobs = n_e(ts.field1[0,*])
readcol, coadd_list_fp, header, format='(a)', comment=';'
spectra_dir = header[0]

    ;Step 1, run save_spectra on each observation
if not keyword_set(skip_save_spectra) then $
  run_save_spectra, obs_list=coadd_list

    ;Step 2, run uber_spectrum separately on each individual spectrum
if not keyword_set(skip_uber_spectrum) then begin
    
                                ;first, verify that there aren't any
                                ;.sav files in output directory, since
                                ;this will mess things up
    ftest = findfile(coadd_spectra_path+spectra_dir+'/*.sav')
    if strcmp(ftest[0], '') ne 1 then message, 'ERROR! coadded spectra already exist in '+coadd_spectra_path+spectra_dir+'/. Quitting...'

    for i = 0, nobs-1 do begin
        uber_spectrum, coadd_list, at_telescope=at_telescope, $
          listnum=i+1, /dateobs_format
    endfor

        ;rename files
    f2m = findfile(coadd_spectra_path+spectra_dir+'/*.sav')
    f2m2 = repstr(f2m, '.sav', '_naive'+strn(version_num)+'.sav')
    file_move, f2m, f2m2, /overwrite
    nobs = n_e(f2m)

    ;and plot them up?
    if keyword_set(plot_obs) then begin
        for i = 0, nobs-1 do begin
            sfsplit = strsplit(f2m2[i], '/', /extract, count=cc)
            sftemp = sfsplit[cc-1]
            pftemp = repstr(sftemp, '.sav', '.ps')
            plot_uber_spectrum_ks, spectra_dir+'/'+sftemp, pftemp
        endfor
    endif

endif

    ;Step 3, fit continuum to spectra
spectra_sav = findfile(coadd_spectra_path+spectra_dir+'/*_naive'+strn(version_num)+'.sav')
nobs = n_e(spectra_sav) ;now excludes flagged observation in coadd_list
nbolo = 160
if not keyword_set(flags) then flags = intarr(nbolo)+1
spectra_fit = repstr(spectra_sav, 'naive', 'fit')
if not keyword_set(skip_fit) then begin
    ;loop over all observations
    for i = 0, nobs-1 do begin
        restore, spectra_sav[i]
        spec = uber_psderror.in1.avespec
        err = uber_psderror.in1.aveerr
        fit = zspec_fit_lines_cont(flags, spec, err, $
                                   0.0, '12CO', '2-1', $
                                   cont_type='PWRLAW', $
                                   lw_value=300.0, lw_tied=1, lw_fixed=1, $
                                   z_tied=1, z_fixed=1)
        save, filename=spectra_fit[i], fit
    endfor

    ;Step 4, run make_fitcal.pro
    ;loop over all observations
    for i = 0, nobs-1 do begin
        fnsplit = strsplit(spectra_sav[i], '_', /extract, count=cc)
        date = fnsplit[cc-3]
        obs = fnsplit[cc-2]
        make_fitcal, spectra_dir, date, obs, index=strn(version_num)
    endfor
endif

;Step 5, compile all information, compute and save mean from all observations
calcorr_sav = repstr(spectra_sav, coadd_spectra_path+spectra_dir+'/', $
                     calcorr_path)
calcorr_sav = repstr(calcorr_sav, 'naive', '')
calcorr_sav = repstr(calcorr_sav, '.sav', '_calcor.sav')
;loop over all obs
relfac_all = dblarr(nbolo, nobs)
for i = 0, nobs-1 do begin
    restore, calcorr_sav[i]
    relfac_all[*,i] = discrepancy
endfor
;mean corrections
mean_relfac = dblarr(nbolo)
std_relfac = dblarr(nbolo)
for j = 0, nbolo-1 do begin
    ;flag bad observations for this bolometer
    obs_flag = intarr(nobs)+1
    if keyword_set(flag_bolo_obs) then begin
        whbb = where(flag_bolo_obs[0,*] eq j, ccb)
        if (ccb gt 0) then begin
            whbo = reform(flag_bolo_obs[1,whbb])
            obs_flag[whbo] = 0
        endif
    endif
    whgood = where(obs_flag eq 1)
    mean_relfac[j] = mean(relfac_all[j,whgood])
    std_relfac[j] = stddev(relfac_all[j,whgood])
endfor
perr_relfac = 100*std_relfac/mean_relfac
;set flagged bolos to correction of 1
whbad = where(flags eq 0, nbad)
if (nbad gt 0) then begin
    mean_relfac[whbad] = 1.0
    std_relfac[whbad] = 0.0
    perr_relfac[whbad] = 0.0
endif

;save it
discrepancy = mean_relfac
if not keyword_set(mean_calfile_basename) then $
  mean_calfile_basename = 'MEAN'
avecal_sav = !zspec_pipeline_root+'/calibration/cal_corr_files/'+mean_calfile_basename+'_'+strn(version_num)+'_calcor.sav'
save, filename=avecal_sav, discrepancy

;Step 6, plot for diagostic purposes, and print results to screen
set_plot, 'ps'
avecal_ps = repstr(avecal_sav, '.sav', '.ps')
device, filename=avecal_ps, /color, bits=8, xsize=8, ysize=4, /inches

plot, indgen(nbolo), relfac_all[*,0], subtitle=' ', charsize=1.0, $
  /nodata, xtitle='Channel #', ytitle='Correction Factor', $
  title='Bin-to-Bin Correction Factors', /ynoz, $
  xr=[-1, nbolo], yr=[0.9,1.1], /yst, /xst
for i = 0, nobs-1 do $
  oplot, indgen(nbolo), relfac_all[*,i], psym=1,color=2
oplot, indgen(nbolo), mean_relfac, psym=7, color=300
errplot, indgen(nbolo), mean_relfac-std_relfac, mean_relfac+std_relfac, $
  color=3

device, /close

;results
gind = where(flags eq 1, complement=bind)
print, 'GOOD Channels: Min, Median, Max % variance = ', $
  min(perr_relfac[gind]), median(perr_relfac[gind]), max(perr_relfac[gind])
print, 'GOOD Channels: Min, Max Correction = ', $
  min(mean_relfac[gind]), max(mean_relfac[gind])

boloind = -1
obsind = -1
nsigma_outlier = -1
if not keyword_set(nthresh) then nthresh = 5.0
for j = 0, nbolo-1 do begin
    if flags[j] eq 1.0 then begin
        whout = where(reform(relfac_all[j,*]) lt $
                      (mean_relfac[j]-nthresh*std_relfac[j]) or $
                      reform(relfac_all[j,*]) gt $
                      (mean_relfac[j]+nthresh*std_relfac[j]), nout)
        if (nout gt 0) then begin
            boloind = [boloind, replicate(j, nout)]
            obsind = [obsind, whout]
            nsigma_outlier = [nsigma_outlier, $
                              (reform(relfac_all[j,whout])-mean_relfac[j]) / $
                              std_relfac[j]]
        endif
    endif
endfor
if (n_e(boloind) gt 1) then begin
    print, 'Channel    Observation    Nsigma'
    for k = 1, n_e(boloind)-1 do print, boloind[k], obsind[k], nsigma_outlier[k]
    boloind = boloind[1:*]
    obsind = obsind[1:*]
endif

end
