; Print out Z-Spec line measurements for LaTEX table

basedir = ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/'
freqs = freqid2freq()
dirs = ['M82_NE', 'M82_CEN', 'M82_SW']
ubernames = ['20100315_1457','20100315_1508','20100315_1512']
fitfiles = dirs + '_' + ubernames + '_zilf_fit.sav'

RESTORE, basedir + '/' + dirs[0] + '/' + fitfiles[0] ;, /verb
ne_amp = zspec_jytok(fit.amplitude*fit.scales*fit.width,fit.centers)
ne_err = zspec_jytok(fit.amperr*fit.scales*fit.width,fit.centers)
RESTORE, basedir + '/' + dirs[1] + '/' + fitfiles[1] ;, /verb
cen_amp = zspec_jytok(fit.amplitude*fit.scales*fit.width,fit.centers)
cen_err = zspec_jytok(fit.amperr*fit.scales*fit.width,fit.centers)
RESTORE, basedir + '/' + dirs[2] + '/' + fitfiles[2] ;, /verb
sw_amp = zspec_jytok(fit.amplitude*fit.scales*fit.width,fit.centers)
sw_err = zspec_jytok(fit.amperr*fit.scales*fit.width,fit.centers)

reorder = SORT(fit.x.species+fit.x.transition)
species = fit.x.species[reorder]
trans = fit.x.transition[reorder]
restfreqs = fit.centers[reorder]*(1+fit.redshift)
beams = fwhm_from_beammap(restfreqs)*(180./!PI)*3600
ne_amp = ne_amp[reorder]
ne_err = ne_err[reorder]
cen_amp = cen_amp[reorder]
cen_err = cen_err[reorder]
sw_amp = sw_amp[reorder]
sw_err = sw_err[reorder]
PRINT, 'Tables for Likelihood Analysis'
FOR j = 0, 2 DO BEGIN
   CASE j OF
      0:BEGIN
         curramp = ne_amp
         currerr = ne_err
      END
      1:BEGIN
         curramp = cen_amp
         currerr = cen_err
      END
      2:BEGIN
         curramp = sw_amp
         currerr = sw_err
      END
   ENDCASE
   PRINT, 'Likelihood Table for ' + dirs[j]
   FOR i = 0, N_E(species)-1 DO BEGIN
      currs = species[i]
      IF TOTAL(currs EQ ['CS','HCO+','HCN','HNC']) EQ 0 THEN BEGIN
         ; DO NOTHING
      ENDIF ELSE BEGIN
         currt = STRING(trans[i],F='(A1)')
         IF curramp[i] GT 3*currerr[i] THEN $
            PRINT, currs, currt, curramp[i], currerr[i],beams[i],0,$
                   FORMAT = '(A-5,A-2,F5.2," ",F0.2," ",F0.1," ",I0)'$
         ELSE PRINT, currs, currt, 0, currerr[i],beams[i],0, curramp[i],$
                   FORMAT = '(A-5,A-2,F5.2," ",F0.2," ",F0.1," ",I0," # ",F0.2)'
         
      ENDELSE
   ENDFOR
   PRINT
ENDFOR




FOR i = 0, N_E(species)-1 DO BEGIN
   currs = species[i]
   CASE currs OF
      '12CO':currs   = '       CO'
      '13CO':currs   = '$^{13}$CO'
      'C180':currs   = 'C$^{18}$O'
      'CCH':currs    = '     \cch'
      'CH3CCH':currs = '   \chcch'
      'HCO+':currs   = '     \hco'
      'H2CO':currs   = '    \hhco'
      ELSE:currs = STRING(currs,F='(A9)')
   ENDCASE
   species[i] = currs

   currt = trans[i]
   CASE currt OF
      '2-1':currt   = '\jtwo      '
      '3-2':currt   = '\jthree    '
      '4-3':currt   = '\jfour     '
      '5-4':currt   = '\jfive     '
      '6-5':currt   = '\jsix      '
      '12-11':currt = '\jtwelve   '
      '13-12':currt = '\jthirteen '
      '14-13':currt = '\jfourteen '
      '15-14':currt = '\jfifteen  '
      '16-15':currt = '\jsixteen  '
      '17-16':currt = '\jseventeen'
      ELSE:currt = STRING(currt,F='(A-11)')
   ENDCASE
   trans[i] = currt
ENDFOR

planck = 6.626068e-34
sol = 299792458d2
kbol = 1.3806503e-23
icm2K = planck*sol/kbol
temps = icm2K*[11.5350,11.0276,10.9857,$
               17.4870,$
               44.4669,51.8776,59.8582,68.4087,$
               11.3544,$
               16.3411,24.5113,34.3152,$
               14.5655,22.2822,24.2597,33.2835,31.6729,$
               17.7382,17.8497,18.1449]

PRINT, 'Table for Paper - Standard Formatting & Upper Limit Formatting - CUT & PASTE AS NECESSARY'
FOR i = 0, N_E(restfreqs) - 1 DO BEGIN
   format = '("'+species[i]+'~'+trans[i]+' & ",F0.3," & ",F0.1," & ",F0.3," & ",'+$
            '2(F0.1," $\pm$ ",F0.1, " & "),F0.1," $\pm$ ",F0.1," \\")'
   PRINT,restfreqs[i],temps[i],beams[i],ne_amp[i],ne_err[i],$
         cen_amp[i],cen_err[i],sw_amp[i],sw_err[i],FORMAT = format
   format = '("'+species[i]+'~'+trans[i]+' & ",F0.3," & ",F0.1," & ",F0.3," & ",'+$
            '2("$<$ ",F0.1, " [",F0.1,"] & "),"$<$ ",F0.1," [",F0.1,"] \\")'
   PRINT,restfreqs[i],temps[i],beams[i],$
         3*ne_err[i],ne_amp[i],3*cen_err[i],cen_amp[i],3*sw_err[i],sw_amp[i],$
         FORMAT = format
ENDFOR

pts = ['NE','CEN','SW']
measdata_files = 'rtl_meas_M82_' + pts + '.txt' 
ne_meas=load_measdata(measdata_files[0],/NO_CAL_ERROR,/NO_BEAM_SCALING)
cen_meas=load_measdata(measdata_files[1],/NO_CAL_ERROR,/NO_BEAM_SCALING)
sw_meas=load_measdata(measdata_files[2],/NO_CAL_ERROR,/NO_BEAM_SCALING)

planck = 6.626068e-34
sol = 299792458d2
kbol = 1.3806503e-23
icm2K = planck*sol/kbol
cs_eup   = icm2K*[1.6342,4.9025,9.8048,16.3411,24.5113,34.3152]
c34s_eup = icm2K*[1.6080,4.8240,9.6479,16.0796,24.1191,33.7660]
hco_eup  = icm2K*[2.9750,8.9250,17.8497,29.7491]
hcn_eup  = icm2K*[2.9564,8.8692,17.7382,29.5633]
hnc_eup  = icm2K*[3.0242,9.0726,18.1449]

cs_freq = [48990.9549,97980.9533,146969.0287,$
           195954.2109,244935.5565,293912.0865]/1000.
c34s_freq = [48206.9411,96412.9495,144617.1007,$
             192818.4566,241016.0892,289209.0684]/1000.
hco_freq = [89188.5247,178375.0563,267557.6259,356734.2230]/1000.
hcn_freq = [88631.6022,177261.1112,265886.4339,354505.4773]/1000.
hnc_freq = [90663.5680,181324.7580,271981.1420]/1000.

mols = ne_meas.mol
jups = ne_meas.jup

PRINT
PRINT,'Raw Measurements used for Likelihood Analysis'
FOR i = 0, N_E(mols)-1 DO BEGIN
   CASE mols[i] OF 
      'CS':BEGIN
         curreup = cs_eup[jups[i]-1] & currfreq = cs_freq[jups[i]-1]
      END
      'C34S':BEGIN
         curreup = c34s_eup[jups[i]-1] & currfreq = c34s_freq[jups[i]-1]
      END
      'HCO+':BEGIN
         curreup = hco_eup[jups[i]-1] & currfreq = hco_freq[jups[i]-1]
      END
      'HCN':BEGIN
         curreup = hcn_eup[jups[i]-1] & currfreq = hcn_freq[jups[i]-1]
      END
      'HNC':BEGIN
         curreup = hnc_eup[jups[i]-1] & currfreq = hnc_freq[jups[i]-1]
      END
   ENDCASE
   CASE jups[i] OF
      1:currt = '\jone'
      2:currt = '\jtwo'
      3:currt = '\jthree'
      4:currt = '\jfour'
      5:currt = '\jfive'
      6:currt = '\jsix'
   ENDCASE
   format = '(A-8,"&",F8.3," &",F5.1," &",F5.1,"\arcsec &",' + $
            '2(F5.1," $\pm$",F4.1, " &"),F5.1," $\pm$",F4.1," & \footnotemark[?] \\")'
   PRINT,currt,currfreq,curreup,ne_meas[i].beam,$
         ne_meas[i].flux,ne_meas[i].err,$
         cen_meas[i].flux,cen_meas[i].err,$
         sw_meas[i].flux,sw_meas[i].err, FORMAT = format
   format = '(A-8,"&",F8.3," &",F5.1," &",F5.1,"\arcsec &",' + $
            '2(" $<$",F4.1," &")," $<$",F4.1," & \footnotemark[?] \\")'
   PRINT,currt,currfreq,curreup,ne_meas[i].beam,$
         ne_meas[i].err,cen_meas[i].err,sw_meas[i].err, FORMAT = format
ENDFOR
      
END

