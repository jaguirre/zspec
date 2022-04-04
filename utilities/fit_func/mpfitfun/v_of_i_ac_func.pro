function v_of_i_ac_func, X, A
;+
; NAME:
;       v_of_i_ac_func
;
; PURPOSE:
;       Routine to calculate the expected observed AC IV curve for
;       a given set of bolometer parameters and observed AC I values.
;       That is, we apply all the necessary AC corrections to turn
;       the DC IV curve into the IV curve we calculate from lockin DC
;       output data without having applied AC corrections.
;       NOTE THAT THE RESULT IS NOT A PHYSICAL IV CURVE -- it is the
;       iv curve that has been corrupted by AC effects.
;
; CALLING SEQUENCE:
;       result = v_of_i_ac_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the observed current values [A]
;       A = parameters of fit:
;           A[0] = Delta [K]
;           A[1] = R0 [ohms]
;           A[2] = g [pW/K^alpha]A
;           A[3] = alpha 
;           A[4] = T_bath [K]
;           A[5] = wiring capacitance [pF]
;           A[6] = Q (optional; set to zero if not included)
;
; OUTPUTS: 
;      The expected observed voltage values [V]
;
; COMMON BLOCKS:
;      BOLO_COMMON: from def_bolo_common.pro, we use rl
;
; MODIFICATION HISTORY:
;      2002/11/23 SG
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   IF N LT 7 THEN A[6] = 0
   IF N LT 6 THEN A[5] = 0
   IF N LT 5 THEN MESSAGE, 'Argument A must have 5, 6, or 7 elements.'

   common BOLO_COMMON

   start_time = systime(/seconds)

   delta = A[0]
   r0 = A[1]
   g = A[2]
   alpha = A[3]
   t_bath = A[4]
   c = A[5]
   q = A[6]

   ; use t_bolo as the free parameter; makes life easy
   n_pts = 1001
   t_red = 10^(findgen(n_pts)/(n_pts-1))
   t_bolo = t_bath * t_red

   ; calculate model
   beta   = alpha - 1
   p      = g * (t_bolo^alpha - t_bath^alpha) - q
   ; discard points with p < 0; they give NaN later
   index  = where(p ge 0)
   n_pts  = n_elements(index)
   t_red  = t_red[index]
   t_bolo = t_bolo[index]
   p      = p[index]
   r      = r0 * exp( sqrt(delta/t_bolo) )
   i      = sqrt( p / r  )
   v      = i * r

   model_time = systime(/seconds)

   ; calculate what we expect at the bias monitor
   v_biasmon_dc = v + i * BOLO_COMSTR.rl

   ; calculate ac effects
   ; it's actually a fairly computationally intensive calculation,
   ; so only do it for a subset of values and interpolate for the remainder
   coarsefac = 100
   modval = n_pts / coarsefac  ; integer division
   index = where(indgen(n_pts) mod modval eq 0)
   ; have to get the last point to bracket all data
   index = [index, n_pts-1]
   xfer = calc_carrier_xfer(r[index[0]], c)
   xfer = replicate(xfer, n_elements(index))
   for k = 0, n_elements(index)-1 do begin
      xfer[k] = calc_carrier_xfer(r[index[k]], c)
   endfor

   ac_time = systime(/seconds)

   ; interpolate to get the rest of the points
   xfer_all = replicate(xfer[0], n_pts)
   xfer_all.bolo = interpol(xfer.bolo, r[index], r)
   xfer_all.biasmon = interpol(xfer.biasmon, r[index], r)

   ; calculate the "observed" bolometer voltage
   v_bolo_dc_lockin = v * xfer_all.bolo
   ; calculate the "observed" bias monitor voltage
   v_biasmon_dc_lockin = (v * (BOLO_COMSTR.rl + r)/r) * xfer_all.biasmon
   ; calculate the "observed" bolometer current
   i_bolo_dc_lockin = (v_biasmon_dc_lockin - v_bolo_dc_lockin)/BOLO_COMSTR.rl

   ; and now interpolate the "observed" IV curve at the observed
   ; current values
   F = interpol(v_bolo_dc_lockin, i_bolo_dc_lockin, abs(X)) * sign(X)

   interpol_time = systime(/seconds)

;   print, 'time to do bolo model:', model_time - start_time
;   print, 'time to calculate AC corrections:', ac_time - model_time
;   print, 'time to interpolate on data:', interpol_time - ac_time

   RETURN, F

END


