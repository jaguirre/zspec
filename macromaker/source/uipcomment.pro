; uipcomment.pro - prints comment as a uip comment in lun
; 2010/01/24 - Update so default behavior is for new UIP


PRO uipcomment, lun, comment, old = old

if keyword_set(old) then begin
    PRINTF, lun, 'C '
    PRINTF, lun, 'C ' + comment
    PRINTF, lun, 'C '
endif else begin
    PRINTF, lun, '! '
    PRINTF, lun, '! ' + comment
    PRINTF, lun, '! '
endelse
        

END
