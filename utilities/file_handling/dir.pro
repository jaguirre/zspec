function dir, filespec, display = display_flag 
;
; $Id: dir.pro,v 1.1 2003/10/19 06:39:24 observer Exp $
; $Log: dir.pro,v $
; Revision 1.1  2003/10/19 06:39:24  observer
; Organizing utilities
;
; Revision 1.1  2003/10/13 17:51:39  observer
; Implementing SG's email suggestions.
;
;
;+
; NAME:
;      dir
;
; PURPOSE:
;      Do a directory listing
;
; CALLING SEQUENCE:
;      
;      result = dir(filespec)
;
; INPUTS:
;      filespec: string argument giving the argument for the unix 'ls'
;                command.  This lets you use standard wildcards, etc.
;                You can even add switch (e.g., '-l').  The command
;                automatically uses the '-C1' switch to get a 
;                1-entry-per-line alphabetical listing.
; 
; OUTPUTS:
;      String array listing of the results of the command.  Without
;      any extra switches, this will just be a 1 file per entry string
;      array.
;
; MODIFICATION HISTORY:
;      2001/06/06 SG
;-

if n_params() lt 1 then filespec = ''

spawn, 'ls -C1 ' + filespec, result

if keyword_set(display_flag) then begin
   for k = 1, n_elements(result) do begin
      print, result(k-1)
   endfor
endif

return, result

end
