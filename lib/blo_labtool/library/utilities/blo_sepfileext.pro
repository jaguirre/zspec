;+
;=============================================================================
;
; NAME:
;		  blo_sepfileext
;
; DESCRIPTION: 
;		  Separate extension from filename
;
; USAGE:
;		   blo_sepfileext, filename, name, extension, leavedot=leavedot
;
; INPUT:        
;   filename       (string)
;
; OUTPUT:       
;   name           (string)
;   extension      (string)
;
; KEYWORDS:
;   leavedot
;
; Edition History:
;
; Date	      Programmer   Remarks
; 2002-11-13  B. Schulz    initial test version
;
;=============================================================================
;-

pro blo_sepfileext, filename, name, extension, leavedot=leavedot

  parts = strsplit(filename,'.')                ;separate into parts
  extp = parts(n_elements(parts)-1)             ;get position of last decimal point
  if keyword_set(leavedot) and extp GE 1 then begin
        extension = strmid(filename,extp-1)     ;extract extension
     name = strmid(filename, 0, extp-1)         ;extract filename only
  endif else begin

    if extp GE 1 then begin
         extension = strmid(filename,extp)      ;extract extension
      name = strmid(filename, 0, extp-1)        ;extract filename only
    endif else begin
         extension = ''                         ;no extension
      name = filename
    endelse

  endelse
end
