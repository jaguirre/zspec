; This function takes the 1D mask and applies to all channels in dataflags_in. 
; dataflags_in is not modified by the function, which returns the new flags.
; It assumes that time is the last dimension of dataflags and the number of
; elements in that dimension will be equal to the number of elements in mask.
; If this condition is not satified, then an error is reported and STOP issued.
;
; HISTORY: 25 AUG 2006 BN initial version
;          05 SEP 2006 BN figured out how to handle arbitrary dimensions

FUNCTION apply1dmask, mask, dataflags_in
dfsize = SIZE(dataflags_in)
msize = N_ELEMENTS(mask)
  
IF dfsize[dfsize[0]] NE msize THEN BEGIN
   MESSAGE, /INFO, 'Mask size and time dimension in dataflags_in ' + $
            'do not match. Stopping'
   STOP
ENDIF

; This creates many copies of mask, indexed the same way dataflags_in is
newflags = REPLICATE(CREATE_STRUCT('mask',mask),REVERSE(dfsize[1:dfsize[0]-1]))
newflags = TRANSPOSE(newflags.mask)

RETURN, dataflags_in*newflags

END

