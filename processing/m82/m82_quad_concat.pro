
; Join together M82 observations
year = 2006
month = 4
obsset = 0
FOR obsset = 0, 4 DO BEGIN
   CASE obsset OF               ; Select Observation
      0:BEGIN                   ; These observations are of M82 center
         marsnight = 14
         marsobs = 6
         night = 14
         sourceobs = [8,9,10]
         datafilename = 'm82+00+00.sav'
      END
      1:BEGIN                   ; Observations offset (+18,+7)
         marsnight = 14
         marsobs = 6
         night = 14
         sourceobs = [11,12]
         datafilename = 'm82+18+70.sav'
      END
      2:BEGIN                   ; Observations offset (+8,+3)
         marsnight = 14
         marsobs = 6
         night = 14
         sourceobs = [13,14]
         datafilename = 'm82+08+30.sav'
      END
      3:BEGIN                   ; Observations offset (-9,-3.5) 
         marsnight = 16
         marsobs = 1
         night = 16
         sourceobs = [4,6,7]
         datafilename = 'm82-09-35.sav'
      END
      4:BEGIN                   ; Observations offset (+9,+3.5)
         marsnight = 16
         marsobs = 1
         night = 16
         sourceobs = [8,9,10,11] 
         datafilename = 'm82+09+35.sav'
      END
      5:BEGIN                   ; Observations offset (-14,-6)
         marsnight = 27
         marsobs = 3
         night = 19
         sourceobs = [5,6,7,8] 
         datafilename = 'm82-14-60.sav'
      END
      6:BEGIN                   ; Observations offset (+18,+8)
         marsnight = 27
         marsobs = 3
         night = 19
         sourceobs = [9,10,11]
         datafilename = 'm82+18+80.sav'
      END
      7:BEGIN                   ; Observations offset (+2,+1)
         marsnight = 27
         marsobs = 3
         night = 19
         sourceobs = [12]
         datafilename = 'm82+02+10.sav'
      END
   ENDCASE
   FOR datatype = 0, 3 DO BEGIN
      CASE datatype OF
         0: BEGIN
            psd = 1 & unweighted = 0
            errbin = 5 & sigma = 4.0
            datafilesuffix = '_psd05.sav'
         END
         1: BEGIN
            psd = 1 & unweighted = 0
            errbin = 10 & sigma = 4.0
            datafilesuffix = '_psd10.sav'
         END
         2: BEGIN
            psd = 0 & unweighted = 0
            errbin = 10 & sigma = 4.0
            datafilesuffix = '_nod10.sav'
         END
         3: BEGIN
            psd = 0 & unweighted = 1
            errbin = 10 & sigma = 4.0
            datafilesuffix = '_unw40.sav'
         END
      ENDCASE
      
      
; Load in data from obsset
      nnodstot = 0
      inttime = 0.D
      FOR obs = 0, N_E(sourceobs) - 1 DO BEGIN
         ncpath = get_ncdfpath(year,month,night,sourceobs[obs])
         file = change_suffix(ncpath,'_quad_spectra.sav')
         PRINT, 'Reading in: ', file
         RESTORE, file
         nnodstot += n_nods
         inttime += n_nods*4*pos_length*samp_int
         PRINT, n_nods, n_nods*4*pos_length*samp_int, nnodstot, inttime
         source_spec = vquad_spectra
         IF psd EQ 1 THEN $
            source_spec = estimate_psd_errs(source_spec,vquad_avepsd,$
                                            1.D/(chop_struct.period*samp_int),$
                                            4.D*pos_length*samp_int)
         source_spec = correct_sky_trans(source_spec,nod_struct,$
                                         year,month,night,sourceobs[obs])
         IF obs EQ 0 THEN BEGIN
            sourcenods = source_spec
         ENDIF ELSE BEGIN
            sourcenods = combine_spectra(sourcenods,source_spec)
         ENDELSE
      ENDFOR
      
; Load in mars calibration 
      PRINT, 'Reading in mars calibration'
      RESTORE, change_suffix(get_ncdfpath(year,month,marsnight,marsobs),$
                             '_quad_spectra.sav')
      marsspec = vquad_spectra
      IF psd EQ 1 THEN $
         marsspec = estimate_psd_errs(marsspec,vquad_avepsd,$
                                      1.D/(chop_struct.period*samp_int),$
                                      4.D*pos_length*samp_int)
      marsspec = correct_sky_trans(marsspec,nod_struct,$
                                   year,month,marsnight,marsobs)

      errbin_temp = errbin
      spectra_ave, marsspec, ERRBIN = errbin_temp, $
                   SIGMA = sigma, UNWEIGHTED = unweighted
      
; Apply calibration and save data
      cal = spectra_div(sourcenods,marsspec)
      cal = spectra_div(cal,(1.D/cal_vec(year,month,marsnight,$
                                         SOURCE = 0,UNIT = 0)))
      spectra_ave, cal, ERRBIN = errbin, $
                   SIGMA = sigma, UNWEIGHTED = unweighted

      avespec = cal.in1.avespec
      aveerr = cal.in1.aveerr

      freqs = freqid2freq()
      fwhm = freqid2bw()

; Compute binned spectra & frequencies
      binfreqs = DBLARR(80)
      binavespec = DBLARR(80)
      binaveerr = DBLARR(80)
      FOR bolo = 0L, 79 DO BEGIN
         binfreqs[bolo] = (freqs[2*bolo] + freqs[2*bolo+1])/2
         currnods = [cal.in1.nodspec[2*bolo,*],cal.in1.nodspec[2*bolo+1,*]]
         currerrs = [cal.in1.noderr[2*bolo,*],cal.in1.noderr[2*bolo+1,*]]
         IF unweighted EQ 0 THEN BEGIN
            binavespec[bolo] = weighted_mean(currnods,currerrs,ERRBIN = errbin)
            binaveerr[bolo] = weighted_sdom(currerrs,ERRBIN = errbin)
         ENDIF ELSE BEGIN
            binavespec[bolo] = rm_outlier(currnods,sigma,$
                                          currmask,currsigma,/SDEV,QUIET = 1)
            binaveerr[bolo] = currsigma
         ENDELSE
      ENDFOR

      SAVE,freqs,fwhm,avespec,aveerr,$
           inttime,nnodstot,cal,marsspec,$
           binfreqs,binavespec,binaveerr,$
           FILE = !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
           change_suffix(datafilename,datafilesuffix)      
   ENDFOR

ENDFOR

END

