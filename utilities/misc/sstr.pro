function sstr,number,precision=precision
;+
; NAME:
;      SSTR
; PURPOSE:
;      Converts a number to a string removing the white spaces.
;
; CALLING SEQUENCE:
;      RESULT = SSTR(number)
;
; INPUT:
;      NUMBER - the number to be converted into a string
;
; OUTPUT:
;      RESULT - the number as a string
;
; OPTIONAL KEYWORD PARAMETERS:
;      PRECISION - specifies the number of digits beyond the decimal
;                  place to keep.  If this is set to a number lt 0 then
;                  the number will be truncated before the decimal
;
; PROCEDURES CALLED:
;      STRTRIM, STRPOS, STRMID
;
; MODIFICATION HISTORY:
;      1999-05-06: (ebb) added precision keyword
;-
result=strtrim(string(number),1)

if (keyword_set(precision)) then begin
    dot=strpos(result,'.')
    if (precision lt 0) then begin
        result=strmid(result,0,dot)
    endif else begin
        result=strtrim(string(round(number*10.^precision)/(10.^precision)),1)
        result=strmid(result,0,dot+precision+1)
    endelse
endif

return,result

end
