FUNCTION mask_recursive, values, sigma_cut, MEDIAN = MEDIAN, QUIET=QUIET

;+
; NAME:
;   MASK_RECURSIVE
;
; PURPOSE:
;   Create a mask to indicate where data is still good after recursively
;   removing outliers.
;
; CALLING SEQUENCE:
;   mask_recursive,values,sigma_cut
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
;   The procedure is largely grabbed from Bret's rm_outlier.pro, except
;   no verbose output of how many points were cut (spectra_ave.pro takes 
;   care of that) and no averaging at the end.  
;
; MODIFICATION HISTORY:
;    Written by JRK 3/13/09
;    Added /NaN keywords 5/19/09
;    7/20/09 BJN Added MEDIAN keyword to mask based on median instead
;                of mean
;    10/1/09 BJN Fixed bug where masked values in the original input
;                would not be reflected in the output mask under
;                certain circumstances. 
;    12/7/12 JRK Added keyword /quiet.
;    12/19/2012 KSS - Committed revisions to svn
;-


  ;; Set up variable for recursive glitch finding loop
  data = values
  
  npts = N_ELEMENTS(data)
  ngoodpts = LONG(0)
  goodmask = REPLICATE(1,npts)

; Check for NaNs in values and incorporate into goodmask
  nan_inds = WHERE(FINITE(values, /NAN) EQ 1, nan_count)
  IF nan_count NE 0 THEN goodmask[nan_inds] = 0
  IF nan_count EQ npts THEN RETURN, goodmask

  data = data[WHERE(goodmask EQ 1)]
  ncurrpts = N_ELEMENTS(data)
  
  ;; add a recursion failsafe
  nloop = 0
  totalloops = 50
  
  WHILE ((ngoodpts LT ncurrpts) AND (nloop LT totalloops)) DO BEGIN
     nloop = nloop + 1
     ncurrpts = N_ELEMENTS(data)
     
     ;; First compute mean & stddev
     IF ~KEYWORD_SET(MEDIAN) THEN $
        ave = MEAN(data,/NaN) $
     ELSE ave = MEDIAN(data,/EVEN)
     
     ;; Get good points
     IF ncurrpts EQ 1 THEN BEGIN
        if ~keyword_set(quiet) then begin
        MESSAGE, /INFO, 'Only one good point remaining in loop ' + $
                 STRING(nloop,F='(I0)')
        MESSAGE, /INFO, 'Unable to to do further sigma based cuts'
        MESSAGE, /INFO, 'Returning original data'
        endif
        data = values
        goodmask = REPLICATE(1,npts)
        IF nan_count NE 0 THEN goodmask[nan_inds] = 0
        BREAK
     ENDIF ELSE BEGIN
        sigma = STDDEV(data,/NaN)
        goodpts = WHERE(ABS(data - ave) LT sigma_cut*sigma, ngoodpts)
     ENDELSE
     
     ;; Check to make sure there are some good points
     IF (ngoodpts EQ 0) THEN BEGIN
        if ~keyword_set(quiet) then begin
        message, /info, 'No good data points remain in loop ' + $
                 STRING(nloop, F = '(I0)')
        message, /info, 'Returning original data'
        endif
        data = values
        goodmask = REPLICATE(1,npts)
        IF nan_count NE 0 THEN goodmask[nan_inds] = 0
        BREAK
     ENDIF ELSE BEGIN
        ;; Set goodflags to 0 where there are bad points
        IF (ngoodpts LT ncurrpts) THEN BEGIN
           temp = INTARR(ncurrpts)
           temp[goodpts] = 1
           goodmask[WHERE(goodmask EQ 1)] = temp
        ENDIF
        ;; Prepare for next iteration
        data = data[goodpts]
     ENDELSE
  ENDWHILE
  
   RETURN, goodmask
END
