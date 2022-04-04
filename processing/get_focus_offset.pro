; returns a structure with three tags:
; .npoints - number of focus values found
; .points - indicies for the starts of each focus setting found
; .focusoff - a vector of focus offsets

FUNCTION get_focus_offset, rpc_params
  ;; If there is a transition within ENDGAP samples (~ seconds)
  ;; of either the begining or end, the inital or final focus values
  ;; are not included in the returned structure.
  ENDGAP = 8   

  rpc_foff = rpc_params.secondary_mirror_focus_offset

  f_trans = find_transitions(rpc_foff)
  f_sort = SORT([f_trans.rise,f_trans.fall])
  f_trans = ([f_trans.rise,f_trans.fall])[f_sort]

  points = f_trans

  IF points[0] GT ENDGAP THEN points = [0,points]

  npoints = N_ELEMENTS(points)

; Check for offsets too close to the end of observation
  WHILE points[npoints-1] GE N_E(rpc_foff) - ENDGAP DO BEGIN
     points = points[0:npoints-2]
     npoints -= 1
  ENDWHILE

  RETURN, CREATE_STRUCT('npoints',npoints,$
                        'points',points,$
                        'focusoff', rpc_foff[points])
END
