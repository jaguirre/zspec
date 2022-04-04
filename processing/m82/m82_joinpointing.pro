; Combine M82 pointings 3A (+8,+3) and 3B (+9,+3.5) from 
; 20060414 & 20060416, respectively.
FOR fix = 0, 1 DO BEGIN
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
      
      marsnightA = 14 & marsobsA = 6 & nightA = 14 & sourceobsA = [13,14]
      datafilenameA = change_suffix('m82+08+30.sav',datafilesuffix)
      
      marsnightB = 16 & marsobsB= 1 & nightB = 16 & sourceobsB = [8,9,10,11] 
      datafilenameB = change_suffix('m82+09+35.sav',datafilesuffix)
      
      datafilename = change_suffix('m82+0809+3035.sav',datafilesuffix)
   
      sourceobs = [sourceobsA,sourceobsB]
      
; Restore Data & make local copies of restored variables
      RESTORE,  !ZSPEC_PIPELINE_ROOT + $
                '/working_bret/m82/joined_data/' + datafilenameA
      inttimeA = inttime
      nnodstotA = nnodstot
      calA = cal
      marsspecA = marsspec
      
      RESTORE,  !ZSPEC_PIPELINE_ROOT + $
                '/working_bret/m82/joined_data/' + datafilenameB
      inttimeB = inttime
      nnodstotB = nnodstot
      calB = cal
      marsspecB = marsspec
      
; Join together and correct level based on CO intensity
      inttime = inttimeA + inttimeB
      nnodstot = nnodstotA + nnodstotB
      cal = combine_spectra(calA,calB)
      
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
      
      IF fix EQ 1 THEN cal = spectra_scale(cal,scalefac)
; Test to make sure scales have been applied correctly
      co_inten_cor = DINDGEN(nsourceobs)
      FOR obs = 0, nsourceobs - 1 DO BEGIN
         obsstart = nods_per_obs*obs
         obsend = obsstart + nods_per_obs - 1
         co_inten_cor[obs] = TOTAL(cal.in1.nodspec[co_chans,obsstart:obsend])
      ENDFOR
      PRINT
      PRINT, co_inten_cor, MEAN(co_inten_cor)
      
; Average & save data
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
         binavespec[bolo] = weighted_mean(currnods,currerrs,ERRBIN = 10)
         binaveerr[bolo] = weighted_sdom(currerrs,ERRBIN = 10)
      ENDFOR
      
      IF fix EQ 0 THEN $
         savefile = datafilename $
      ELSE savefile = change_suffix(datafilename,'_cofix.sav')

      SAVE,freqs,fwhm,avespec,aveerr,co_inten,$
           meanco,cal,inttime,nnodstot,$
           calA,calB,marsspecA,marsspecB,$
           binfreqs,binavespec,binaveerr,$
           FILE = !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
           savefile
   ENDFOR
ENDFOR
END
