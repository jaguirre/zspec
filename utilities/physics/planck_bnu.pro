function planck_bnu, nu, T
;+
; NAME:
;       planck_bnu
; PURPOSE: 
;       Calculates the Planck brightness function in units of W/m^2/ster/Hz.
;          (i.e., B_nu).  Multiply by A Omega to get a power spectral
;          density [W/Hz].
;
; CALLING SEQUENCE: 
;       result = planck_bnu(nu, T) 
;
; INPUT PARAMETERS: 
;       nu: frequencies at which to calculate planck function
;       T: temperature for which to calculate planck function
;
; OUTPUTS:
;       Planck function in units of W/m^2/ster/Hz at the 
;       specified frequencies.
;
; MODIFICATION HISTORY:
;       2001/04/10 SG 
;       2002/08/10 SG Renamed to planck_bnu, rewrote algebra in
;       cleaner form.
;-

result = 0D

if (n_params() lt 2) then begin
   message, 'Requires two arguments.'
   return, result
endif

if (n_elements(T) gt 1) then begin
   message, 'T argument must be a scalar.'
   return, result
endif

h = 6.626e-34;  J s
c = 2.998e8;   m/s
k = 1.38e-23;   J/K

x = (h * nu)/(k * T)

result = (2 * k * T) * (nu/c)^2 * x * (exp(x) - 1)^(-1)

return, result

end
