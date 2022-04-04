; This function takes the original chopper (orig_chop) encoder time stream
; and creates in-phase sine & cosine waves of the same period.  It returns
; a chopper structure with the following elements:
;       sin = pure tone in phase with chopper with mask applied
;       cos = pure tone out of phase with chopper with mask applied
;       sin1 = pure tone in phase with chopper at fundamental (~1Hz)
;       cos1 = pure tone out of phase with chopper at fundamental
;       sin3 = pure tone in phase with chopper at 2nd harmonic (~3Hz)
;       cos3 = pure tone out of phase with chopper at 2nd harmonic
;       sin5 = pure tone in phase with chopper at 4th harmomic (~5Hz)
;       cos5 = pure tone out of phase with chopper at 4th harmonic
;       psd = psd structure (2 tags: .psd & .freq)
;       amp3 = ratio of 2nd harmonic peak to fundamental peak in psd
;       amp5 = ratio of 4th harmonic peak to fundamental peak in psd
;       phase = phase angle of chopper with mask applied
;       mask = a masked out region where chopper problems occur
;              each masked out region is n chop cycles long (n = integer)
;       period = period of chopper
;       clean = same waveform as orig_chop, with mean subtracted, and
;               scaled to have peaks at +/- 1
; It also applies the chopper mask to the given dataflags argument.  
; If HARMONIC is set to an integer n > 0 then the sin and cos waves are
; the n-th harmonic.  If it is set to zero or not set, then the waves are
; at the fundamental.  Only sin & cos are effected by the HARMONIC keyword,
; not phase or period which are always based on the fundamental.  The 
; additional waves (sin1,sin3,sin5,cos1,cos3,cos5) are also uneffected
; by the keyword HARMONIC
;
; An easy way to phase shift the given results is to use IDL matrix 
; multiplication like so.  If the returned value is stored in chop
; and the desired phase shift (either for a single channel or multiple 
; channels is phase then
;
;   [[COS(phase)],[-1.0*SIN(PHASE)]] # TRANSPOSE([[chop.sin],[chop.cos]])
;
; or MATRIX_MULTIPLY([[COS(phase)],[-1.0*SIN(PHASE)]], $
;                    [[chop.sin],[chop.cos]], /BTRANSPOSE) which is more
;                                                          efficient
;
; will be an timestream vector (or matrix if phase is a vector) with a 
; phase-shifted pure tone wave.

FUNCTION make_chop_struct, orig_chop, dataflags, $
                           HARMONIC = HARMONIC, $
                           SAMPLE_INTERVAL = SAMPLE_INTERVAL, quiet = quiet

if ~keyword_set(quiet) then quiet = 0

  IF KEYWORD_SET(HARMONIC) THEN HARMONIC = HARMONIC ELSE HARMONIC = 0
  IF KEYWORD_SET(SAMPLE_INTERVAL) THEN $
     SAMPLE_INTERVAL = SAMPLE_INTERVAL $
  ELSE SAMPLE_INTERVAL = 0.02

  npts = N_ELEMENTS(orig_chop)
  
; Get chop transistions for entire timestream (including padded data at end)
  choptrans = get_choptrans(orig_chop)
  if choptrans.chop_status eq 0 then return, create_struct('chop_status', 0)
  
  n_rise = N_ELEMENTS(choptrans.rise)
  n_fall = N_ELEMENTS(choptrans.fall)

; Now that we have the transitions, we need to strip off the tail
; end of the data (which is padded w/ constant) and reprocess chop
; to get symmetric transitions
; NOTE: Data merged after SEPT 06 may not have padding at the end, and this
; step may be unnecessary, but we'll keep it for now.
  IF choptrans.rise[n_rise-1] GT choptrans.fall[n_fall-1] THEN $
     trimmed_chop = DOUBLE(orig_chop[0:choptrans.rise[n_rise-1]]) $
  ELSE trimmed_chop = DOUBLE(orig_chop[0:choptrans.fall[n_fall-1]])
  
  chopzeros = get_choptrans(trimmed_chop, /EST_ZEROS)
  if chopzeros.chop_status eq 0 then return, create_struct('chop_status', 0)
  n_rise = N_ELEMENTS(chopzeros.rise)
  n_fall = N_ELEMENTS(chopzeros.fall)

; Now measure the chop period
  ave_del_rise = rm_outlier(compute_deltas(chopzeros.rise),0.6,risemask,$
                            quiet=quiet)
  ave_del_fall = rm_outlier(compute_deltas(chopzeros.fall),0.6,fallmask,$
                            quiet=quiet)
  chop_period = (ave_del_rise + ave_del_fall)/2.0
 
; Use trimmed_chop to clean up orig_chop
  chopmean = MEAN(trimmed_chop)
  chopamp = MAX(ABS(trimmed_chop-chopmean))
  cleaned_chop = DOUBLE(orig_chop)
  cleaned_chop -= chopmean
  cleaned_chop /= chopamp

; Get chopper psd and measure 1, 3 & 5 Hz peak heights
  ntrim = N_E(trimmed_chop)
;  ntrim = ROUND(chop_period*FLOOR(ntrim/chop_period)) ; get int # of periods
  ntrim = 16*FLOOR(ntrim/16)    ; This ensures that the fft will calculate more
                                ; quickly than using an integer number of
                                ; periods, which isn't totally necessary since
                                ; psd.pro applies a window function.
  chop_psd = psd(DOUBLE(orig_chop[0:ntrim-1]),SAMP = SAMPLE_INTERVAL)
  !P.MULTI = [0,1,3]
  amp1 = get_psd_peakheight(chop_psd,1.D/(chop_period*SAMPLE_INTERVAL),$
                            FITWIDTH = 15)
  amp3 = get_psd_peakheight(chop_psd,3.D/(chop_period*SAMPLE_INTERVAL),$
                            FITWIDTH = 15)
  amp5 = get_psd_peakheight(chop_psd,5.D/(chop_period*SAMPLE_INTERVAL),$
                            FITWIDTH = 15)
  !P.MULTI = 0

; Create mask for artificial chopper signal that masks out chopper slips
  chop_mask = make_chopmask(chopzeros, chop_period, npts, quiet=quiet)

; Create the phase variable that adjusts after each bad section
  chop_phase = make_chopphase(chop_mask, chopzeros, chop_period, npts)

; Make dataflags an optional argument.  If not present, print message.
  IF N_PARAMS() EQ 2 THEN BEGIN
     dataflags = apply1dmask(chop_mask, dataflags)
  ENDIF ELSE BEGIN
     IF ~QUIET THEN MESSAGE, /INFO, 'No dataflags argument given, ' + $
              'chopmask saved in chop_struct but not applied.'
  ENDELSE

  chop_struct = CREATE_STRUCT($
                'sin',SIN((DOUBLE(HARMONIC)+1.)*chop_phase)*chop_mask,$
                'cos',COS((DOUBLE(HARMONIC)+1.)*chop_phase)*chop_mask,$
                'sin1',SIN(1.D*chop_phase)*chop_mask,$
                'cos1',COS(1.D*chop_phase)*chop_mask,$
                'sin3',SIN(3.D*chop_phase)*chop_mask,$
                'cos3',COS(3.D*chop_phase)*chop_mask,$
                'sin5',SIN(5.D*chop_phase)*chop_mask,$
                'cos5',COS(5.D*chop_phase)*chop_mask,$
                'psd',chop_psd,$
                'amp3',DOUBLE(amp3)/DOUBLE(amp1),$
                'amp5',DOUBLE(amp5)/DOUBLE(amp1),$
                'phase',chop_phase*chop_mask,$
                'mask',chop_mask,$
                'period',chop_period,$
                'clean',cleaned_chop,$
                               'chop_status', 1)

  RETURN, chop_struct
END
