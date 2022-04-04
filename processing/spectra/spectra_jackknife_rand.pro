; This function generates a randomly jackknifed spectra. 
; NOTE: any particular realization of a random jackknife isn't truly
; random and for better results several random jackknives should 
; be averaged together.  Averaging together nnods (or 2*nnods) worth
; of random jackknives should be sufficient.

FUNCTION spectra_jackknife_rand, spectra_in, _EXTRA = EXTRA
  spectra_out = spectra_in
  nbolos = N_E(spectra_out.(0).(0)[*,0])
  nnods = N_E(spectra_out.(0).(0)[0,*])
  ntags = N_TAGS(spectra_out)

  FOR tag = 0, ntags - 1 DO BEGIN
     FOR bolo = 0, nbolos - 1 DO BEGIN
        spectra_out.(tag).(0)[bolo,*] *= create_jack_vec_knuth(nnods)
     ENDFOR
  ENDFOR

  spectra_ave, spectra_out, _EXTRA = EXTRA
  RETURN, spectra_out
END
