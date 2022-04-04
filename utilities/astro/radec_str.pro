function radec_str, val, mode
;+
; routine to convert an angle value to a string with no blanks
; (blanks are either filled with +/- signs or 0's)
;
; eg: RA: HHhMMmSS.SSs
;     dec: +DD:AM:AS.AS
;
; INPUTS
;    val = angle value to convert (in [HH MM SS] or [DD AM AS])
;    mode = 1 for RA
;           2 for dec
; 
; OUTPUTS
;    the desired string
;
; SG 2000/08
;-
str = ''

if n_params() ne 2 then begin
   print
   print, $
'ERROR in radec_str: Requires 2 arguments.'
   return, str
endif

if n_elements(val) gt 3 then begin
   print
   print, $
'ERROR in radec_str: angle argument may have no more than 3 elements.'
   return, str
endif

if n_elements(val) le 0 then val = [ val, 0.0]
if n_elements(val) le 1 then val = [ val, 0.0]
if n_elements(val) le 2 then val = [ val, 0.0]

if mode eq 1 then begin
   ; create string for RA
   str = string(format = '((I2.2),"h",(I2.2),"m",(F5.2),"s")', $
                val[0], val[1], val[2])
endif else begin
   sgn_str = '+'
   if val[0] lt 0 then sgn_str = '-'

   str = string(format = '((A),(I2.2),":",(I2.2),":",(F5.2))', $
                sgn_str,abs(val[0]), val[1], val[2])
endelse

; get rid of blanks; can't get IDL to zero pad floating fields
index = strpos(str,' ')
while index ge 0 do begin
   if index eq 0 then begin
      str = strmid(str,1,strlen(str)-1)
   endif else begin
      str = strmid(str,0,index) + '0' $
                 + strmid(str, $
                          index+1,strlen(str)-index-1)
   endelse
   index = strpos(str,' ')
endwhile

return, str

end