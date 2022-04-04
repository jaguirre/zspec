pro write_jiggle_macro, filename, x_off, y_off, t_int, comment

openw,lun,filename,/get_lun

; Stuff that must begin every macro
printf,lun,'C ' + comment
printf,lun,"SECONDARY /RELOAD /FORCE"
printf,lun,"WAIT 0:0:05"
printf,lun,"FLSIGNAL 128 /RESET"
printf,lun,"FLSIGNAL  64 /RESET"
printf,lun,"STARE 1"
printf,lun,"FLSIGNAL 128 /SET"

for i=0,n_e(x_off)-1 do begin

    printf,lun,"FLSIGNAL 64 /SET"
    printf,lun,string("AZO ",x_off[i],format='(A4,F5.1)')
    printf,lun,string("ZAO ",y_off[i],format='(A4,F5.1)')
    printf,lun,"ANWAIT"
    printf,lun,"AZO /ON_BEAM"
    printf,lun,"ANWAIT"
    printf,lun,string("WAIT 0:0:",t_int,format='(A9,I2)')
    printf,lun,"AZO /OFF_BEAM"
    printf,lun,"ANWAIT"
    printf,lun,string("WAIT 0:0:",t_int,format='(A9,I2)')
    printf,lun,"AZO /OFF_BEAM"
    printf,lun,"ANWAIT"
    printf,lun,string("WAIT 0:0:",t_int,format='(A9,I2)')
    printf,lun,"ANWAIT"
    printf,lun,"AZO /ON_BEAM"
    printf,lun,"ANWAIT"
    printf,lun,"FLSIGNAL 64 /RESET"
    
endfor

printf,lun,"AZO 0.0"
printf,lun,"ZAO 0.0"
printf,lun,"ANWAIT"
printf,lun,"FLSIGNAL 128 /RESET"

close,lun
free_lun,lun

end
