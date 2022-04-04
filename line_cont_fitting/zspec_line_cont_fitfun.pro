function zspec_line_cont_fitfun, x, p, scales, centers , _EXTRA = FUNCTARGS

;nu_fts = DOUBLE(FUNCTARGS.nu_fts)
;ftsspec = DOUBLE(FUNCTARGS.ftsspec)

;print,'Evaluating function'

; Get the bandpass information
nu_fts = double(x.nu_fts)
ftsspec = double(x.ftsspec)

; Find out how many lines we're fitting 
nlines = n_e(x.species)
line_freqs = x.line_freqs ;dblarr(nlines)

; Read list of known lines and rest frequencies
; Might be better to pass this in rather than re-reading each time?
;;;readcol,'line_table.txt',comment=';',format='(A,A,D)',$
;;;  species,transition,frequency,/silent

; Make these all upper case for comparison
;;;species = strupcase(species)
;;;transition = strupcase(transition)

paramsperline = 3
ampind = paramsperline*INDGEN(nlines)
widthind = paramsperline*INDGEN(nlines)+1
redind = paramsperline*INDGEN(nlines)+2

scales = DBLARR(nlines)
centers = DBLARR(nlines)
linespec = DBLARR((SIZE(ftsspec))[1])

; Build up the line spectrum
for line=0,nlines-1 do begin

;;;    wh = where(species eq strupcase(x.species[line]) and $
;;;               transition eq strupcase(x.transition[line]))
;;;    if (wh[0] eq -1) then message, 'Line not recognized'
;;;    line_freqs[line] = frequency[wh]

    amp = p[ampind[line]]
    linewidth = p[widthind[line]]
; Redshift shall be dimensionless
    redshift = p[redind[line]]

    linespec += amp*zspec_make_line(nu_fts,ftsspec,redshift,$
                                    line_freqs[line],$
                                    linewidth, scale, center)
                                              
    scales[line] = scale
    centers[line] = center

endfor

; Deal with various cases of requested continuum fits
case strupcase(x.cont) of 
    
    'NONE' : contspec = dblarr(n_e(linespec))

    'PWRLAW' : begin

        if n_e(p) ne 3.*nlines + 2 then $
          message,'Parameters inconsistent with power law continuum fit'

        contamp = p[paramsperline*nlines+0]
        contexp = p[paramsperline*nlines+1]
        contspec = $
          make_cont_spec(nu_fts, ftsspec, 240., contamp, contexp)
     
    end
    'M82FFT' : begin

        if n_e(p) ne 3.*nlines + 2 then $
          message,'Parameters inconsistent with M82 Free-Free + Thermal fit'

        contfrac = p[paramsperline*nlines+0]
        contexp = p[paramsperline*nlines+1]
        contspec = $
          make_cont_spec_m82(nu_fts, ftsspec, contfrac, contexp)
     
    end
    '1068BBP' : begin

        if n_e(p) ne 3.*nlines + 2 then $
          message,'Parameters inconsistent with NGC1068 BB + Powerlaw'

        contfrac = p[paramsperline*nlines+0]
        contexp = p[paramsperline*nlines+1]
        contspec = $
          make_cont_spec_ngc1068(nu_fts, ftsspec, contfrac, contexp)
     
    end
    
endcase

return, linespec + contspec

end
