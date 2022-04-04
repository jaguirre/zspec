function species_tex,species

; This function takes a "species" string (or array or strings
; from zilf output and returns it in latex format.
; JRK 5/14/09

nspecies=n_e(species)
speciestex=STRARR(nspecies)
for i=0,nspecies-1 do begin
    CASE species[i] of 
        '12CO':  speciestex[i]='CO'
        '13CO':  speciestex[i]='$^{13}$CO'
        'C18O':  speciestex[i]='C$^{18}$O'
        'C180':  speciestex[i]='C$^{18}$O'
        'HCO+':  speciestex[i]='HCO$^+$'
        'HOC+':  speciestex[i]='HOC$^+$'
        'HCNH+': speciestex[i]='HCNH$^+$'
        'H2O':   speciestex[i]='H$_2$O'
        'CH+':   speciestex[i]='CH$^+$'
        'C17O':  speciestex[i]='C$^{17}$O'
        '13CN':  speciestex[i]='$^{13}$CN'
        'o-H2CO':speciestex[i]='$o$-H$_2$CO'
        'p-H2CO':speciestex[i]='$p$-H$_2$CO'
        'CH3OH': speciestex[i]='CH$_3$OH'
	;CH3CCH':speciestex[i]='CH$_3$CCH'
         else:   speciestex[i]=species[i]
    endcase
endfor
return,speciestex
end
