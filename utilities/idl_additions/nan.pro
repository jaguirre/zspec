function nan, float = float, double = double
;+
; NAME:
;	nan
;
; PURPOSE:
;       Returns NaN.
;
; CALLING SEQUENCE:
;       result = nan(float = float, double = double)
;
; OUTPUTS:
;       NaN, of the appropriate type
;
; OPTIONAL KEYWORDS:
;       float: set this to return floating-point NaN.  Otherwise you
;          will get double-precision NaN.
;       double: not necessary, allowed only so user doesn't have to 
;          remember syntax
;
; MODIFICATION HISTORY:
;       2002/05/14 SG
;       2002/11/08 SG Add double keyword
;-

!EXCEPT = 0

if keyword_set(float) and keyword_set(double) then begin
   message, 'FLOAT and DOUBLE keywords may not both be set.'
endif

if keyword_set(float) then begin
   result = -sqrt(-1.)
endif else begin
   result = -sqrt(-1D)
endelse

return, result
!EXCEPT = 1

end
