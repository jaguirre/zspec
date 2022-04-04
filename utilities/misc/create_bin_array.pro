; This function takes inputs of a number of elements (n_ele) and bin
; size(s) (binsize) and returns a vector of bins for grouping the
; elements.  binsize can be either a single value or a vector.  A
; single value binsize creates equal sized bins, except for the last
; bin which is adujsted to match n_ele.  If binsize is less than 1, an
; error is issued.  If binsize is a vector, it is checked to make sure
; it is a logical binning of n_ele (i.e. TOTAL(binsize) = n_ele) and
; returned as the bin size array.

; 2009_07_02 BJN Initial Version

FUNCTION create_bin_array, n_ele, binsize
; Check if binsize is a single value or vector
; If binsize is a single value then create CEIL(FLOAT(n_ele)/binsize)
; equal sized bins, trimming the last bin in case n_ele/binsize is not
; a whole number. 
  IF N_E(binsize) EQ 1 THEN BEGIN
     IF binsize LT 1 THEN $
        STOP, "binsize is too small.  STOPPING"
     IF binsize GT n_ele THEN binsize = n_ele
     IF n_ele MOD binsize NE 0 THEN $
        MESSAGE, /INFO, 'Error Bin Size not commensurate with' + $
                 ' number of elements in sigmas - proceed with caution'
     nbins = CEIL(FLOAT(n_ele)/binsize)
     binsizes = FLTARR(nbins)
     binsizes += binsize
     binsizes[nbins-1] = binsize - (TOTAL(binsizes) - n_ele)
; When binsize is a vector, check to make sure the input is logical
; (sum of elements in binsize equals n_ele),
; issue stop if necessary and create variable for RETURN statement.
  ENDIF ELSE BEGIN
     IF TOTAL(binsize) NE n_ele THEN $
        STOP, 'binsize vector elements do not add up to n_ele.' + $
              ' This is not how this function should be used. STOPPING.'
     binsizes = binsize
  ENDELSE
  RETURN, binsizes
END
