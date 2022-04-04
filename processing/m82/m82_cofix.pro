
year = 2006
month = 4
obsset = 0
FOR obsset = 0, 4 DO BEGIN
   CASE obsset OF               ; Select Observation
      0:BEGIN                   ; These observations are of M82 center
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [8,9,10]
         datafilename = 'm82+00+00.sav'
      END
      1:BEGIN                   ; Observations offset (+18,+7)
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [11,12]
         datafilename = 'm82+18+70.sav'
      END
      2:BEGIN                   ; Observations offset (+8,+3)
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [13,14]
         datafilename = 'm82+08+30.sav'
      END
      3:BEGIN                   ; Observations offset (-9,-3.5)
         marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [4,6,7]
         datafilename = 'm82-09-35.sav'
      END
      4:BEGIN                   ; Observations offset (+9,+3.5)
         marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [8,9,10,11] 
         datafilename = 'm82+09+35.sav'
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
            errbin = 5 & sigma = 4.0
            datafilesuffix = '_unw40.sav'
         END
      ENDCASE
      newdatafilename = change_suffix(datafilename,datafilesuffix)

; Load in weather-corrected & calibrated data
      RESTORE, $
         !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
         newdatafilename
      
; This is easier because all observations have 10 nods.
      nsourceobs = N_E(sourceobs)
      nods_per_obs = 10
      co_chans = [77,78,79]
      co_inten = DINDGEN(nsourceobs)
      FOR obs = 0, nsourceobs - 1 DO BEGIN
         obsstart = nods_per_obs*obs
         obsend = obsstart + nods_per_obs - 1
         co_inten[obs] = TOTAL(cal.in1.nodspec[co_chans,obsstart:obsend])
      ENDFOR
      meanco = MEAN(co_inten)
      PRINT, co_inten, meanco
      scalefac = DINDGEN(nods_per_obs*nsourceobs)
      FOR obs = 0, nsourceobs - 1 DO BEGIN
         obsstart = nods_per_obs*obs
         obsend = obsstart + nods_per_obs - 1
         scalefac[obsstart:obsend] = meanco/co_inten[obs]
      ENDFOR
      
      cal = spectra_scale(cal,scalefac)
; Test to make sure scales have been applied correctly
      co_inten_cor = DINDGEN(nsourceobs)
      FOR obs = 0, nsourceobs - 1 DO BEGIN
         obsstart = nods_per_obs*obs
         obsend = obsstart + nods_per_obs - 1
         co_inten_cor[obs] = TOTAL(cal.in1.nodspec[co_chans,obsstart:obsend])
      ENDFOR
      PRINT
      PRINT, co_inten_cor, MEAN(co_inten_cor)
      
; Average & save Data
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
      
      SAVE,freqs,fwhm,avespec,aveerr,co_inten,$
           meanco,cal,inttime,nnodstot,marsspec,$
           binfreqs,binavespec,binaveerr,$
           FILE = !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
           change_suffix(newdatafilename,'_cofix.sav')
      
   ENDFOR
ENDFOR
END

