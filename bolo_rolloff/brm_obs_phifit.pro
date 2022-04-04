; This function computes the best fit phi for the given bolometer timestreams

; UPDATE 22 JUL 07 - Added fbias argument because downsampling 
;                    changes relationship between sampint & fbias
FUNCTION brm_obs_phifit, bolosin, bolocos, bias, $
                         sampint, rload, cline, fbias

; Make local copies of the passed timestreams 
; so that the originals are not modified
  vr = bolosin
  vi = bolocos

; First downsample vr & vi into 5 second long bins
  MESSAGE, /INFO, 'Downsampling timestreams'
  binsize = LONG(5./sampint)
  
  ts_size = SIZE(vr)
  nbolos = ts_size[1]
  nsamps = ts_size[2]
  
  nbins = FLOOR(nsamps/binsize)
  nsamps_trim = binsize*nbins
  vr = vr[*,0:nsamps_trim-1]
  vi = vi[*,0:nsamps_trim-1]
  
  vr_mean = REBIN(vr,nbolos,nbins)
  vi_mean = REBIN(vi,nbolos,nbins)
  vr2_mean = REBIN(vr^2,nbolos,nbins)
  vi2_mean = REBIN(vi^2,nbolos,nbins)
  vr_err = SQRT((binsize/FLOAT(binsize - 1))*$
                (vr2_mean - vr_mean^2))/SQRT(binsize)
  vi_err = SQRT((binsize/FLOAT(binsize - 1))*$
                (vi2_mean - vi_mean^2))/SQRT(binsize)

  vr = vr_mean
  vi = vi_mean

; Next set up for fitting
  TRUE = 1
  FALSE = 0
  parinfo = REPLICATE({fixed:FALSE, $
                       limited:[FALSE,FALSE], $
                       limits:[0.D,0.D], $
                       parname:''},6)

  parinfo[0].parname = 'vbias [mv]  '
  parinfo[1].parname = 'fbias [Hz]  '
  parinfo[2].parname = 'rload [MOhm]'
  parinfo[3].parname = 'cline [pF]  '
  parinfo[4].parname = 'gain        '
  parinfo[5].parname = 'phi0  [Deg] '

  gain = 138.D
  phi = 194.D

  parinfo[0:4].fixed = TRUE
  parinfo[5].limited = [TRUE,TRUE]
  parinfo[5].limits = [160,280]
  
  phifit = DBLARR(nbolos)
  phierr = DBLARR(nbolos)
  
  MESSAGE,/INFO,'Fitting the data'
  FOR bolo = 0, nbolos - 1 DO BEGIN
;     PRINT, 'Fitting Bolo #', bolo
     bolovr = REFORM(vr[bolo,*])
     bolovi = REFORM(vi[bolo,*])
     bolovr_err = REFORM(vr_err[bolo,*])
     bolovi_err = REFORM(vi_err[bolo,*])

     indvar = [[bolovr],[bolovi]]
     depenvar = bolovr^2 + bolovi^2
     depenerr = 2.*SQRT(bolovr^2*bolovr_err^2 + bolovi^2*bolovi_err^2)

; Correct if there are any points with zero error (or all points)
     zeroerr = WHERE(depenerr EQ 0, nzero, $
                     COMPLEMENT = nonzeroerr, NCOMPLEMENT = nnonzero)
     IF nzero NE 0 THEN BEGIN
        IF nnonzero NE 0 THEN BEGIN
           depenerr[zeroerr] = 10*MEAN(depenerr[nonzeroerr])
        ENDIF ELSE BEGIN
           depenerr[zeroerr] = 0.1*depenvar[zeroerr]
        ENDELSE
     ENDIF

     startpar = [bias*1000.D,fbias,rload[bolo],cline[bolo],gain,phi]
     fitparams = $
        mpfitfun('brm_quadsum_multiphi_fitfun',indvar,depenvar,depenerr,$
                 startpar, PARINFO = parinfo, $
                 MAXITER = 50, NPRINT = 5, /QUIET,$
                 DOF = degfree, BESTNORM = sqresid, PERROR = fiterr)
     phifit[bolo] = fitparams[5]
     phierr[bolo] = fiterr[5]*SQRT(sqresid/degfree)
  ENDFOR
  
  RETURN, CREATE_STRUCT('value', phifit, $
                        'error', phierr)
END
