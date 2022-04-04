; This is a function that estimates errors for each nod in a spectra
; As a first try, it computes the STDDEV of the set of nods (for
; each bolometer) and calls that the error for each nod.  This only
; works for chop & nod type observations, not fivepoints or focus.
;
; A fancier way of doing this might look at each nod's PSD (would need
; another argument) and extract an error estimate for each nod separately.
; That's much harder and I'll leave it for the future.

PRO estimate_spec_err, spectra
  nbolos = N_ELEMENTS(spectra.(0).nodspec[*,0])
  FOR tag = 0, N_TAGS(spectra) - 1 DO BEGIN
     FOR bolo = 0, nbolos - 1 DO BEGIN
        spectra.(tag).noderr[bolo,*] = STDDEV(spectra.(tag).nodspec[bolo,*])
     ENDFOR
  ENDFOR
END
     
