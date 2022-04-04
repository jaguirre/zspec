; Returns a structure with four tags: 
; .npoints - number of pointings found
; .points - indicies for the starts of each pointing found
; .azoff - a vector of azimuth offsets 
; .eloff - a vector of elevation offsets

FUNCTION get_pointings, rpc_params
  ;; If there is a transition within ENDGAP samples (~ seconds)
  ;; of either the begining or end, the inital or final az & el values
  ;; are not included in the returned structure.
  ENDGAP = 8   

  ;; If there are transitions in both az & el within MIDGAP of each
  ;; other, then that is counted as one change in pointing with the
  ;; starting index of that pointing being the later of the two transisition
  MIDGAP = 2

  npts = N_ELEMENTS(rpc_params.azimuth_offset)

  az_trans = find_transitions(rpc_params.azimuth_offset)
  az_sort = SORT([az_trans.rise,az_trans.fall])
  az_usort = UNIQ([az_trans.rise,az_trans.fall], az_sort)
  az_trans = ([az_trans.rise,az_trans.fall])[az_usort]
  az_trans = [az_trans,npts]

  el_trans = find_transitions(rpc_params.elevation_offset)
  el_sort = SORT([el_trans.rise,el_trans.fall])
  el_usort = UNIQ([el_trans.rise,el_trans.fall], el_sort)
  el_trans = ([el_trans.rise,el_trans.fall])[el_usort]
  el_trans = [el_trans,npts]

  points = REPLICATE(-1L,N_E(az_trans) + N_E(el_trans) + 1)
  curraz = 0
  currel = 0

; deal with the first pointing
  CASE 1 OF
     az_trans[curraz] LE ENDGAP AND el_trans[currel] LE ENDGAP : BEGIN
        points[0] = MAX([az_trans[curraz],el_trans[currel]]) 
        curraz += 1
        currel += 1
     END
     az_trans[curraz] LE ENDGAP : BEGIN
        points[0] = az_trans[curraz] 
        curraz += 1
     END
     el_trans[currel] LE ENDGAP : BEGIN
        points[0] = el_trans[currel] 
        currel += 1
     END
     ELSE: points[0] = 0
  ENDCASE

; Deal with intermediate pointings
  FOR i = 1, N_E(points) - 1 DO BEGIN
     IF curraz GE N_E(az_trans)-1 AND currel GE N_E(el_trans)-1 THEN BREAK
     CASE 1 OF
        ABS(az_trans[curraz] - el_trans[currel]) LE MIDGAP : BEGIN
           points[i] = MAX([az_trans[curraz],el_trans[currel]]) 
           curraz += 1
           currel += 1
        END
        az_trans[curraz] LT el_trans[currel] - MIDGAP : BEGIN
           points[i] = az_trans[curraz]
           curraz += 1
        END
        el_trans[currel] LT az_trans[curraz] - MIDGAP : BEGIN
           points[i] = el_trans[currel]
           currel += 1
        END
        ELSE: MESSAGE, 'Something strange has happenend.  Stopping'
     ENDCASE
  ENDFOR
 
; Trim points array and check if end pointing is too close to end
  wh = WHERE(points NE -1,npoints)
  points = points[wh]

  WHILE points[npoints-1] GE npts - ENDGAP DO BEGIN
     points = points[0:npoints-2]
     npoints -= 1
  ENDWHILE

  RETURN, CREATE_STRUCT('npoints',npoints,$
                        'points',points,$
                        'azoff', rpc_params.azimuth_offset[points],$
                        'eloff', rpc_params.elevation_offset[points])
END
