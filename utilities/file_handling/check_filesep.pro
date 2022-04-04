function check_filesep, dirname, filesep = filesep
;
; $Id: check_filesep.pro,v 1.2 2003/10/22 07:01:14 observer Exp $
; $Log: check_filesep.pro,v $
; Revision 1.2  2003/10/22 07:01:14  observer
; Removing exist.pro
;
;
;+
; NAME:
;	check_filesep
;
; PURPOSE:
;	Checks that the input argument ends the appropriate file
;       separator.
;
; CALLING SEQUENCE:
;	dirname = check_filesep(dirname, filesep = filesep)
;
; INPUTS:
;	dirname: input directory name
;
; KEYWORD PARAMETERS:
;	filesep: set this to provide a file separator symbol -- 
;          needed if there is not IDL_FILESEP variable in the common
;          block USER_COMMON, or if you want to provide a nonstandard 
;          file separator
;
; OUTPUTS:
;	Corrected dirname.  Unchanged if dirname already ended in filesep.
;
; COMMON BLOCKS:
;	USER_COMMON: looks for IDL_FILESEP in USER_COMMON.  If
;	   nonexistent, user must have supplied a filesep keyword.
;
; MODIFICATION HISTORY:
; 	2002/04/08 SG
;       2003/10/21 SG Removed the need for "exist.pro"
;-

 common USER_COMMON

if (n_elements(filesep) eq 0) then begin
   ; no filesep keyword provided, see if we have on in common block
   if (n_elements(IDL_FILESEP) eq 0) then begin
      message, /cont, $
"No filesep keyword supplied and no IDL_FILESEP variable found in USER_COMMON."
      message, $
"Unable to continue."
   endif
   filesep = IDL_FILESEP
endif

if (strmid(dirname, 0, 1, /reverse) ne filesep) then $
   dirname = dirname + filesep

return, dirname

end
