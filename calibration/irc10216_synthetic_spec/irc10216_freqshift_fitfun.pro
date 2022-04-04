FUNCTION irc10216_freqshift_fitfun, x, p, TOP_HAT = TOP_HAT
  PRINT, '.'
; FTS Data
  fts_freq = x.fts_freq
  fts_spec = x.fts_spec

; Heterodyne Survey Data
  linefreq = x.linefreq
  lineflux = x.lineflux
  linewdth = x.linewdth

  nlines = N_E(linefreq)

; Extract Parameter Values
  contamp = p[0]                ;Continuum Amplitude at 240 GHz
  contexp = p[1]                ;Continuum Exponent
  csamp   = p[2]                ;CS 4-3 Amplitude
  csexp   = p[3]                ;CS power law exponent
  coscale = p[4]                ;CO 2-1 Scale Factor
  sisamp  = p[5]                ;SiS power law amplitude
  sisexp  = p[6]                ;SiS power law exponent
  hncrat  = p[7]                ;HNC 3-2 Ratio (rel to HN13C)
  sioamp  = p[8]                ;SiO 5-4 Amplitude
  sioexp  = p[9]                ;SiO power law exponent
  hc3namp = p[10]              ;HCCCN power law amplitude
  hc3nexp = p[11]              ;HCCCN power law exponent
  polycof = p[12:*]             ;Frequency shifting polynomial coefficients

  fts_freq_norm = (fts_freq - 180.D)/(320.D - 180.D)
  fts_freq += POLY(fts_freq_norm, polycof)

  delnu = DBLARR(N_E(fts_freq))
  delnu[0:N_E(fts_freq)-2] = fts_freq[1:*]-fts_freq[0:N_E(fts_freq)-2]
  delnu[N_E(fts_freq)-1] = delnu[N_E(fts_freq)-2]
  
  nchan = (SIZE(fts_spec))[1]
  FOR i = 0, nchan - 1 DO fts_spec[i,*] /= TOTAL(delnu*fts_spec[i,*])

  linespec = DBLARR(nchan)
; Make survey lines, masking out some of the lines
  FOR l = 0, nlines-1 DO BEGIN
     CASE l of
        30: ;HCCCN 25-24, do nothing
        80: ;SiS 13-12, do nothing
        83: ;HCCCN 26-25, do nothing
        105: ;C34S 5-4, do nothing
        116: ;CS 5-4, do nothing
        135: ;SiS 14-13 do nothing
        143: ;HCCCN 28-27, do nothing
        174: ;SiO 6-5 do nothing
        189: ;HCCCN 29-28, do nothing
        ELSE: BEGIN
           newline = zspec_make_line(fts_freq, fts_spec, 0.0, $
                                     linefreq[l], linewdth[l], $
                                     scale, center, TOP_HAT = TOP_HAT)
           amp = lineflux[l]/(scale*linewdth[l])
           IF l EQ 52 THEN amp *= coscale
           linespec += amp*newline
        ENDELSE
     ENDCASE
  ENDFOR

  lw = MEDIAN(linewdth)

;CS & C34S Lines (4, 5 & 6), amplitudes controled by power law
  csfreq = ([195954.2109,244935.64,293912.0865] + (244934.91 - 244935.64))/1000
  c34sfreq = ([192818.4566,241016.19,289209.0684] + (241015.87 - 241016.19))/1000
  csamps = (csamp*(csfreq/csfreq[0])^csexp) * 1000
  FOR cs = 0, 2 DO BEGIN
     newline = zspec_make_line(fts_freq, fts_spec, 0.0, csfreq[cs], lw, $
                               scale, center, TOP_HAT = TOP_HAT)
     amp = csamps[cs]/(scale*lw)
     linespec += amp*newline
     newline = zspec_make_line(fts_freq, fts_spec, 0.0, c34sfreq[cs], lw, $
                               scale, center, TOP_HAT = TOP_HAT)
     amp = 0.075*csamps[cs]/(scale*lw)
     linespec += amp*newline
  ENDFOR

;SiS Lines (11, 12, 13, 14, 15, 16), amplitudes controled by power law
  sisfreq = [199672.2290,217817.6630,235961.15,$
             254102.82,272243.0521,290380.7570]/1000.
  sisamps = (sisamp*(sisfreq/sisfreq[0])^sisexp) * 1000
  FOR sis = 0, 5 DO BEGIN
     newline = zspec_make_line(fts_freq, fts_spec, 0.0, sisfreq[sis], lw, $
                               scale, center, TOP_HAT = TOP_HAT)
     amp = sisamps[sis]/(scale*lw)
     linespec += amp*newline
  ENDFOR

;HCCCN Lines (21-33), amplitudes controled by power law
;  hc3nfreq = [191040.299	,$
  hc3nfreq = [200135.392	,$
              209230.234	,$
              218324.723	,$
              227418.905	,$
              236512.7888	,$
              245606.3199	,$
              254699.5	        ,$
              263792.308	,$
              272884.7458	,$
              281976.7884	,$
              291068.427	,$
              300159.647	]/1000.
  hc3namps = (hc3namp*(hc3nfreq/hc3nfreq[0])^hc3nexp) * 1000
  FOR hc3n = 0, N_E(hc3nfreq)-1 DO BEGIN
     newline = zspec_make_line(fts_freq, fts_spec, 0.0, hc3nfreq[hc3n], lw, $
                               scale, center, TOP_HAT = TOP_HAT)
     amp = hc3namps[hc3n]/(scale*lw)
     linespec += amp*newline
  ENDFOR

;SiO Lines (5, 6 & 7), amplitudes controled by power law
  siofreq = ([217104.9800,260518.02,303926.8092] + (260517.67 - 260518.02))/1000
  sioamps = (sioamp*(siofreq/siofreq[0])^sioexp) * 1000
  FOR sio = 0, 2 DO BEGIN
     newline = zspec_make_line(fts_freq, fts_spec, 0.0, siofreq[sio], lw, $
                               scale, center, TOP_HAT = TOP_HAT)
     amp = sioamps[sio]/(scale*lw)
     linespec += amp*newline
  ENDFOR

;HNC 3-2 line
  newline = zspec_make_line(fts_freq, fts_spec, 0.0, (271981.1420)/1000., lw, $
                            scale, center, TOP_HAT = TOP_HAT)
  amp = hncrat*lineflux[176]/(scale*lw)  
  linespec += amp*newline

  contspec = make_cont_spec(fts_freq, fts_spec, 240., contamp, contexp)

  RETURN, linespec + contspec
END
