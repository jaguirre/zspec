;; A wrapper function for doing line fitting to Z-Spec data.  This function
;; fits for single-peaked line profiles (suitable for most sources).  

;; fitfreqid are the indicies of the channels that should be used for fitting
;; spec_in and specerr_in are the dependent variable to fit (and the error).
;; IF spec_in has more elements in it than fitfreqid, then fitting will occur
;; with respect to spec_in[fitfreqid].  redshift is the redshift of the source
;; in units of km/s.  species and transitions are arrays that identify
;; which lines to use in the fit (eg. CO 2-1) SEE make_template_spec
;; for species definitions.  amps are the guesses for
;; the overall amplitude of those lines.  

;; This function has several keywords.  CONT_START_PAR if set must be a three
;; element vector with the starting guesses for the continuum fitting 
;; parameters.  The first is the frequency normalizing factor (typically 
;; 240 GHz) and won't be adjusted for the fit.  The second term is the 
;; amplitude of the continuum power law and the third is the exponent.  If
;; this keyword is not set, then no continuum fitting occurs.
;; If Z_FIXED (default =  FALSE) is set, then the redshift is not 
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
;;
;; BINFREQID can be set to the frequency ID below which channels
;; will be binned together in pairs.  60 is a sensible value.  If this
;; is set, then fitfreqid is assumed to be a binned index such that
;; a properly binned & unbinned vector can be indexed with fitfreqid.
;; This also implied that spec_in & specerr_in are already binned/not binned.


FUNCTION fit_lines, fitfreqid, spec_in, specerr_in, $
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

  linenames = ['CO','13CO','C18O','CN','CCH',$
               'HCN','HCO+','HNC','CS','SiO','HCNH+','HOC+','Mystery']
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
                                    'parname',''),params_perline*nspecies+3)

  ampind = params_perline*INDGEN(nspecies)
  widthind = params_perline*INDGEN(nspecies)+1
  redind = params_perline*INDGEN(nspecies)+2

  parinfo[ampind].value = amps
  parinfo[ampind].limits = TRANSPOSE([[0.0*amps],[3.0*amps]])
  parinfo[ampind].parname = 'Amplitude ' + fitlinestring

  parinfo[widthind].value = LW_VALUE
  parinfo[widthind].fixed = LW_FIXED
  parinfo[widthind].limits = [70.,1000.]
  parinfo[widthind].parname = 'Line Width ' + fitlinestring
  IF LW_TIED AND nspecies GT 1 THEN parinfo[widthind[1:*]].tied = 'P(1)'

  parinfo[redind].value = redshift ; in units of km/s
  parinfo[redind].fixed = Z_FIXED
  parinfo[redind].limits = redshift + 1000*[-1,1]
  parinfo[redind].parname = 'Redshift ' + fitlinestring
  
; The redshifts of the multiple lines should be tied together, 
; except for the splitted lines CN & CCH & Mystery Line (Species ID 3 & 4 & 13)
  IF nspecies GT 1 THEN BEGIN
     splits = WHERE((species EQ 3) OR (species EQ 4) OR $
                    (species_for_names EQ 13), nsplits, $
                    COMPLEMENT = purerot, NCOMPLEMENT = npurerot)
     IF nsplits GT 0 THEN parinfo[redind[splits]].fixed = transitions[splits]
     IF npurerot GT 1 THEN BEGIN
        parinfo[redind[purerot[1:*]]].tied = $
           'P(' + STRING(params_perline*purerot[0]+2,F='(I0)') + ')'
     ENDIF
  ENDIF

  IF fit_cont THEN BEGIN
     ckneeind = params_perline*nspecies+0
     campind = params_perline*nspecies+1
     cexpind = params_perline*nspecies+2
     parinfo[ckneeind].value = CONT_START_PAR[0]
     parinfo[ckneeind].fixed = TRUE
     parinfo[ckneeind].limits = [0.0,3.0]*CONT_START_PAR[0]
     parinfo[ckneeind].parname = 'Continuum Knee'
     parinfo[campind].value = CONT_START_PAR[1]
     parinfo[campind].limits = [0.0,3.0]*CONT_START_PAR[1]
     parinfo[campind].parname = 'Continuum Amplitude'
     parinfo[cexpind].value = CONT_START_PAR[2]
     parinfo[cexpind].limits = [-3.0,3.0]*CONT_START_PAR[2]
     parinfo[cexpind].parname = 'Continuum Exponent'
  ENDIF ELSE BEGIN
     parinfo = parinfo[0:params_perline*nspecies-1]
  ENDELSE

;stop
;; Do fitting if requested
  IF ~(NO_FIT) THEN BEGIN
     fitparams = $
        mpfitfun('line_cont_fitfun',indvar,fitspec,fiterr,$
                 PARINFO = parinfo, DOF = degfree, BESTNORM = sqresid,$
                 PERROR = parerr, FUNCTARGS = functargs, COVAR = covar)
  ENDIF ELSE BEGIN
     fitparams = parinfo.value
     parerr = REPLICATE(0.0,N_E(fitparams))
     degfree = 1
     sqresid = 0
     covar = 0
  ENDELSE

  lcspec = line_cont_fitfun(indvar,fitparams,scales,centers,$
                            _EXTRA = CREATE_STRUCT('nu_fts',nu_trim,$
                                                   'ftsspec',$
                                                   spec_coadd_norm))
  IF FIT_CONT THEN BEGIN
     cspec = make_cont_spec(nu_trim, spec_coadd_norm, $
                            fitparams[ckneeind],$
                            fitparams[campind],$
                            fitparams[cexpind])
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
                           'cknee',fitparams[ckneeind],$
                           'camp',fitparams[campind],$
                           'caerr',parerr[campind],$
                           'cexp',fitparams[cexpind],$
                           'ceerr',parerr[cexpind],$
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
                           'cknee',0.,$
                           'camp',0.,$
                           'caerr',0.,$
                           'cexp',0.,$
                           'ceerr',0.,$
                           'linename',fitlinestring,$
                           'freqshift',FREQSHIFT,$
                           'covar', covar)
  ENDELSE

END
 
