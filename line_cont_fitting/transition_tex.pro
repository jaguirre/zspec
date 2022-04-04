function transition_tex,trans

ntrans=n_e(trans)
transtex=STRARR(ntrans)
for i=0,ntrans-1 do begin
    
    dash=strSPLIT(TRANS[I],'-',/EXTRACT)  ; Should return 2 elements, upper/lower
    under=strsplit(trans[i],'_',/EXTRACT) ; Will only return more than 1 if trans has _
    
    if (n_e(dash) EQ 2) and (n_e(under) EQ 1) then begin  ; Transition of form 2-1
       transtex[i]=dash[0]+' $\rightarrow$ '+dash[1]
    endif else begin
       transtex[i]=trans[i]
    endelse
    
    if (n_e(dash) EQ 2) and (n_e(under) EQ 3) then begin  ; Transition of form 4_04-3_03
        middash=strsplit(under[1],'-',/EXTRACT)
        transtex[i]=under[0]+'$_{'+middash[0]+'} \rightarrow '+middash[1]+'_{'+under[2]+'}$'
    endif

endfor
return,transtex
end