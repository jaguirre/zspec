pro wclose, p
;+
; NAME:
;	wclose
;
; PURPOSE:
;	closes windows with indices given by the input array
;
; CALLING SEQUENCE:
;       wclose, p
;
; INPUTS:
;	p: array of indices of windows to close.  Set to -1 to close
;          all windows.  If p is not given, the current window is closed.
;
; MODIFICATION HISTORY:
; 	2001/08/03 SG
;       2002/05/14 SG Fix bug in closing of multiple windows.
;-

if (n_params() eq 0) then p = !WINDOW

if (n_elements(p) eq 1) then begin
   if (p eq -1) then begin
      while (!WINDOW ge 0) do begin
         wdelete, !WINDOW
      endwhile
   endif else wdelete, p
   return
endif

if (n_elements(p) gt 1) then begin
   for k = n_elements(p)-1, 0, -1 do begin
      wdelete, p[k]
   endfor
   return
end

end
