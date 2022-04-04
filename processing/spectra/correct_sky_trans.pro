;; This function calculates and applies the correction to scale up a
;; demodulated observation up to the top of the atmosphere.  The returned
;; spectra has had it's nodspec & noderr subtags scaled by
;; 1/sky_transmission where the sky transmission is calculated on a nod
;; by nod basis.

FUNCTION correct_sky_trans, spectra_in, nod_struct, $
                            year, month, day, obsnum, $
                            USETAU = USETAU
  spectra_out = spectra_in
  
  nbolos = N_E(spectra_in.(0).(0)[*,0])
  nnods = N_E(nod_struct)
  ntags = N_TAGS(spectra_out)

  ncfile = get_ncdfpath(year,month,day,obsnum)
  ticks = read_ncdf(ncfile,'ticks')
  elevation = read_ncdf(ncfile,'elevation')
  
  nod_start = nod_struct.i
  nod_end = nod_struct.f

  datestring = STRMID(FILE_BASENAME(ncfile),0,8)

  FOR nod = 0, nnods - 1 DO BEGIN
     med_uthour = $
        MEDIAN(ticks[nod_start[nod]:nod_end[nod]])/(3600.)
     currtau = tau225smooth(datestring,med_uthour,SIGMA=0.25)
     IF KEYWORD_SET(USETAU) THEN currtau = USETAU
     med_elevation = MEDIAN(elevation[nod_start[nod]:nod_end[nod]])
     currairmass = 1./sin(med_elevation*!DPI/180)
;     trans = EXP(-1*currairmass*sky_zspec_fts(currtau))
     trans = trans_zspec_fts(currairmass*currtau)

;     PRINT, med_uthour, currtau, med_elevation, currairmass, MEDIAN(trans)
;     PLOT, freqid2freq(), trans

     FOR tag = 0, ntags - 1 DO BEGIN
        spectra_out.(tag).(0)[*,nod] /= trans
        spectra_out.(tag).(1)[*,nod] /= trans
     ENDFOR
  ENDFOR

  RETURN, spectra_out
END
