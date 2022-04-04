;+
;===========================================================================
;
; NAME: 
;		   get_ops_separator
;
; DESCRIPTION: 
;		   Get operating system dependent path separator
;
; USAGE: 
;		   x = get_ops_separator()
;  	
; INPUT:
;		   system variable "!VERSION.OS_FAMILY"
;
; OUTPUT:
;   function 	   (character) separator between directories in path string
;
; AUTHOR:
;		   Bernhard Schulz (IPAC)
;
; Edition History:
;
;    Date    Programmer Remarks
; ---------- ---------- -------
; 2002-08-08 B. Schulz  initial version
; 2002-12-02 B. Schulz	bugfix lower case OS name
;
;-------------------------------------------------------------------
;-

function get_ops_separator

if !VERSION.OS_FAMILY EQ 'unix' then begin

  return, '/'

endif else begin

  if strlowcase(!VERSION.OS_FAMILY) EQ 'windows' then return, '\' $
  else message, 'Operating System '+!VERSION.OS_FAMILY+' not supported!'

endelse

end
