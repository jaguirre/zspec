;; A wrapper function for doing line fitting to Z-Spec data.  This function
;; fits for single-peaked line profiles (suitable for most sources).  

;; fitfreqid are the indicies of the channels that should be used for fitting
;; spec_in and specerr_in are the dependent variable to fit (and the error).
;; IF spec_in has more elements in it than fitfreqid, then fitting will occur
;; with respect to spec_in[fitfreqid].  redshift is the redshift of the source
;; in units of km/s.  species and transitions are arrays that identify
;; which lines to use in the fit (eg. CO 2-1) SEE make_template_spec
;; for species definitions.  amps are the guesses for
;; the overall amplitude of those lines.  Elements in species that
;; fall in the range from 180 to 320 are assumed to be "mystery lines"
;; and the value of that element is the rest frequency [in GHz] of the mystery
;; line.  If the corresponding element in the transitions vector is
;; set to 1 then the fitting routine locks the redshift of the
;; mystery-line with the redshift of the other fitted lines.  If the
;; element in transitions is not equal to 1 then the redshift for that
;; feature is allowed to float (like it does for CCH & CN).

;; This function has several keywords.  

;; CONT_START_PAR if set must be a four
;; element vector with the starting guesses for the continuum fitting 
;; parameters.  There are two modes of continuum fitting - one is a 
;; simple power law fit which is generally useful and the other is a
;; thermal dust spectrum plus free-free emission which is only really 
;; useful for M82.  The simple power law fit will be used if
;; the second element of CONT_START_PAR is set to 0.0.  In this case,
;; the first element should be the amplitude of the continuum at 240
;; GHz and the third element is the power law exponent.  The fouth
;; element is tied to the first and not used in this mode.  
;; The other fitting method is used when
;; the second element of CONT_START_PAR is non-zero and it is
;; interpreted as the temperature of the dust emission (with an
;; assumed graybody beta of 1.3 (the value for M82).  The first
;; element will be the fraction of thermal emission and the fourth
;; element is the fraction of free-free emission (tied to the thermal
;; fraction, by default).  The third element is the exponent of an overall
;; power-law dependence with a reference frequency of 240 GHz, though
;; the actual power-law exponent is "third element" - 2.  This is
;; somewhat useful for M82 and probably not that useful for any other
;; source.  Please use this second mode with caution (or modify it to
;; work better for a larger variety of sources).  The continuum
;; spectrum calculation occurs in hughes94_fitfun.pro.  If
;; this keyword is not set, then no continuum fitting occurs.

;; If Z_FIXED (default = FALSE) is set, then the redshift is not 
;; adjusted by the fitting.

;; The LW_* parameters control how the line widths are controlled during
;; the fitting.  LW_VALUE is the starting value for all lines IF LW_FIXED
;; is set, then the linewidths are not adjusted by the fitting routine.
;; If LW_TIED is set, then the widths for all lines have to be equal to 
;; each other.  The default values for these parameters are 200 km/s, 
;; FALSE & FALSE, respectively.

;; If NO_FIT is set then no fitting occurs and the input parameters are
;; returned (in the same form as if fitting did occur).

;; If FREQSHIFT is set then the FTS frequencies are shifted by 
;; 1.0/(1.0+FREQSHIFT/speed_of_light).  FREQSHIFT should be in km/s

;; BINFREQID can be set to the frequency ID below which channels
;; will be binned together in pairs.  60 is a sensible value.  If this
;; is set, then fitfreqid is assumed to be a binned index such that
;; a properly binned & unbinned vector can be indexed with fitfreqid.
;; This also implies that spec_in & specerr_in are already binned/not binned.


FUNCTION fit_lines_planck, fitfreqid, spec_in, specerr_in, $
                           redshift, species, transitions, amps, $
                           CONT_START_PAR = CONT_START_PAR, $
                           Z_FIXED = Z_FIXED, $
                           LW_VALUE = LW_VALUE, $
                           LW_TIED = LW_TIED, $
                           LW_FIXED = LW_FIXED, $
                           NO_FIT = NO_FIT, $
                           FREQSHIFT = FREQSHIFT, $
                           BINFREQID = BINFREQID

  sol = 299792.458 
  nbolos = 160
  temp = species/(1.D + (redshift/sol))
  unknown_lines = WHERE(temp GT 180. AND temp LT 320., nun_lines)

  linenames = ['CO','13CO','C18O','CN','C2H',$
               'HCN','HCO+','HNC','CS','SiO','HCNH+','HOC+','Mys']
  species_for_names = species
  IF nun_lines GT 0 THEN species_for_names[unknown_lines] = 13
  fitlinestring = linenames[species_for_names] + ' ' + $
                  STRING(transitions, F ='(I0)') + ' to ' + $
                  STRING(transitions-1, F ='(I0)')

  IF nun_lines GT 0 THEN BEGIN
     FOR i = 0, nun_lines-1 DO BEGIN
        fitlinestring[unknown_lines[i]] = $
           'Mys ' + STRING(species[unknown_lines[i]],F='(I03)') + ' ' + $
           'ZFIX ' + STRING(transitions[unknown_lines[i]], F ='(I0)')
     ENDFOR
  ENDIF

        
; Reindex spec_in & specerr_in as necessary
  IF N_E(spec_in) GT N_E(fitfreqid) THEN BEGIN
     fitspec = spec_in[fitfreqid]
     fiterr = specerr_in[fitfreqid]
  ENDIF ELSE BEGIN
     fitspec = spec_in
     fiterr = specerr_in
  ENDELSE

  ; Control default values for keywords
  TRUE = 1
  FALSE = 0
  IF ~KEYWORD_SET(Z_FIXED) THEN Z_FIXED = FALSE

  IF ~KEYWORD_SET(LW_VALUE) THEN LW_VALUE = 200 ; km/sec
  IF ~KEYWORD_SET(LW_TIED) THEN LW_TIED = FALSE
  IF ~KEYWORD_SET(LW_FIXED) THEN LW_FIXED = FALSE

  fit_cont = KEYWORD_SET(CONT_START_PAR) 

  IF ~KEYWORD_SET(NO_FIT) THEN NO_FIT = FALSE

  ; Load in FTS data
  RESTORE, !ZSPEC_PIPELINE_ROOT + $
           '/line_cont_fitting/ftsdata/normspec_nov.sav'

  IF KEYWORD_SET(FREQSHIFT) THEN $
     nu_trim *= 1.0/(1.0+FREQSHIFT/sol) $
  ELSE FREQSHIFT = 0.0

  ; Bin spec_coadd_norm as necessary
  IF KEYWORD_SET(BINFREQID) THEN BEGIN
     bin_spec_coadd = DBLARR(nbolos/2,N_E(nu_trim))
     FOR i = 0, nbolos/2 - 1 DO BEGIN
        bin_spec_coadd[i,*] = (spec_coadd_norm[2*i,*] + $
                               spec_coadd_norm[2*i + 1,*])/2.
     ENDFOR
     spec_coadd_temp = [bin_spec_coadd[0:(BINFREQID/2)-1,*],$
                        spec_coadd_norm[BINFREQID:*,*]]
     spec_coadd_norm = spec_coadd_temp
  ENDIF

  functargs = CREATE_STRUCT('nu_fts',nu_trim,$
                            'ftsspec',spec_coadd_norm[fitfreqid,*])

  ; Join together the species, & transitions & splitting together
  ; to make the "independent variable'
  indvar = CREATE_STRUCT('species',species,$
                         'transitions',transitions)

; Create parinfo structure based on 
; amps & LW_*, CONT_START_PAR and Z_FIXED

  nspecies = N_ELEMENTS(species)
  params_perline = 3
  parinfo = REPLICATE(CREATE_STRUCT('value',0.D,$
                                    'fixed',FALSE,$
                                    'limited',[TRUE,TRUE],$
                                    'limits',[0.D,0.D],$
                                    'tied','',$
                                    'parname',''),params_perline*nspecies+4)

  ampind = params_perline*INDGEN(nspecies)
  widthind = params_perline*INDGEN(nspecies)+1
  redind = params_perline*INDGEN(nspecies)+2

  parinfo[ampind].value = amps
  parinfo[ampind].limits = TRANSPOSE([[-3.0*amps],[3.0*amps]])
  parinfo[ampind].parname = 'Amplitude ' + fitlinestring

;;   co13 = WHERE(species EQ 1)
;;   co18 = WHERE(species EQ 2)
;;   IF co13 NE -1 AND co18 NE -1 THEN BEGIN
;;      parinfo[ampind[co18]].tied = $
;;      '0.2*P(' + STRING(ampind[co13],F='(I0)') + ')'
;;      parinfo[ampind[co18]].limits = $
;;         0.2*[0.0,3.0*amps[co13]]
;;   ENDIF

  parinfo[widthind].value = LW_VALUE
  parinfo[widthind].fixed = LW_FIXED
  parinfo[widthind].limits = [70.,1000.]
  parinfo[widthind].parname = 'Line Width ' + fitlinestring
  
;;   coind = WHERE(species EQ 0, $
;;                 COMPLEMENT = notco, NCOMPLEMENT = nnotco)
;;   IF coind NE -1 THEN BEGIN
;;      parinfo[widthind[coind]].fixed = 0
;;      parinfo[widthind[coind]].tied = ''
;;   ENDIF
;;   IF LW_TIED AND nnotco GT 1 THEN $
;;      parinfo[widthind[notco[1:*]]].tied = $
;;      'P(' + STRING(widthind[notco[0]],F='(I0)') + ')'
  IF LW_TIED AND nspecies GT 1 THEN $
     parinfo[widthind[1:*]].tied = $
     'P(' + STRING(widthind[0],F='(I0)') + ')'

  parinfo[redind].value = redshift ; in units of km/s
  parinfo[redind].fixed = Z_FIXED
  parinfo[redind].limits = redshift + 1000*[-1,1]
  parinfo[redind].parname = 'Redshift ' + fitlinestring
  
; The redshifts of the multiple lines should be tied together, 
; except for the splitted lines CN & CCH & Mystery Line 
; (Species ID 3 & 4 & 13), unless the mystery line transition # = 1,
; then it should be tied in with the other transitions.
  IF nspecies GT 1 THEN BEGIN
     splits = WHERE((species EQ 3) OR (species EQ 4) OR $
                    (species_for_names EQ 13), nsplits, $
                    COMPLEMENT = purerot, NCOMPLEMENT = npurerot)
     FOR isplit = 0, nsplits - 1 DO BEGIN
        currsplit = splits[isplit]
        IF species_for_names[currsplit] EQ 13 AND $
           transitions[currsplit] EQ 1 THEN BEGIN
           IF npurerot EQ 0 THEN $
              purerot = [currsplit] $
           ELSE purerot = [purerot,currsplit]
           npurerot += 1
        ENDIF ELSE BEGIN
           parinfo[redind[currsplit]].fixed = transitions[currsplit]
        ENDELSE
     ENDFOR
     IF npurerot GT 1 THEN BEGIN
        parinfo[redind[purerot[1:*]]].tied = $
           'P(' + STRING(params_perline*purerot[0]+2,F='(I0)') + ')'
     ENDIF
  ENDIF

  IF fit_cont THEN BEGIN
     campind = params_perline*nspecies+0
     ctempind = params_perline*nspecies+1
     cexpind = params_perline*nspecies+2
     cffamp = params_perline*nspecies+3
     parinfo[campind].value = CONT_START_PAR[0]
     parinfo[campind].limits = [0.05,0.9];[0.0,3.0]*CONT_START_PAR[0]
     parinfo[campind].parname = 'Therm Fraction'
     parinfo[ctempind].value = CONT_START_PAR[1]
     parinfo[ctempind].limits = [0,150];[0.5,1.5]*CONT_START_PAR[1]
     parinfo[ctempind].parname = 'Therm Cont Temp'
     parinfo[ctempind].fixed = TRUE
     parinfo[cexpind].value = CONT_START_PAR[2]
     parinfo[cexpind].limits = [-3.0,3.0];[-3.0,3.0]*CONT_START_PAR[2]
     parinfo[cexpind].parname = 'Spatial Dist Exp'
;     parinfo[cexpind].fixed = TRUE
     parinfo[cffamp].value = CONT_START_PAR[3]
     parinfo[cffamp].limits = [0.05,0.9];[0.0,3.0]*CONT_START_PAR[3]
     parinfo[cffamp].parname = 'Free-Free Fraction'
;     parinfo[cffamp].fixed = TRUE
     parinfo[cffamp].tied = 'P(' + STRING(campind,F='(I0)') + ')'
  ENDIF ELSE BEGIN
     parinfo = parinfo[0:params_perline*nspecies-1]
  ENDELSE

;stop
;; Do fitting if requested
  IF ~(NO_FIT) THEN BEGIN
     fitparams = $
        mpfitfun('line_cont_planck_fitfun',indvar,fitspec,fiterr,$
                 PARINFO = parinfo, DOF = degfree, BESTNORM = sqresid,$
                 PERROR = parerr, FUNCTARGS = functargs, COVAR = covar)
  ENDIF ELSE BEGIN
     fitparams = parinfo.value
     parerr = REPLICATE(0.0,N_E(fitparams))
     degfree = 1
     sqresid = 0
     covar = 0
  ENDELSE

  lcspec = line_cont_planck_fitfun(indvar,fitparams,scales,centers,$
                                    _EXTRA = CREATE_STRUCT('nu_fts',nu_trim,$
                                                           'ftsspec',$
                                                   spec_coadd_norm))
  IF FIT_CONT THEN BEGIN
     cspec = make_cont_spec_planck(nu_trim, spec_coadd_norm, $
                                   fitparams[campind],$
                                   fitparams[ctempind],$
                                   fitparams[cexpind],$
                                   fitparams[cffamp])
     RETURN, CREATE_STRUCT('lcspec',lcspec,$
                           'cspec',cspec,$
                           'center',centers,$
                           'scale',scales,$
                           'amp',fitparams[ampind],$
                           'aerr',parerr[ampind],$
                           'width',fitparams[widthind],$
                           'werr',parerr[widthind],$
                           'redchi',sqresid/degfree,$
                           'dof', degfree,$
                           'redshift',fitparams[redind],$
                           'zerr',parerr[redind],$
                           'camp',fitparams[campind],$
                           'caerr',parerr[campind],$
                           'ctemp',fitparams[ctempind],$
                           'cterr',parerr[ctempind],$
                           'cexp',fitparams[cexpind],$
                           'ceerr',parerr[cexpind],$
                           'cffamp',fitparams[cffamp],$
                           'cferr',parerr[cffamp],$
                           'linename',fitlinestring,$
                           'freqshift',FREQSHIFT,$
                           'covar', covar)
  ENDIF ELSE BEGIN
     RETURN, CREATE_STRUCT('lcspec',lcspec,$
                           'cspec',0.,$
                           'center',centers,$
                           'scale',scales,$
                           'amp',fitparams[ampind],$
                           'aerr',parerr[ampind],$
                           'width',fitparams[widthind],$
                           'werr',parerr[widthind],$
                           'redchi',sqresid/degfree,$
                           'dof', degfree,$
                           'redshift',fitparams[redind],$
                           'zerr',parerr[redind],$
                           'camp',0.,$
                           'caerr',0.,$
                           'ctemp',0,$
                           'cterr',0,$
                           'cexp',0.,$
                           'ceerr',0.,$
                           'cffamp',0.,$
                           'cferr',0.,$
                           'linename',fitlinestring,$
                           'freqshift',FREQSHIFT,$
                           'covar', covar)
  ENDELSE

END
 
