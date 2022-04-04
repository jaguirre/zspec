; macrostart.pro - writes to the lun the uip commands that
; should preceed every observation.  The header is a string
; that will be included as a comment at the begining of the
; macro.

PRO macrostart, lun, header, old = old

uipcomment, lun, header, old = old

uipcomment, lun, $
  'Force reload of secondary parameters and wait to settle', old = old

if keyword_set(old) then begin

    PRINTF, lun, 'SECONDARY /RELOAD /FORCE'
    PRINTF, lun, 'WAIT 00:00:05'
    
endif else begin

    printf, lun, 'SECONDARY /RESTART /FORCE'
    printf, lun, 'STARE 5'

endelse

END
