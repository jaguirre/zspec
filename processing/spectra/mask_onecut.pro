FUNCTION mask_onecut,values,sigma_cut,MEDIAN = MEDIAN

;+
; NAME:
;   MASK_ONECUT
;
; PURPOSE:
;   Create a mask to indicate where data is still good after one pass
;   of outlier removal.
;
; CALLING SEQUENCE:
;   mask_onecut,values,sigma_cut
;
; INPUTS:
;   values = vector (length nnods) of nod values for specific channel.
;   sigma_cut = multiple of standard deviation beyond which points
;      will be cut.  spectra_ave feeds a default of 3.
;
; KEYWORDS:
;   MEDIAN = set this keyword to mask based on the median of values
;      rather than the (arithmetic) mean
;
; OUTPUTS:
;   goomask is an nnods length array with 1 where the points are good
;   and 0 where the points are bad.
;     
; PROCEDURE:
;   Calculate mean and standard deviation, flag as "bad" all indices
;   where the absolute value of the difference from mean is greater than
;   sigma_cut*sigma.  The of goodmask at these indices then become 0.
;
; MODIFICATION HISTORY:
;    Written by JRK 3/13/09
;    Added /NaN keywords 5/19/09.  NaNs are also masked as 0.
;    7/20/09 BJN Added MEDIAN keyword to mask based on median instead
;                of mean
;-

  npts=n_e(values)
  goodmask=REPLICATE(1.0,npts)
  IF ~KEYWORD_SET(MEDIAN) THEN $
     mean=MEAN(values,/NaN) $
  ELSE mean = MEDIAN(values,/EVEN)
  stdev=STDDEV(values,/NaN)
  
  ;Calculate bad indices.
  bad=WHERE(ABS(values-mean) GT sigma_cut*stdev, nbad)  
  
  ;Set goodmask to 0 at bad indices.
  IF nbad GT 0 then goodmask[bad]=0
  ;Also set goodmask to 0 if /NaNs were fed in.
  NaNs=WHERE(values NE values,nNaNs)
  If nNaNs GT 0 then goodmask[NaNs]=0
  
 
  RETURN,goodmask

END
