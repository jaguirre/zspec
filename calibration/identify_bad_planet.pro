; Originally by Edo Ibar, moved to the SVN by JRK on 12/10/12.
;
;
; The output from flux_calibration_wrapper are:
;
; calibration_obs_jan11_fitparams.sav
; calibration_obs_jan11_plot.pdf
; calibration_obs_jan11_plot.ps
; calibration_obs_jan11.sav
;
; The .ps contain a graph for all the bolometers. These are the
;conversion from V_DC to Jy. The fits are used to calibrate the
;normalisation for each bolometer. The .sav files give you the fitted
;parameters and the raw data used for the calibration
;
; Run identify_bad_planet and you will get the numer of times that a scan
; deviates more than 3xsigma from the fitted. In this way, you can
; easily find the scans that tend to give you poor fits. Identify them
; and flag them in the calibration_obs_jan11.txt file and run
; everything again.
;

pro identify_bad_planet

restore, !zspec_pipeline_root+'/calibration/calibration_obs_nov12_fitparams.sav'
;help
;CHI_SQ_VALS     FLOAT     = Array[160, 3]
;CHI_SQ_VALS_ALL DOUBLE    = Array[160]
;FITPARS         FLOAT     = Array[160, 3, 2]
;FITPARS_ALL     DOUBLE    = Array[160, 2]
;RMS_DEV         FLOAT     = Array[160, 3]
;RMS_DEV_ALL     DOUBLE    = Array[160]

restore, !zspec_pipeline_root+'/calibration/calibration_obs_nov12.sav'
;help
;AIRMASS_TOTAL   DOUBLE    = Array[60]
;BINS            UNDEFINED = <Undefined>
;BOLO            UNDEFINED = <Undefined>
;CAL_TOTAL       DOUBLE    = Array[160, 60]
;DATE            STRING    = Array[8]
;ERR_TOTAL       DOUBLE    = Array[160, 60]
;FITPARS_ALL     UNDEFINED = <Undefined>
;FLAG            INT       = Array[10]
;HISTX           UNDEFINED = <Undefined>
;HISTY           UNDEFINED = <Undefined>
;INX_NOISY       UNDEFINED = <Undefined>
;J               UNDEFINED = <Undefined>
;MARS_OBS        INT       =        0
;MEDIAN_CLIP     UNDEFINED = <Undefined>
;NEPTUNE_OBS     INT       =        0
;N_OBS           LONG      =            8
;OBS             STRING    = Array[8]
;PLOTMARS        STRING    = 'none'
;PLOTNEP         STRING    = 'none'
;PLOTURANUS      LONG      = Array[60]
;RMS_DEV_ALL     UNDEFINED = <Undefined>
;SIGMA_CLIP      UNDEFINED = <Undefined>
;SOURCE          INT       = Array[8]
;TAU_TOTAL       DOUBLE    = Array[60]
;TRANSMISSION_TOTAL  FLOAT     = Array[160, 60]
;TTAM            DOUBLE    = Array[60]
;URANUS_OBS      INT       =        1
;VBOLO_QUAD_TOTAL  DOUBLE    = Array[60, 160]
;WHICH_OBS       INT       = Array[60]                             
;X_DC            UNDEFINED = <Undefined>
;Y_V_JY          UNDEFINED = <Undefined>


set_plot, 'x'
;window, 0
;bins = 5.0
;histx = hist_plot_x(CHI_SQ_VALS_ALL, binsize=bins)
;histy = hist_plot_y(CHI_SQ_VALS_ALL, binsize=bins)
;plot, histx, histy

;window, 1
;bins = 0.005
;histx = hist_plot_x(RMS_DEV_ALL, binsize=bins)
;histy = hist_plot_y(RMS_DEV_ALL, binsize=bins)
;plot, histx, histy, xrange=[0,0.1], charsize=2

;print, 'MEDIAN & STDDEV RMS_DEV_ALL', median(RMS_DEV_ALL), stddev(RMS_DEV_ALL)
;print, 'CLIPPED MEAN'
;clipped_stat, RMS_DEV_ALL, 2.75, sigma_clip, median_clip

RMS_stat = RMS_DEV_ALL[where(finite(RMS_DEV_ALL))]

;meanclip, RMS_stat, median_clip, sigma_clip
;meanclip, RMS_stat, median_clip, sigma_clip

median_clip = mean(RMS_stat)
sigma_clip  = stddev(RMS_stat)

;print, sigma_clip, median_clip

;oplot, [1,1]*median_clip, [0,1000], linestyle=2
;oplot, [1,1]*(median_clip-3*sigma_clip), [0,1000], linestyle=1
;oplot, [1,1]*(median_clip+3*sigma_clip), [0,1000], linestyle=1

inx_noisy = where(abs(RMS_DEV_ALL - median_clip) gt 3.0*sigma_clip)

for j=0, n_elements(inx_noisy)-1 do begin
   print, 'Bad bolometers', inx_noisy[j]
endfor

;bolo = 13
bad_obs = intarr(n_elements(VBOLO_QUAD_TOTAL[0,*])*100)
nsig = 3.

kk=0
for k=0, n_elements(VBOLO_QUAD_TOTAL[0,*])-1 do begin
   inx_bad_flag = where(k eq inx_noisy)
   if inx_bad_flag eq [-1] then begin
      bolo = k
;   window, 2
      x_DC   = VBOLO_QUAD_TOTAL[*, bolo] ;V_DC
      y_V_Jy = FITPARS_ALL[bolo,0] +  FITPARS_ALL[bolo,1]*x_DC
      dy_V_Jy = RMS_DEV_ALL[bolo]
;;plot, x_DC, y_V_Jy, xrange=[0.215,0.241], yrange=[2.0,2.5]*10^(-6d), charsize=2
;   plot, x_DC, y_V_Jy, charsize=2, $
;         xrange=[min(VBOLO_QUAD_TOTAL[*, bolo]),max(VBOLO_QUAD_TOTAL[*, bolo])], $
;         yrange=[min(CAL_TOTAL[bolo,*]),max(CAL_TOTAL[bolo,*])]
;   
;   oplot, x_DC, y_V_Jy + (y_V_Jy*dy_V_Jy*3), linestyle=1
;   oplot, x_DC, y_V_Jy - (y_V_Jy*dy_V_Jy*3), linestyle=1
   
;print, FITPARS_ALL[bolo,0], FITPARS_ALL[bolo,1]
;print, y_V_Jy
   
;   oplot, VBOLO_QUAD_TOTAL[*, bolo], CAL_TOTAL[bolo, *], psym=4
;   err_plot, VBOLO_QUAD_TOTAL[*, bolo], $
;             CAL_TOTAL[bolo, *]-ERR_TOTAL[bolo,*], $
;             CAL_TOTAL[bolo, *]+ERR_TOTAL[bolo,*]
;
      inx_caca = where(abs(CAL_TOTAL[bolo, *]-y_V_Jy) gt nsig*y_V_Jy*dy_V_Jy)
;print, inx_caca
      if inx_caca ne [-1] then begin
;      oplot, VBOLO_QUAD_TOTAL[inx_caca, bolo], CAL_TOTAL[bolo, inx_caca], $
;             psym=7, thick=1
;   print, which_obs
;   print, 'Outliers in the calibration distribution:'
;print,  VBOLO_QUAD_TOTAL[inx_caca, bolo], CAL_TOTAL[bolo, inx_caca]
;print, which_obs[inx_caca]
         for i=0, n_elements(inx_caca)-1 do begin
            bad_obs[kk] = obs[which_obs[inx_caca[i]]]
            kk=kk+1
         endfor
;      print, 'Bad_obs', bad_obs[k] 
      endif
   endif
   
endfor
bad_obs = bad_obs[0:kk-1]

print, ''
print, 'Number of outliers per observation'
for j=0, n_elements(obs)-1 do begin
   inx_N_ele = where(bad_obs eq obs[j])
   if inx_N_ele ne [-1] then begin
      print, 'obs & #_failed  ', obs[j], n_elements(inx_N_ele)
   endif else begin
      print, 'obs & #_failed  ', obs[j], 0
   endelse
endfor
;window,3
;plot, VBOLO_QUAD_TOTAL[*, bolo], CAL_TOTAL[bolo, *]-y_V_Jy, psym=4

;print, VBOLO_QUAD_TOTAL[*, bolo]
;print,  CAL_TOTAL[bolo, *]

;bolo = 5 
;print, 'TESTING bolometer bolo'
;print, 'CHI_SQ_VALS',CHI_SQ_VALS[bolo,*]
;print, 'CHI_SQ_VALS_ALL',CHI_SQ_VALS[bolo]
;print, 'FITPARS', FITPARS[bolo,*,*]
;print, 'FITPARS_ALL', FITPARS_ALL[bolo,*]
;print, 'RMS_DEV', RMS_DEV[bolo,*]
;print, 'RMS_DEV_ALL', RMS_DEV_ALL[bolo,*]

end
