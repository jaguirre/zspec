pro window_std, free = free, retain = retain, $
                xpos = xpos, ypos = ypos, xsize = xsize, ysize = ysize, $
               title = title, noindex = noindex
;+
; NAME:
;        window_std
;
; PURPOSE:
;        create a standard size window
;
; CALLING SEQUENCE:
;        window_std, free = free, retain = retain, $
;           xpos = xpos, ypos = ypos, xsize = xsize, ysize = ysize, $
;           title = title, noindex = noindex
;
; INPUTS:
;        none
;
; OPTIONAL KEYWORDS:
;        By including any of the following keywords, you create a
;        window with the keyword parameters modified from the values
;        specified in USER_COMMON:
;        FREE: normally 1, by default creates a new window with the first 
;           available free index.
;        RETAIN: normally 2, which has IDL do the backing store for
;           the window; option 0 -> no backing store; option 1 -> window
;           system provides backing store 
;        XPOS, YPOS, XSIZE, YSIZE: obvious
;        TITLE: defaults to ''
;        NOINDEX: if this flag is set, the IDL window index is NOT
;           prepended to the window title
;
; COMMON BLOCKS:
;        Assumes the common block USER_COMMON is defined, containing variable
;        IDL_WIN, with at minimum the following fields for every
;        device the user wants to use (DNAME is the device name)
;           IDL_WIN.DNAME.XSIZE
;           IDL_WIN.DNAME.YSIZE
;           IDL_WIN.DNAME.XPOS
;           IDL_WIN.DNAME.YPOS
; 
; MODIFICATION HISTORY:
;        2000/09/08 SG
;        2001/08/11 SG Allow keyword parameters, make
;                      device-independent
;        2002/08/04 SG RETAIN keyword was not working properly.
;                      Set default RETAIN = 2.
;-

;COMMON USER_COMMON
@window_setup

idl_win_this = get_field(IDL_WIN, !D.NAME)

if not keyword_set(free) then free = 1
if not keyword_set(retain) then retain = 2
if not keyword_set(xpos) then xpos = idl_win_this.XPOS
if not keyword_set(ypos) then ypos = idl_win_this.YPOS
if not keyword_set(xsize) then xsize = idl_win_this.XSIZE
if not keyword_set(ysize) then ysize = idl_win_this.YSIZE
if not keyword_set(title) then title = ''
if not keyword_set(noindex) then noindex = 0
win_index = !D.WINDOW
if free then begin
   if win_index lt 32 then begin
      win_index = max([32, win_index])
   endif else begin
      win_index = max([32, win_index]) + 1
   endelse
endif
if noindex eq 0 then begin
   str = 'IDL ' + string(format = '(I0)', win_index)
   if title eq '' then begin
      title = str
   endif else begin
      title =  str + ': ' + title
   endelse
endif

window, free = free, retain = retain, $
        xpos = xpos, ypos = ypos, xsize = xsize, ysize = ysize, $
        title = title

end
