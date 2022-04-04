; Use this function on a result from find_continuous that has more
; than one section, but should only have one.
;
; The return value will be a structure with tags .i and .f.  If the
; input sections could not be fixed, then both tags will be set to -1

FUNCTION fix_sections, in_secs, MAXGAP = MAXGAP, FIRSTFALL = FIRSTFALL
  IF ~(KEYWORD_SET(MAXGAP)) THEN MAXGAP = 70
  IF ~(KEYWORD_SET(FIRSTFALL)) THEN FIRSTFALL = 25
  
  ret_secs = in_secs

  IF N_E(ret_secs) EQ 0 THEN BEGIN
     MESSAGE, /INFO, 'Zero element input section - cannot fix'
     ret_secs = ret_secs[0]
     ret_secs.i = -1
     ret_secs.f = -1
     RETURN, ret_secs
  ENDIF
 
  IF N_E(ret_secs) EQ 1 THEN BEGIN
     MESSAGE, /INFO, 'Only one element in input section - already fixed'
     RETURN, ret_secs
  ENDIF

  in_firstfall = ret_secs[0].f - ret_secs[0].i
  IF in_firstfall LE FIRSTFALL THEN BEGIN
     MESSAGE, /INFO, 'Glitch at beginning - Stripping first section' 
     ret_secs = ret_secs[1:*]
     IF N_E(ret_secs) EQ 1 THEN RETURN, ret_secs
  ENDIF

  gaps = SHIFT(ret_secs.i,-1) - ret_secs.f
  gaps = gaps[0:N_E(gaps)-2]

  IF (WHERE(gaps GT MAXGAP) NE -1) THEN BEGIN
     MESSAGE, /INFO, 'Gaps are too large to span - cannot fix'
     ret_secs = ret_secs[0]
     ret_secs.i = -1
     ret_secs.f = -1
     RETURN, ret_secs
  ENDIF ELSE BEGIN
     MESSAGE, /INFO, 'Patching all segments together'
     RETURN, CREATE_STRUCT('i',MIN(ret_secs.i),$
                           'f',MAX(ret_secs.f))
  ENDELSE

  MESSAGE, /INFO, 'This section should not be reached'
  ret_secs = ret_secs[0]
  ret_secs.i = -1
  ret_secs.f = -1
  RETURN, ret_secs
END

  
  
