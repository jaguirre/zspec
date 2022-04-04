PRO rolloff_fitprint, infile,cline_combine_filename,bolonum=bolonum

infile=!zspec_pipeline_root+$
  '/bolo_rolloff/fit_data/all_fit_files/'+infile

PRINT, 'Restoring file ', infile
RESTORE, infile
PRINT, infile

ps_file = change_suffix(infile,'ps')
PRINT, 'Creating ps file ', ps_file

SET_PLOT,'ps'
DEVICE,FILE = ps_file, /PORTRAIT, /COLOR, /INCHES, $
       XSIZE = 7.5, YSIZE = 10, XOFFSET = 0.5, YOFFSET = 0.5
!P.MULTI = [0,1,3]
!p.font=0

; Make a vector of 16 points, A[i] = i*2pi/16:  
A = FINDGEN(17) * (!PI*2/16.)  
; Define the symbol to be a unit circle with 16 points,   
; and set the filled flag:
symsize = 0.20  
USERSYM, symsize*COS(A), symsize*SIN(A), /FILL  
!P.PSYM = 8 ; by default, use circular points

pt_skip = 1;5
fit_skip = 1;2
err_skip = 10

ave_phi = DBLARR(nbolos)
ave_phierr = DBLARR(nbolos)
ave_phistd = DBLARR(nbolos)

if keyword_set(bolonum) then begin
boloi=bolonum
bolof=bolonum
endif else begin
boloi=0
bolof=nbolo-1
endelse

FOR bolo = boloi, bolof DO BEGIN
ubolo=bolos(bolo)
   PRINT, 'Plotting Bolo #', ubolo
   bolosin = REFORM(optical_sin[ubolo,*])
   bolocos = REFORM(optical_cos[ubolo,*])
   bolosinerr = REFORM(optical_sinerr[ubolo,*])
   bolocoserr = REFORM(optical_coserr[ubolo,*])

   indvar = [[bolosin],[bolocos]]
   depenvar = bolosin^2 + bolocos^2
   depenerr = 2.*SQRT(bolosin^2*bolosinerr^2 + bolocos^2*bolocoserr^2)

   fitparams = REFORM(all_fitparams[ubolo,*])
   quadsum_fit = REFORM(all_quadsum_fit[ubolo,*])

   ; Plot results
   fitsin = all_fitsin[ubolo]

   IF fitsin THEN BEGIN
      xt='*** sin ***' & yt='cos' 
      fitfunceval = REFORM(all_vifit[ubolo,*])
      efferr = bolocoserr
   ENDIF ELSE BEGIN
      xt='sin' & yt='*** cos ***'
      fitfunceval = REFORM(all_vrfit[ubolo,*])
      efferr = bolosinerr
   ENDELSE
   PLOT, [bolosin,0], [bolocos,0], /NODATA,$
         XTITLE = xt, YTITLE = yt,$
         TITLE = 'Bolo # = ' + STRING(ubolo, FORMAT = '(I0)')+$
         ', Freq = ' + STRING(freqid2freq(ubolo),FORMAT='(F0.2)')+' GHz'
   OPLOT, [0], [0], PSYM = 7, SYMSIZE = 3, THICK = 3
   IF fitsin THEN $
      OPLOT, bolosin[0:*:fit_skip], fitfunceval[0:*:fit_skip] $
   ELSE OPLOT, fitfunceval[0:*:fit_skip], bolocos[0:*:fit_skip]
   FOR d_ind = 0, N_E(dates) - 1 DO BEGIN
      pts = WHERE(alldates EQ dates[d_ind],count)
      IF count NE 0 THEN BEGIN
         first = pts[0]
         last = pts[N_E(pts)-1]
         OPLOT,bolosin[first:last:pt_skip],$
               bolocos[first:last:pt_skip],COLOR = d_ind; (d_ind MOD 5)+ 2
      ENDIF
   ENDFOR
   ave_phi[ubolo] = MEAN(fitparams[5:*])
   ave_phierr[ubolo] = MEAN(all_fiterrscaled[ubolo,5:*])
   ave_phistd[ubolo] = STDDEV(fitparams[5:*])
   textx = MIN(bolosin)
   texty = MIN(bolocos) + 0.2*(MAX(bolocos) - MIN(bolocos))
   XYOUTS, textx, texty, CHARSIZE = 0.5, $
           'cline [pF] = ' + STRING(fitparams[3],F='(F0.4)') + $
           ' +/- ' + STRING(all_fiterrscaled[ubolo,3],F='(F0.4)') + $
           '!C!C' + 'phi (averaged) [deg] = ' + $
           STRING(ave_phi[ubolo],F='(F0.4)') + $
           ' +/- ' + STRING(ave_phistd[ubolo],F='(F0.4)') + $
           ' (stat) +/- ' + STRING(ave_phierr[ubolo],F='(F0.4)') + ' (fit)'


   FOR f_ind = 1, total_obs_used DO BEGIN
      pts = WHERE(allfiles EQ f_ind,count)
      IF count NE 0 THEN BEGIN
         XYOUTS, MEAN(bolosin[pts]),MEAN(bolocos[pts]),$
                 STRING(f_ind,F='(I0)'),ALIGNMENT = 0.5,$
                 CHARSIZE = 0.3, COLOR = (f_ind MOD 5) + 2
      ENDIF
   ENDFOR


   IF fitsin THEN BEGIN
      fitdelta = bolocos - fitfunceval & yt = 'cos - fit'  
      x = bolosin & xt = '*** sin ***' & xr = !X.CRANGE
   ENDIF ELSE BEGIN
      fitdelta = bolosin - fitfunceval & yt = 'sin - fit' 
      x = bolocos & xt = '*** cos ***' & xr = [MAX(bolocos),MIN(bolocos)]
   ENDELSE
   PLOT, [x,0], [fitdelta,0], /NODATA, XTITLE = xt, YTITLE = yt, XRANGE = xr
   FOR d_ind = 0, N_E(dates) - 1 DO BEGIN
      pts = WHERE(alldates EQ dates[d_ind],count)
      IF count NE 0 THEN BEGIN
         first = pts[0]
         last = pts[N_E(pts)-1]
         uperr = fitdelta + efferr
         lowerr = fitdelta - efferr
         ERRPLOT,x[first:last:err_skip],$
                 lowerr[first:last:err_skip],$
                 uperr[first:last:err_skip],$
                 COLOR = (d_ind MOD 5)+2,WIDTH = 0.005
      ENDIF
   ENDFOR
   OPLOT,[-100,100],[0,0],PSYM = 0
   
   PLOT, depenvar - quadsum_fit, /NODATA, YTITLE = 'quad_sum - fit'
   FOR d_ind = 1, total_obs_used DO BEGIN
      pts = WHERE(allfiles EQ d_ind,count)
      IF count NE 0 THEN BEGIN
         first = pts[0]
         last = pts[N_E(pts)-1]
         uperr = depenvar - quadsum_fit + depenerr
         lowerr = depenvar - quadsum_fit - depenerr
         ERRPLOT,pts[0:*:err_skip],lowerr[first:last:err_skip],$
                 uperr[first:last:err_skip],$
                 COLOR = (d_ind MOD 5)+2,WIDTH = 0.005
      ENDIF
   ENDFOR
   OPLOT,[0,2*N_E(alldates)],[0,0],PSYM = 0
   FOR d_ind = 0, N_E(dates) - 1 DO BEGIN
      pts = WHERE(alldates EQ dates[d_ind],count)
      IF count NE 0 THEN BEGIN
         startpt = MIN(pts)
         endpt = MAX(pts)
         OPLOT,[startpt,startpt],[-1,+1]*1000,$
               COLOR = (d_ind MOD 5) + 2, PSYM = 0, THICK = 5
         OPLOT,[endpt,endpt],[-1,+1]*1000,$
               COLOR = (d_ind MOD 5) + 2, PSYM = 0, THICK = 5
      ENDIF
   ENDFOR
ENDFOR

DEVICE, /CLOSE_FILE
SET_PLOT, 'x'
!P.MULTI = 0
!P.PSYM = 0

; Write fiting data to file
data_file = change_suffix(infile, 'txt')

; Break up all_fitparams & all_fiterrscaled into 1D variables
vbias  = REFORM(all_fitparams[*,0])
fbias  = REFORM(all_fitparams[*,1])
rload  = REFORM(all_fitparams[*,2])
cline  = REFORM(all_fitparams[*,3])
gain   = REFORM(all_fitparams[*,4])
phi    = ave_phi

freqid = INDGEN(nbolos)

cline_err = REFORM(all_fiterrscaled[*,3])
phi_err   = ave_phierr

;comment1 = '# freqid, cline[pF], ave_phi[Deg], cline_err, ave_phierr'
comment2 = '# freqid, vbias[mV], fbias[Hz], rload[MOhm], cline[pF], ' + $
           'cline_err, ave_phi[Deg], ave_phierr, gain, n_iterations, ' + $
           'Squared Residuals'
comment3 = '# freqid, cline[pF], cline_err'

format2 = '(I5,"  ",F0.5,"  ",F0.4,"  ",F0.2,"  ",F0.6," +/- ",F0.8,' + $
          '"  ",F0.6, " +/- ",F0.8,"  ",F0.2,"  ",I0,"  ",E0.6,"  ",' + $
          'I0)'
format3 = '(I5," ",F0.4," ",F0.8)'

;FORPRINT, freqid, cline, phi, cline_err, phi_err, TEXTOUT = data_file, $
;          COMMENT = comment1

FORPRINT, freqid, vbias, fbias, rload, cline, cline_err, phi, phi_err, $
          gain, all_iterations, all_sqresid, COMMENT = comment2, $
          TEXTOUT = change_suffix(infile,'.allfitdata.txt'), $
          FORMAT = format2

print,'Creating cline_combine text file.' 

cline_combine_file=!zspec_pipeline_root+'/bolo_rolloff/fit_data/'+ cline_combine_filename

forprint,freqid,cline,cline_err,textout=cline_combine_file,comment=comment3,$
  format=format3

cline_combine_file=!zspec_pipeline_root+'/bolo_rolloff/fit_data/rload'+ cline_combine_filename

forprint,freqid,rload,textout=cline_combine_file,comment=comment3,$
  format=format3


END
