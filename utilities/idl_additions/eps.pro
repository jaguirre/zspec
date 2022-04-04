function eps, float = float, double = double
;+
; NAME:
;	EPS
;
; PURPOSE:
;       Returns the machine precision, based on the MACHAR() function.
;       NOTE THAT THIS DEPENDS ON WHETHER YOU ARE DOING FLOAT OR DOUBLE
;       ARITHMETIC.
;
; CALLING SEQUENCE:
;       result = eps(float = float, double = double)
;
; OUTPUTS:
;       machine precision, for float or double
;
; OPTIONAL KEYWORDS:
;       float: set this (e.g., by eps(float = 1) or eps(/float)
;          to return machine precision for FLOATs.  Otherwise.
;          returns precision for doubles.
;       double: not necessary, allowed only so user doesn't have to 
;          remember syntax
;
; MODIFICATION HISTORY:
; 	2001/03/07 SG
;       2001/03/10 SG Multiply result by float(1) or double(1) to
;                     prevent error messages
;       2002/09/30 SG Add /double keyword
;       2002/11/08 SG Add keyword check at start
;-

result = MACHAR()

if keyword_set(float) and keyword_set(double) then begin
   message, 'FLOAT and DOUBLE keywords may not both be set.'
endif

; don't know why I need to multiply by float(1) or double(1),
; but appears necessary to prevent floating underflow error message
if keyword_set(float) then begin
   result = float(1)*result.eps
endif else begin
   result = double(1)*result.xmin
endelse

return, result

end
