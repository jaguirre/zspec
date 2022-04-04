;; A wrapper function for doing line fitting to Z-Spec data.  This function
;; fits for double-peaked line profiles (as would be seen in M82).  

;; fitfreqid are the indicies of the channels that should be used for fitting
;; spec_in and specerr_in are the dependent variable to fit (and the error).
;; IF spec_in has more elements in it than fitfreqid, then fitting will occur
;; with respect to spec_in[fitfreqid].  redshift is the redshift of the source
;; in units of km/s.  species and transitions are arrays that identify
;; which lines to use in the fit (eg. CO 2-1).  amps are the guesses for
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
;; The DEL_* parameters control how the difference between the two heights the
;; peaks in the assumed line profile are handled by the fitting routine.  
;; DEL_VALUE is the starting value of this parameter for all lines 
;; (default value = 0) and DEL_FIXED (default = FALSE) keeps this parameter
;; fixed for the fitting.
;; SPLITTING is the value of the separation between the two line components
;; (default is 200 km/s)
;; If NO_FIT is set then no fitting occurs and the input parameters are
;; returned (in the same form as if fitting did occur).


FUNCTION fit_dlines, fitfreqid, spec_in, specerr_in, $
                     redshift, species, transitions, amps, $
                     CONT_START_PAR = CONT_START_PAR, $
                     Z_FIXED = Z_FIXED, $
                     LW_VALUE = LW_VALUE, $
                     LW_TIED = LW_TIED, $
                     LW_FIXED = LW_FIXED, $
                     DEL_VALUE = DEL_VALUE, $
                     DEL_FIXED = DEL_FIXED, $
                     SPLITTING = SPLITTING, $
                     NO_FIT = NO_FIT
                     

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

  IF ~KEYWORD_SET(DEL_VALUE) THEN DEL_VALUE = 0
  IF ~KEYWORD_SET(DEL_FIXED) THEN DEL_FIXED = FALSE

  IF ~KEYWORD_SET(SPLITTING) THEN SPLITTING = 200 ; km/sec

  fit_cont = KEYWORD_SET(CONT_START_PAR) 

  IF ~KEYWORD_SET(NO_FIT) THEN NO_FIT = FALSE

  ; Load in FTS data
  RESTORE, /VERBOSE, !ZSPEC_PIPELINE_ROOT + $
           '/line_cont_fitting/ftsdata/normspec_nov.sav'
  functargs = CREATE_STRUCT('nu_fts',nu_trim,$
                            'ftsspec',spec_coadd_norm[fitfreqid,*])

  ; Join together the species, & transitions & splitting together
  ; to make the "independent variable'
  indvar = CREATE_STRUCT('species',species,$
                         'transitions',transitions,$
                         'splitting',SPLITTING) ; in km/s
  
; Create parinfo structure based on 
; amps & LW_*, DEL_*, CONT_START_PAR and Z_FIXED

  nspecies = N_ELEMENTS(species)
  parinfo = REPLICATE(CREATE_STRUCT('value',0.D,$
                                    'fixed',FALSE,$
                                    'limited',[TRUE,TRUE],$
                                    'limits',[0.D,0.D],$
                                    'tied','',$
                                    'parname',''),3*nspecies+4)
  ampind = 3*INDGEN(nspecies)
  delind = 3*INDGEN(nspecies)+1
  widthind = 3*INDGEN(nspecies)+2

  parinfo[ampind].value = amps
  parinfo[ampind].limits = TRANSPOSE([[0.0*amps],[3.0*amps]])
  parinfo[ampind].parname = 'Amplitude ' + STRING(INDGEN(nspecies),F='(I0)')

  parinfo[delind].value = DEL_VALUE
  parinfo[delind].fixed = DEL_FIXED
  parinfo[delind].limits = TRANSPOSE([[-3.0*amps],[3.0*amps]])
  parinfo[delind].parname = 'Delta Amp ' + STRING(INDGEN(nspecies),F='(I0)')

  parinfo[widthind].value = LW_VALUE
  parinfo[widthind].fixed = LW_FIXED
  parinfo[widthind].limits = [70.,1000.]
  parinfo[widthind].parname = 'Line Width ' + STRING(INDGEN(nspecies),F='(I0)')
  IF LW_TIED AND nspecies GT 1 THEN parinfo[widthind[1:*]].tied = 'P(2)'

  redind = 3*nspecies
  parinfo[redind].value = redshift ; in units of km/s
  parinfo[redind].fixed = Z_FIXED
  parinfo[redind].limits = redshift + [-500,500]
  parinfo[redind].parname = 'Redshift'

  IF fit_cont THEN BEGIN
     ckneeind = 3*nspecies+1
     campind = 3*nspecies+2
     cexpind = 3*nspecies+3
     parinfo[ckneeind].value = CONT_START_PAR[0]
     parinfo[ckneeind].fixed = TRUE
     parinfo[ckneeind].limits = [0.0,3.0]*CONT_START_PAR[0]
     parinfo[ckneeind].parname = 'Continuum Knee'
     parinfo[campind].value = CONT_START_PAR[1]
     parinfo[campind].limits = [0.0,3.0]*CONT_START_PAR[1]
     parinfo[campind].parname = 'Continuum Amplitude'
     parinfo[cexpind].value = CONT_START_PAR[2]
     parinfo[cexpind].limits = [0.0,3.0]*CONT_START_PAR[2]
     parinfo[cexpind].parname = 'Continuum Exponent'
  ENDIF ELSE BEGIN
     parinfo = parinfo[0:redind]
  ENDELSE

;; Do fitting if requested
  IF ~(NO_FIT) THEN BEGIN
     fitparams = $
        mpfitfun('doubleline_cont_fitfun',indvar,fitspec,fiterr,$
                 PARINFO = parinfo, DOF = degfree, BESTNORM = sqresid,$
                 PERROR = parerr, FUNCTARGS = functargs)
  ENDIF ELSE BEGIN
     fitparams = parinfo.value
     parerr = REPLICATE(0.0,N_E(fitparams))
     degfree = 1
     sqresid = 0
  ENDELSE

  lcspec = doubleline_cont_fitfun(indvar,fitparams,scales,centers,$
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
                           'del',fitparams[delind],$
                           'derr',parerr[delind],$
                           'width',fitparams[widthind],$
                           'werr',parerr[widthind],$
                           'redchi',sqresid/degfree,$
                           'dof', degfree,$
                           'splitting',SPLITTING,$
                           'redshift',fitparams[redind],$
                           'zerr',parerr[redind],$
                           'cknee',fitparams[ckneeind],$
                           'camp',fitparams[campind],$
                           'caerr',parerr[campind],$
                           'cexp',fitparams[cexpind],$
                           'ceerr',parerr[cexpind])
  ENDIF ELSE BEGIN
     RETURN, CREATE_STRUCT('lcspec',lcspec,$
                           'cspec',0.,$
                           'center',centers,$
                           'scale',scales,$
                           'amp',fitparams[ampind],$
                           'aerr',parerr[ampind],$
                           'del',fitparams[delind],$
                           'derr',parerr[delind],$
                           'width',fitparams[widthind],$
                           'werr',parerr[widthind],$
                           'redchi',sqresid/degfree,$
                           'dof', degfree,$
                           'splitting',SPLITTING,$
                           'redshift',fitparams[redind],$
                           'zerr',parerr[redind],$
                           'cknee',0.,$
                           'camp',0.,$
                           'caerr',0.,$
                           'cexp',0.,$
                           'ceerr',0.)
  ENDELSE

END
 
