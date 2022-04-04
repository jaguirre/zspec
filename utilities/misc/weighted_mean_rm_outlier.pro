;THIS FUNCTION IS NO LONGER IN USE
;It was replaced in spectra_ave by making a mask separately
;and then using weighted_mean.
;JRK 3/13/09

FUNCTION weighted_mean_rm_outlier, values, sigmas, currmask, ERRBIN = ERRBIN, WEIGHTS_OUT=weights_ind,$
     SIGMA_CUT=SIGMA_CUT,OUTLIERCUT=OUTLIERCUT
IF N_E(values) NE N_E(sigmas) THEN $
  MESSAGE, /INFO, 'Values & sigmas have different numbers' + $
  ' of elements - this may give weird behavior'

; Edit to original /utilities/misc/weighted_mean
; JRK 2/1/09
; 
; Now, before calculating the weighted average, any
; data points 3 sigma away from the mean of all nods
; is discarded to avoid completely skewing a bin.
; 
; EDIT 3/6/09 - Fixed bug where if all points in a bin were removed,
; the whole channel becomes NaN.  Those bins are now discarded.




;-------------------------------------------------------------
; OUTLIERCUT = 1 CASE: REMOVE 3 SIGMA OUTLIERS

;if outliercut EQ 1 then begin
  mean=MEAN(values)
  stdev=STDDEV(values)
  
  bad=WHERE(ABS(values-mean) GT sigma_cut*stdev, nbad)  
   
  IF nbad NE 0 THEN BEGIN
    values[bad]=!VALUES.D_NAN
    sigmas[bad]=!VALUES.D_NAN
  ENDIF
  
;  currmask= 
  
;endif
  
;-------------------------------------------------------------
; OUTLIERCUT = 2 CASE: RECURSIVELY REMOVE 3 SIGMA OUTLIERS
  
;  goodmask=rm_outlier(values,sigma_cut,currmask,

;-------------------------------------------------------
; Ready to do averaging
; Calculate bin values
weights_ind=fltarr(n_e(values))
IF KEYWORD_SET(ERRBIN) THEN BEGIN
    nsigmas = N_E(sigmas)
    IF ERRBIN GT nsigmas THEN ERRBIN = nsigmas
    IF nsigmas MOD ERRBIN NE 0 THEN $
      MESSAGE, /INFO, 'Error Bin Size not commensurate with' + $
      ' number of elements in sigmas - proceed with caution'
    nbins = FLOOR(nsigmas/ERRBIN)
    binvalues = DBLARR(nbins)
    binvar = DBLARR(nbins)
    FOR bin = 0, FLOOR(nsigmas/ERRBIN) - 1 DO BEGIN ;should be nbins
        binvalues[bin] = MEAN(values[ERRBIN*bin:ERRBIN*bin+ERRBIN-1],/NAN)
        binvar[bin] = MEDIAN(sigmas[ERRBIN*bin:$
                                    ERRBIN*bin+ERRBIN-1]^2,/EVEN)/ERRBIN
        weights_ind[ERRBIN*bin:ERRBIN*bin+ERRBIN-1] = 1.D/binvar[bin]
    ENDFOR
    ; REMOVE any bins that had all points removed.
    goodbin=WHERE(binvalues EQ binvalues,ngoodbin)
    binvalues=binvalues[goodbin]
    binvar=binvar[goodbin]
    nbins=ngoodbin
ENDIF ELSE BEGIN
    binvalues = values
    binvar = sigmas^2
ENDELSE
weights = (1.D/binvar)/TOTAL(1.D/binvar)
weights_ind=weights_ind / TOTAL(1.D/binvar)
IF KEYWORD_SET(WEIGHTS_OUT) $
  THEN RETURN,TOTAL(weights * binvalues,weights_out=weights_ind) $
else RETURN,TOTAL(weights * binvalues)

END
