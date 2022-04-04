;pro rolloff_fit

;GET DATA

TRUE = 1
FALSE = 0

obslist=!zspec_pipeline_root+'/bolo_rolloff/fit_data/'+$
  'obsdates.txt'

readcol,obslist,dates,format='(A8)'

;dates=[105,106,109,112,113,114,115,118,119]

wantbias = 10. ; mult 25 in mV                      
biasrange = [wantbias-1.,wantbias+1.] 

wantbiasf = 71. ; in Hz

label_bias=strtrim(floor(wantbias),2)
label_biasf=strtrim(floor(wantbiasf),2)
label_year=strmid(dates[0],0,4)
label_firstdate=strmid(dates[0],4,4)
label_lastdate=strmid(dates[n_e(dates)-1],4,4)
;now create name of savefile based on above parameters:
fit_results_savefile='rolloff_fits_'+label_year+$
  '_'+label_firstdate+'_'+label_lastdate+'_'+$
  label_bias+'mV_'+label_biasf+'Hz.sav'

;stop

firsttime = TRUE
total_obs_used = 0

FOR date=0,N_E(dates)-1 DO BEGIN
;   filenameroot = !ZSPEC_DATA_ROOT + $
;                  PATH_SEP() + 'ncdf' + $
;                  PATH_SEP() + '20090' + $
;                  STRING(dates[date],F='(I03)')
    filenameroot = !zspec_data_root+$
                  '/ncdf/'+dates[date]

    dc_curve_files = file_search(filenameroot + $
                                PATH_SEP() + '*_dc_curve.sav',$
                                COUNT = n_files)
   FOR file=0,n_files-1 DO BEGIN
      PRINT, dc_curve_files[file]
      RESTORE, dc_curve_files[file]
      ;; Check if bias ever goes outside desired range and skip file
      ;; if it does.
      badbias = WHERE(bias LT biasrange[0]/1.e3 OR $
                      bias GT biasrange[1]/1.e3 OR $
                      ABS(2./sampint - wantbiasf) GT 1.D,nbadbias) 
      IF nbadbias GT 0 THEN BEGIN
         PRINT,'Not using file '+dc_curve_files[file]
         PRINT,'Wrong bias (voltage or frequency)!'
      ENDIF ELSE BEGIN
         total_obs_used += 1
         IF firsttime THEN BEGIN ; First time through, create storage varibles
            totalsin=sinbolos
            totalcos=cosbolos
            totalsinerr=sinboloserr
            totalcoserr=cosboloserr
            totalgrt1=grt1
            totalgrt2=grt2
            totalbias = bias
            totalbiasf = 2./sampint
            alldates=REPLICATE(dates[date],N_ELEMENTS(sinbolos[1,1,*]))
            allfiles=REPLICATE(total_obs_used,N_ELEMENTS(sinbolos[1,1,*]))
            phiranges = [0,N_E(totalsin[1,1,*])]
            firsttime=FALSE
         ENDIF ELSE BEGIN   ; After first time, concatenate to storage varibles
            totalsin=[[[totalsin]],[[sinbolos]]]
            totalcos=[[[totalcos]],[[cosbolos]]]
            totalsinerr=[[[totalsinerr]],[[sinboloserr]]]
            totalcoserr=[[[totalcoserr]],[[cosboloserr]]]
            totalgrt1=[totalgrt1,grt1]
            totalgrt2=[totalgrt2,grt2]
            totalbias = [totalbias,bias]
            totalbiasf = [totalbiasf,2./sampint]
            alldates=[alldates,$
                      REPLICATE(dates[date],N_ELEMENTS(sinbolos[1,1,*]))]
            allfiles=[allfiles,REPLICATE(total_obs_used,$
                                         N_ELEMENTS(sinbolos[1,1,*]))]
            phiranges = [phiranges,N_E(totalsin[1,1,*])]
         ENDELSE
         
      ENDELSE
      
   ENDFOR
   
ENDFOR

PRINT, 'Extracting optical channels'

bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
optical_sin=extract_channels(totalsin,'optical',bolo_config_file=bc_file)
   
optical_cos=extract_channels(totalcos,'optical',bolo_config_file=bc_file)

optical_sinerr=extract_channels(totalsinerr,'optical',$
                                bolo_config_file=bc_file)

optical_coserr=extract_channels(totalcoserr,'optical',$
                                bolo_config_file=bc_file)

; FIT DATA
nbolo = 160

;Starting model parameters
vbias = MEAN(totalbias) * 1000.D ; average bias in mV
fbias = MEAN(totalbiasf)         ; Hz
rload = get_load_resistors('optical',$
                           bolo_config_file=bc_file) ; MOhm
cline = 60.D                                         ; pF
gain  = 138.D                                        ; ~200/SQRT(2)
phi   = 194.D                                        ; Degrees

nphi = N_E(phiranges) - 1

;Set up parameter info for mpfitfun
parinfo = replicate({fixed:FALSE, $
                     limited:[FALSE,FALSE], $
                     limits:[0.D,0.D], $
                     parname:''},5+nphi)
parinfo[0:2].fixed = TRUE       ;vbias, fbias, rload fixed
parinfo[4].fixed = TRUE       ;gain fixed

parinfo[3].limited = [TRUE,TRUE]
parinfo[3].limits = [20,200]    ; limits on cline

parinfo[5:*].limited = [TRUE,TRUE]
parinfo[5:*].limits = [160,230]   ; limits on phi

parinfo[0].parname = 'vbias [mv]  '
parinfo[1].parname = 'fbias [Hz]  '
parinfo[2].parname = 'rload [MOhm]'
parinfo[3].parname = 'cline [pF]  '
parinfo[4].parname = 'gain        '
parinfo[5].parname = 'phi0  [Deg] '

;Create variables to hold fit info
all_fitparams = DBLARR(nbolo,N_E(parinfo))
all_iterations = INTARR(nbolo)
all_fiterr = DBLARR(nbolo,N_E(parinfo))
all_fiterrscaled = DBLARR(nbolo,N_E(parinfo))
all_sqresid = DBLARR(nbolo)
all_fitsin = INTARR(nbolo)

all_quadsum_fit = DBLARR(nbolo,N_E(optical_sin[0,*]))
all_vifit = DBLARR(nbolo,N_E(optical_sin[0,*]))
all_vrfit = DBLARR(nbolo,N_E(optical_sin[0,*]))

FOR bolo = 0, nbolo-1 DO BEGIN
   time = SYSTIME(1)
   PRINT, 'Fitting Bolo #', bolo
   bolosin = REFORM(optical_sin[bolo,*])
   bolocos = REFORM(optical_cos[bolo,*])
   bolosinerr = REFORM(optical_sinerr[bolo,*])
   bolocoserr = REFORM(optical_coserr[bolo,*])
   
   indvar = [[bolosin],[bolocos]]
   depenvar = bolosin^2 + bolocos^2
   depenerr = 2.*SQRT(bolosin^2*bolosinerr^2 + bolocos^2*bolocoserr^2)
   
   zeroerr = WHERE(depenerr EQ 0, nzero, $
                   COMPLEMENT = nonzeroerr, NCOMPLEMENT = nnonzero)
   IF nzero NE 0 THEN BEGIN
      IF nnonzero NE 0 THEN BEGIN
         depenerr[zeroerr] = 10*MEAN(depenerr[nonzeroerr])
      ENDIF ELSE BEGIN
         depenerr[zeroerr] = 0.1
      ENDELSE
   ENDIF
   
   startpar = [vbias,fbias,rload[bolo],cline,gain,$
               REPLICATE(phi,nphi)]
   
   fitparams = $
      mpfitfun('brm_quadsum_multiphi_fitfun',indvar,depenvar,depenerr,$
               startpar, PARINFO = parinfo, yfit = quadsum_fit, $
               MAXITER = 50, NPRINT = 5, /QUIET, NITER = iterations,$
               DOF = degfree, BESTNORM = sqresid, PERROR = fiterr,$
               FUNCTARGS = CREATE_STRUCT('phiranges',phiranges))
   
   all_fitparams[bolo,*] = fitparams
   all_iterations[bolo] = iterations
   all_fiterr[bolo,*] = fiterr
   all_fiterrscaled[bolo,*] = fiterr*SQRT(sqresid/degfree)
   all_sqresid[bolo] = sqresid
   
   sinrange = MAX(bolosin) - MIN(bolosin)
   cosrange = MAX(bolocos) - MIN(bolocos)
   IF sinrange GE cosrange THEN fitsin = TRUE ELSE fitsin = FALSE
   all_fitsin[bolo] = fitsin

   all_quadsum_fit[bolo,*] = quadsum_fit
   all_vifit[bolo,*] = $
      brm_vi_multiphi_fitfun(bolosin,fitparams,$
                             _EXTRA = CREATE_STRUCT('phiranges',phiranges))
   all_vrfit[bolo,*] = $
      brm_vr_multiphi_fitfun(bolocos,fitparams,$
                             _EXTRA = CREATE_STRUCT('phiranges',phiranges))

   PRINT, 'Time to fit = ', SYSTIME(1) - time, ' seconds'
;   blah = ''
;   READ, blah
ENDFOR

SAVE, FILENAME = !ZSPEC_PIPELINE_ROOT + $
      PATH_SEP() + 'bolo_rolloff' + $
      PATH_SEP() + 'fit_data' + $
      PATH_SEP() + 'all_fit_files' + $
      PATH_SEP() + fit_results_savefile

END
