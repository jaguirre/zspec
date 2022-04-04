; Computes weighted mean of values using variance based weighting,
; where the weights can be binned based on the value of ERRBIN.  Equal
; sized bins are used if ERRBIN is a single value, or variable sized
; bins can be used if ERRBIN is a vector with sequential bins whose
; widths are given by the elements in ERRBIN.  The weights used are
; returned in the keyword WEIGHTS_OUT.

; EDIT JRK 3/13: Remove any bins that have had all points removed.
;                Added /NaN keyword to MEAN.

; 2009_07_02 BJN Updated to use new binning and weight computing
;                functions.  Also fixed weird code relating to
;                returning the weights used in keyword WEIGHTS_OUT.

FUNCTION weighted_mean, values, sigmas, ERRBIN = ERRBIN, $
                        WEIGHTS_OUT = WEIGHTS_OUT
  IF N_E(values) NE N_E(sigmas) THEN $
     STOP, 'Values & sigmas have different numbers' + $
           ' of elements - this is not correct.  STOPPING.'
  WEIGHTS_OUT = compute_weights(sigmas, ERRBIN = ERRBIN)
  RETURN, weighted_mean_input_weights(values, WEIGHTS_OUT)
END

; This code stays in this file for historical reasons.  The new code
; should do (basically) the same thing but we'll keep the old
; code just in case.

;; weights_ind=fltarr(n_e(values))
;; IF KEYWORD_SET(ERRBIN) THEN BEGIN
;;     nsigmas = N_E(sigmas)
;;     IF ERRBIN GT nsigmas THEN ERRBIN = nsigmas
;;     IF nsigmas MOD ERRBIN NE 0 THEN $
;;       MESSAGE, /INFO, 'Error Bin Size not commensurate with' + $
;;       ' number of elements in sigmas - proceed with caution'
;;     nbins = FLOOR(nsigmas/ERRBIN)
;;     binvalues = DBLARR(nbins)
;;     binvar = DBLARR(nbins)
;;     FOR bin = 0, FLOOR(nsigmas/ERRBIN) - 1 DO BEGIN ;should be nbins
;;         binvalues[bin] = MEAN(values[ERRBIN*bin:ERRBIN*bin+ERRBIN-1],/NAN)
;;         binvar[bin] = MEDIAN(sigmas[ERRBIN*bin:$
;;                                     ERRBIN*bin+ERRBIN-1]^2,/EVEN)/ERRBIN
;;         weights_ind[ERRBIN*bin:ERRBIN*bin+ERRBIN-1] = 1.D/binvar[bin]
;;     ENDFOR
;;     ; REMOVE any bins that had all points removed.
;;     goodbin=WHERE(binvalues EQ binvalues,ngoodbin)
;;     binvalues=binvalues[goodbin]
;;     binvar=binvar[goodbin]
;;     nbins=ngoodbin
;; ENDIF ELSE BEGIN
;;     binvalues = values
;;     binvar = sigmas^2
;; ENDELSE
;; weights = (1.D/binvar)/TOTAL(1.D/binvar)
;; weights_ind=weights_ind / TOTAL(1.D/binvar)
;; IF KEYWORD_SET(WEIGHTS_OUT) $
;;   THEN RETURN,TOTAL(weights * binvalues,weights_out=weights_ind) $
;; else RETURN,TOTAL(weights * binvalues)

;; END
