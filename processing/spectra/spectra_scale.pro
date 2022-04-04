; Scale each nodspec (and error) by the corresponding element in nodscales.
; nodscales should have as many elements as nods stored in spectra_in.

FUNCTION spectra_scale, spectra_in, nodscales
  spectra_out = spectra_in
  nnods = N_E(nodscales)
  ntags = N_TAGS(spectra_out)
  FOR nod = 0, nnods - 1 DO BEGIN
     FOR tag = 0, ntags - 1 DO BEGIN
        FOR subtag = 0, 1 DO BEGIN
           spectra_out.(tag).(subtag)[*,nod] *= nodscales[nod]
        ENDFOR
     ENDFOR
  ENDFOR
  RETURN, spectra_out
END
       
