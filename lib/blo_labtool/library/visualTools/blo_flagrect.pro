;+
;===========================================================================
;
;  NAME:
;                  blo_flagrect
;
;  DESCRIPTION:
;                  Flagging of Datapoints within rectangle
;
;  INPUT:
;      x           x 2-el.-Vector
;      y           y 2-el.-Vector
;      tmp         SRD data structure
;      pixel       index of current pixel
;
;  KEYWORDS:
;     unhide       if set pixels are flagged valid
;     allcol       if set pixel and y are ignored and
;                  all pixels between y[0] and y[1] are affected
;
;  AUTHOR:
;                  B. Schulz
;
; Edition History
;  2002/08/26  B.Schulz  initial test version
;  2004/02/26  B.Schulz  select feature added
;  2004/02/27  B.Schulz  keyword allcol added

;===========================================================================
;-

pro blo_flagrect, x, y, tmp, pixel, unhide=unhide, allcol=allcol


@blo_flag_info

x1 = x(0)  & nx = x(1) - x1

if keyword_set(allcol) then begin
  y1=min((*tmp).data)-1. & ny = max((*tmp).data)-y1+1.         ;disable y selection
endif else begin
  y1 = y(0)& ny = y(1) - y1
endelse

time = (*tmp).dtim(*)

npix = n_elements((*tmp).data(*,0))
if keyword_set(allcol) then plist = indgen(npix) $
else plist = [pixel]
np = n_elements(plist)

for ipix=0, np-1 do begin

signal = reform((*tmp).data(plist(ipix),*))
flag  = reform((*tmp).flag(plist(ipix),*))

IF NOT keyword_set(unhide) THEN BEGIN

 ix = where(time GE x1 $                ;hide
  AND  time LE x1+nx  AND  signal GE y1 $
  AND  signal LE y1+ny, cnt)

;  AND  signal LE y1+ny AND  ((flag AND (NOT F_ERR_INVALID)) EQ 0), cnt)

 if cnt GT 0 then $
  (*tmp).flag(plist(ipix),ix) = (*tmp).flag(plist(ipix),ix) OR F_MANDISC

ENDIF ELSE BEGIN
 if unhide EQ 1 then begin

   ix = where(time GE x1 $                ;unhide
    AND  time LE x1+nx  AND  signal GE y1 $
    AND  signal LE y1+ny AND  $
    ((flag AND (F_SIG_INVALID OR F_AUTODISC OR F_MANDISC)) GT 0), cnt)

   if cnt GT 0 then $
    (*tmp).flag(plist(ipix),ix) = (*tmp).flag(plist(ipix),ix) AND $
          (NOT F_AUTODISC AND NOT F_MANDISC)

 endif else begin

   (*tmp).flag(plist(ipix),*) = (*tmp).flag(plist(ipix),*) OR F_MANDISC   ;hide everything outside first

   ix = where(time GE x1 $                ;unhide
    AND  time LE x1+nx  AND  signal GE y1 $
    AND  signal LE y1+ny,cnt)

     ;AND  $
    ;((flag AND (F_SIG_INVALID OR F_AUTODISC OR F_MANDISC)) GT 0), cnt)

   if cnt GT 0 then $
    (*tmp).flag(plist(ipix),ix) = (*tmp).flag(plist(ipix),ix) AND $
          (NOT F_AUTODISC AND NOT F_MANDISC)
 endelse

ENDELSE
endfor

END
