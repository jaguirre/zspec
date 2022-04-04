; This function takes the original chopper (orig_chop) encoder time stream
; and creates in-phase sine & cosine waves of the same period.  It returns
; a chopper structure with the following elements:
;       sin = pure tone wave in phase with chopper with mask applied
;       cos = pure tone wave out of phase with chopper with mask applied
;       phase = phase angle of chopper with mask applied
;       mask = a masked out region where chopper problems occur
;              each masked out region is n chop cycles long (n = integer)
;       period = period of chopper
; It also applies the chopper mask to the given dataflags argument.  
; If HARMONIC is set to an integer n > 0 then the sine and cosine waves are
; the n-th harmonic.  If it is set to zero or not set, then the waves are
; at the fundamental.  Only sin & cos are effected by the HARMONIC keyword,
; not phase or period which are always based on the fundamental.
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

FUNCTION make_artichop, orig_chop, dataflags, HARMONIC = HARMONIC

  IF KEYWORD_SET(HARMONIC) THEN HARMONIC = HARMONIC ELSE HARMONIC = 0

  npts = N_ELEMENTS(orig_chop)
  
; Get chop transistions for entire timestream (including padded data at end)
  choptrans = get_choptrans(orig_chop)
  n_rise = N_ELEMENTS(choptrans.rise)
  n_fall = N_ELEMENTS(choptrans.fall)

; Now that we have the transitions, we need to strip off the tail
; end of the data (which is padded w/ constant) and reprocess chop
; to get symmetric transitions
; NOTE: Data merged after SEPT 06 may not have padding at the end, and this
; step may be unnecessary, but we'll keep it for now.
  IF choptrans.rise[n_rise-1] GT choptrans.fall[n_fall-1] THEN $
     trimed_chop = DOUBLE(orig_chop[0:choptrans.rise[n_rise-1]]) $
  ELSE trimed_chop = DOUBLE(orig_chop[0:choptrans.fall[n_fall-1]])
  
  chopzeros = get_choptrans(trimed_chop, /EST_ZEROS)
  n_rise = N_ELEMENTS(chopzeros.rise)
  n_fall = N_ELEMENTS(chopzeros.fall)

; Now measure the chop period
  ave_del_rise = rm_outlier(compute_deltas(chopzeros.rise),0.6,risemask)
  ave_del_fall = rm_outlier(compute_deltas(chopzeros.fall),0.6,fallmask)
  chop_period = (ave_del_rise + ave_del_fall)/2.0

; Create mask for artificial chopper signal that masks out chopper slips
  chop_mask = make_chopmask(chopzeros, chop_period, npts)

; Create the phase variable that adjusts after each bad section
  chop_phase = make_chopphase(chop_mask, chopzeros, chop_period, npts)

  sinchop = SIN((DOUBLE(HARMONIC)+1.)*chop_phase)
  coschop = COS((DOUBLE(HARMONIC)+1.)*chop_phase)

  dataflags = apply1dmask(chop_mask, dataflags)

  chop_struct = CREATE_STRUCT('sin',sinchop*chop_mask,$
                              'cos',coschop*chop_mask,$
                              'phase',chop_phase*chop_mask,$
                              'mask',chop_mask,$
                              'period',chop_period)

  RETURN, chop_struct
END
