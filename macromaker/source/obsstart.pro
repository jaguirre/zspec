; obsstart.pro - prints to lun the uip commands to signal the start of
; an observation

PRO obsstart, lun, old = old

uipcomment,lun,'Reseting all flags'

if keyword_set(old) then begin

    PRINTF, lun, 'FLSIGNAL 255 /RESET'
    PRINTF, lun, 'WAIT 00:00:01'
    
    uipcomment, lun, 'Setting observation flag'
    PRINTF, lun, 'FLSIGNAL 128 /SET'

endif else begin
    
    printf,lun,'FLSIGNAL 0 /BIT 7'
    printf,lun,'FLSIGNAL 0 /BIT 6'
    printf,lun,'FLSIGNAL 0 /BIT 5'
    printf,lun,'FLSIGNAL 0 /BIT 4'
    printf,lun,'FLSIGNAL 0 /BIT 3'
    printf,lun,'FLSIGNAL 0 /BIT 2'
    printf,lun,'FLSIGNAL 0 /BIT 1'
    printf,lun,'FLSIGNAL 0 /BIT 0'
    printf,lun,'STARE 0.5'
    
    uipcomment, lun, 'Setting observation flag'
    printf, lun, 'FLSIGNAL 1 /BIT 7'

endelse

END
