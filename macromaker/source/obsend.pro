; obsend.pro - prints to lun the uip commands to signal the end of
; an observation

PRO obsend, lun, old = old

if keyword_set(old) then begin

    uipcomment, lun, 'Reseting all observation flags'
    PRINTF, lun, 'FLSIGNAL 255 /RESET'

endif else begin

    uipcomment, lun, 'Reseting all observation flags'
    PRINTF, lun, 'FLSIGNAL 0 /BIT 7'

endelse

END
