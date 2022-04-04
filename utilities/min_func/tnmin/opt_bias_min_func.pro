function opt_bias_min_func, $
            p, $
            bolo_model = bolo_model, q = q, rl = rl, en_amp = en_amp, $
            eta = eta, nu0 = nu0, dnu = dnu, t_bath = t_bath
;+
; NAME:
;       opt_bias_min_func
;
; PURPOSE:
;       Routine to return total NEP as a function of bias current,
;       given the various parameters passed by the keywords.
;
; CALLING SEQUENCE:
;       result = $
;          opt_bias_min_func( $
;             p, $
;             bolo_model = bolo_model, q = q, rl = rl, en_amp = en_amp, $
;             eta = eta, nu0 = nu0, dnu = dnu, t_bath = t_bath)
;
; INPUTS:
;       p = array of bias current [nA].  Must be in nA (not A) otherwise 
;           minimization gets unhappy (values too small).
; 
; KEYWORD PARAMETERS:
;       all keyword params have same definitions as in calc_noise.pro,
;       including units
;
; OUTPUTS: 
;      Total NEP at bias current input [aW/rtHz].  In aW/rtHz instead
;      of W/rtHz because of above small values problem.
;
; COMMON BLOCKS:
;      BOLO_COMMON: defined in def_bolo_common.pro
;
; MODIFICATION HISTORY:
;      2002/07/24 SG
;-

common BOLO_COMMON

noise_struct = $
   calc_noise(p / BOLO_COMSTR.iscale, $
              bolo_model, q, rl, en_amp, eta, nu0, dnu, t_bath)

;print, 'p, nep = ', p, noise_struct.nep.total * BOLO_COMSTR.nepscale

return, noise_struct.nep.total * BOLO_COMSTR.nepscale

end

