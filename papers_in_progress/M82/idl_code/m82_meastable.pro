pts = ['NE','CEN','SW']
measdata_files = !zspec_modeling_root + '/RADEX_modeling/rtl_meas_M82_' + pts + '.txt' 

ne_meas=load_measdata(measdata_files[0],/NO_CAL_ERROR,/NO_BEAM_SCALING)
cen_meas=load_measdata(measdata_files[1],/NO_CAL_ERROR,/NO_BEAM_SCALING)
sw_meas=load_measdata(measdata_files[2],/NO_CAL_ERROR,/NO_BEAM_SCALING)

cs_freq = [48990.9549,97980.9533,146969.0287,195954.2109,244935.5565,293912.0865]/1000.
cs_eup  = [1.6342,4.9025,9.8048,16.3411,24.5113,34.3152]
c34s_freq = [48206.9411,96412.9495,144617.1007,192818.4566,241016.0892,289209.0684]/1000.
c34s_eup = [1.6080,4.8240,9.6479,16.0796,24.1191,33.7660]
hco_freq = [89188.5247,178375.0563,267557.6259,356734.2230]/1000.
hco_eup = [2.9750,8.9250,17.8497,29.7491]
hcn_freq = [88631.6022,177261.1112,265886.4339,354505.4773]/1000.
hcn_eup = [2.9564,8.8692,17.7382,29.5633]
hnc_freq = [90663.5680,181324.7580,271981.1420]/1000.
hnc_eup = [3.0242,9.0726,18.1449]

currmol = ne_meas[0].mol
FOR i = 0, N_E(ne_meas) - 1 DO BEGIN
   CASE ne_meas[i].mol OF
      'CS':BEGIN
         currfreq = cs_freq & curreup = cs_eup & currname = 'CS' & latexname = 'CS'
      END
      'C34S':BEGIN
         currfreq = c34s_freq & curreup = c34s_eup & currname = 'C34S' & latexname = 'C$^{34}$S'
      END
      'HCO+':BEGIN
         currfreq = hco_freq & curreup = hco_eup & currname = 'HCO+' & latexname = '\hco'
      END
      'HCN':BEGIN
         currfreq = hcn_freq & curreup = hcn_eup & currname = 'HCN' & latexname = 'HCN'
      END
      'HNC':BEGIN
         currfreq = hnc_freq & curreup = hnc_eup & currname = 'HNC' & latexname = 'HNC'
      END
   ENDCASE
   IF (i EQ 0) OR (currname NE currmol) THEN BEGIN
      PRINT, '\hline'
      PRINT, '\hline'
      PRINT, '\multicolumn{8}{|c|}{' + latexname + '} \\'
      PRINT, '\hline'
   ENDIF
   currtrans = ne_meas[i].jup
   CASE currtrans OF
      1:transtxt = '\jone'
      2:transtxt = '\jtwo'
      3:transtxt = '\jthree'
      4:transtxt = '\jfour'
      5:transtxt = '\jfive'
      6:transtxt = '\jsix'
   ENDCASE
   format1 = '("'+transtxt+' & ",F0.3," & ",F0.1," & ",F0.3,"\arcsec & ",'+$
             '2(F0.1," $\pm$ ",F0.1, " & "),F0.1," $\pm$ ",F0.1," & [NOTE]\\")'
   PRINT,currfreq[currtrans-1],curreup[currtrans-1],ne_meas[i].beam,$
         ne_meas[i].flux,ne_meas[i].err,$
         cen_meas[i].flux,cen_meas[i].err,$
         sw_meas[i].flux,sw_meas[i].err,$
         FORMAT = format1

   format2 = '("'+transtxt+' & ",F0.3," & ",F0.1," & ",F0.3,"\arcsec & ",'+$
             '2(" $<$ ",F0.1, " & ")," $<$ ",F0.1," & [NOTE]\\")'
   IF ((ne_meas[i].flux EQ 0) OR $
       (cen_meas[i].flux EQ 0) OR $
       (sw_meas[i].flux EQ 0)) THEN $
          PRINT,currfreq[currtrans-1],curreup[currtrans-1],ne_meas[i].beam,$
                3*ne_meas[i].err,3*cen_meas[i].err,3*sw_meas[i].err,$
                FORMAT = format2
   currmol = ne_meas[i].mol
ENDFOR
END
