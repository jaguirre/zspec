function break_filename, filename
;+
; NAME:
;	break_filename
;
; PURPOSE:
;	Breaks a filename into directory name, filestub, and file
;	extension.  The directory name that is returned contains the
;       file separator (e.g., '/' for unix)
;
; CALLING SEQUENCE:
;
;       result = break_filename(filename)
;
; INPUTS:
;	filename: a filename to break
;
; OUTPUTS:
;	result: a 4-element string array with entries
;          result[0] = directory name (including filesep)
;          result[1] = filestub
;          result[2] = file extension
;	   result[3] = last directory
;       so, for example, to reconstruct the filename, you would do
;
;          result[0] + result[1] + '.' + result[2]
;
; MODIFICATION HISTORY:
; 	2001/12/26 SG
;	2003/11/06 GL - added last directory
;-

 COMMON USER_COMMON

; look for last '.'
dot_at = strpos(filename, '.', /reverse_search)
if (dot_at eq -1) then dot_at = strlen(filename)

; look for last filesep
delim_at = strpos(filename, IDL_FILESEP, /reverse_search)

result = strarr(4)

if (delim_at ne -1) then begin
   result[0] = strmid(filename, 0, delim_at)

   ;get next directory up
   delim2_at=strpos(result[0],IDL_FILESEP,/reverse_search)
   if delim2_at ne -1 then result[3]=strmid(result[0],delim2_at+1,strlen(result[0])-delim2_at-1)

   ;put idl separator back in
   result[0]=result[0]+IDL_FILESEP
endif

result[1] = strmid(filename, delim_at+1, dot_at-(delim_at+1))

if (dot_at ne strlen(filename)) then begin
	result[2] = strmid(filename, dot_at+1, strlen(filename)-(dot_at+1))
endif

return, result
end
