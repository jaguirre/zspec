pro print_fittable,source,species,transitions,fitfile

line_sig_threshold=1.2
restore,fitfile

; the above has to be done by hand for each file.
fluxes=fit.amp*fit.width*fit.scale
snr=fit.amp/fit.aerr

species_string=strarr(n_elements(species))
trans_string=strarr(n_elements(species))
line_freq=fltarr(n_elements(species))


for i=0,n_elements(species)-1 do begin

    if species[i] gt 190 and species[i] lt 195 then species[i]=100
    if species[i] gt 210 and species[i] lt 215 then species[i]=110
    if species[i] gt 240 and species[i] lt 245 then species[i]=120
    if species[i] gt 285 and species[i] lt 295 then species[i]=130

    CASE species[i] of 
        0:  species_string[i]='CO'
        1:  species_string[i]='$^{13}$CO'
        2:  species_string[i]='C$^{18}$O'
        3:   species_string[i]='CN'             
        4:   species_string[i]='CCH'
        5:   species_string[i]='HCN'
        6:    species_string[i]='HCO$^+$'
        7:    species_string[i]='HNC'
        8:    species_string[i]='CS'
        9:    species_string[i]='SiO'
        10:   species_string[i]='HCNH$^+$'
        100: species_string[i]='Mys1'
        110: species_string[i]='Mys2'
        120: species_string[i]='Mys3'
        130:species_string[i]='Mys4'
    end

    if i lt 11 then begin

        CASE transitions[i] of 
            1:   trans_string[i]='\jone'
            2:   trans_string[i]='\jtwo'
            3:   trans_string[i]='\jthree'
            4:   trans_string[i]='\jfour' 
            5:   trans_string[i]='\jfive'
            6:   trans_string[i]='\jsix'
            7:   trans_string[i]='\jseven'
            8:   trans_string[i]='\jeight'
            9:   trans_string[i]='\jnine'
           10:   trans_string[i]='\jten'
           11:   trans_string[i]='\jeleven'
           12:   trans_string[i]='\jtwelve'
           13:   trans_string[i]='\jthirteen'
        end

    endif else begin
        trans_string[i]='unknown'

endelse

endfor


;; NOW MAKE A LATEX TABLE OF LINES AND UNCERTAINTIES

outputfile=source+'_linetable.tex'
openw,unit,outputfile,/get_lun

printf,unit,'\begin{table}[t!]'
printf,unit,'\Large \centering'
printf,unit,'{\LARGE Spectral Lines in '+source+'}\\'
;printf,unit,'\LARGE\caption{\LARGE Spectral Lines in '+source+' \label{tab:'+source+'}}'
;printf,unit,'\large'
printf,unit,'\begin{tabular}{|cccccc|}'
;printf,unit,'\multicolumn{6}{c}{\LARGE Spectral Lines in '+source+'}\\'
;printf,unit,'\vspace{0.1in}'
printf,unit,'\hline' 
printf,unit,'Species & Transition & Freq & \multicolumn{2}{c}{Flux} & SNR \\'
printf,unit,'  &  &[GHz]& [Jy km s$^{-1}$] & [K km s$^{-1}$] & \\'
printf,unit,'\hline\hline'
for i=0,n_elements(fit.center)-1 do begin
    if (snr[i] gt line_sig_threshold OR species[i] eq 1 or species[i] eq 2) then begin
        printf,unit,species_string[i] +' & '+$
          trans_string[i]+' & '+$
          string(fit.center[i],format='(f6.2)')+' & '+$
          string(fluxes[i],format='(f7.1)')+' & '+$
          string(fluxes[i]/32.5,format='(f7.1)')+' & '+$
          string(snr[i],format='(f5.1)')+'\\'
    end
end


printf,unit,'\hline  \end{tabular}'
printf,unit,'\end{table}'
close,unit & free_lun,unit


;stop
end
