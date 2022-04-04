
;+
;===========================================================================
;
;  NAME:
;                  blo_validdat
;
;  DESCRIPTION:
;                  find all valid datapoints
;
;  INPUT:
;      bdata       data structure
;      pixel       pixel number for selection (starting with 0)
;
;  OUTPUT:
;      function: pointer array to valid data
;
;  KEYWORDS:
;     negate       if set selection invalid data are selected
;     inclerr      if set invalid errors will be seen as part of invalid data
;
;  AUTHOR:
;                  B. Schulz
;
; Edition History
;     2004/02/27  initial version
;
;===========================================================================
;-

function blo_validdat, bdata, pixel, cnt, negate=negate, inclerr=inclerr

@blo_flag_info

flags = 255b           ;select all

if NOT keyword_set(inclerr) then $
  flags = flags AND (NOT F_ERR_INVALID)  ;remove

if keyword_set(negate) then begin

  ix = where(((*bdata).flag(pixel,*) AND flags) GT 0, cnt)

endif else begin

  ix = where(((*bdata).flag(pixel,*) AND flags) EQ 0, cnt)

endelse

return, ix

end
