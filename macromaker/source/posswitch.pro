; posswitch.pro - print to lun the nod sequence of events,
; integrating at each nod position for t_int seconds.  Because
; of the vax WAIT command, t_int must be <= 59.  This version
; works when there is no chopper going

PRO posswitch, lun, throw, t_int, old = old

if (keyword_set(old)) then begin

    uipcomment, lun, 'Start Position Switch Sequence'
    PRINTF, lun, 'FLSIGNAL 64 /SET'
    PRINTF, lun, 'AZO 0'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO ' + STRING(throw, FORMAT = '(I0)')
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO 0'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO ' + STRING(-throw, FORMAT = '(I0)')
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'FLSIGNAL 64 /RESET'

endif else begin

    uipcomment, lun, 'Start Position Switch Sequence'
    PRINTF, lun, 'FLSIGNAL 1 /BIT 6'
    PRINTF, lun, 'AZO 0'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('stare ',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO ' + STRING(throw, FORMAT = '(I0)')
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('stare ',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO 0'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('stare ',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO ' + STRING(-throw, FORMAT = '(I0)')
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('stare ',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'FLSIGNAL 0 /BIT 6'

endelse

END
