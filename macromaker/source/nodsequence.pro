; nodsequence.pro - print to lun the nod sequence of events,
; integrating at each nod position for t_int seconds.  Because
; of the vax WAIT command, t_int must be <= 59. 

PRO nodsequence, lun, t_int, old = old

if keyword_set(old) then begin

    uipcomment, lun, 'Start Nod Sequence'
    PRINTF, lun, 'FLSIGNAL 64 /SET'
    PRINTF, lun, 'AZO /ON_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO /OFF_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO /OFF_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'AZO /ON_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('WAIT 00:00:',t_int,format='(A11,F04.1)')
    PRINTF, lun, 'FLSIGNAL 64 /RESET'

endif else begin

    uipcomment, lun, 'Start Nod Sequence'
    PRINTF, lun, 'FLSIGNAL 1 /BIT 6'
    PRINTF, lun, 'AZO /RHS_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('STARE ',t_int,format='(A0,F04.1)')
    PRINTF, lun, 'AZO /LHS_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('STARE ',t_int,format='(A0,F04.1)')
    PRINTF, lun, 'AZO /LHS_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('STARE ',t_int,format='(A0,F04.1)')
    PRINTF, lun, 'AZO /RHS_BEAM'
    PRINTF, lun, 'ANWAIT'
    PRINTF, lun, STRING('STARE ',t_int,format='(A0,F04.1)')
    PRINTF, lun, 'FLSIGNAL 0 /BIT 6'
   
endelse

END
