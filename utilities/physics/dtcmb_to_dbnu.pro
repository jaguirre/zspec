function dtcmb_to_dbnu, nu, tcmb
;+
; NAME:
;       dtcmb_to_dbnu
;
; PURPOSE: 
;       Converts from CMB temperature fluctuations to surface
;       brightness fluctuation; i.e., from uK_CMB to mJy
;
; CALLING SEQUENCE: 
;       result = dtcmb_to_dbnu(nu, tcmb) 
;
; INPUT PARAMETERS: 
;       nu: frequencies at which to calculate conversion
;       tcmb: temperature for which to calculate conversion
;
; OUTPUTS:
;       conversion factor: given a dtcmb, one has
;          dbnu = dtcmb_to_dbnu * dtcmb
;          all quantities in SI units
;
; MODIFICATION HISTORY:
;       2005/03/13
;-

common PHYS_COMMON

result = 0D

if (n_params() lt 2) then begin
   message, 'Requires two arguments.'
   return, result
endif

if (n_elements(tcmb) gt 1) then begin
   message, 'tcmb argument must be a scalar.'
   return, result
endif

k = 1.38e-23;   J/K

; for a 1K dtcmb, calculate dpnu
; just use dpnu_to_dtcmb since that already has the necessary
; derivative of the Planck function
dpnu = 1. / dpnu_to_dtcmb(nu, tcmb)

; convert to dbnu using throughput theorem
result = dpnu / (phys_comstr.c / nu)^2.

return, result

end
