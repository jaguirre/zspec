; Procedure to calculate frequencies and psds of sliced data
PRO psd_calc, sliced_data, sample_interval, quiet = quiet

  nchan = N_ELEMENTS(sliced_data)
  nnod = N_ELEMENTS(sliced_data[0].nod)
  npos = N_ELEMENTS(sliced_data[0].nod[0].pos)

  FOR ch = 0, nchan-1 DO BEGIN
     IF ((ch MOD 10 EQ 0) and ~KEYWORD_SET(quiet)) THEN $
        MESSAGE, /INFO, 'Computing PSD for channel ' + $
                 STRING(ch,F='(I0)')
     FOR nd = 0, nnod-1 DO BEGIN
        FOR ps = 0, npos-1 DO BEGIN
           ts = sliced_data[ch].nod[nd].pos[ps].time
           psd_struct = psd(ts,sample_interval = sample_interval)
           sliced_data[ch].nod[nd].pos[ps].freq = psd_struct.freq
           sliced_data[ch].nod[nd].pos[ps].psd_raw = psd_struct.psd
        ENDFOR
     ENDFOR
  ENDFOR
END
