function sztherm_bnu, nu, tcmb, y
;+
; NAME:
;       sztherm_bnu
; PURPOSE: 
;       Calculates the thermal SZ brightness function in units of 
;          W/m^2/ster/Hz (i.e., B_nu).  Multiply by A Omega to get a 
;          power spectral density [W/Hz].
;       Note of course that the function is linear in y!
;
; CALLING SEQUENCE: 
;       result = sztherm_bnu(nu, tcmb, y) 
;
; INPUT PARAMETERS: 
;       nu: frequencies at which to calculate planck function
;       tcmb: CMB temperature
;
; OPTIONAL PARAMETERS:
;       y: Compton y-parameter.  If not provided, taken to be 1.
;
; OUTPUTS:
;       Thermal SZ brightness function in units of W/m^2/ster/Hz at the 
;       specified frequencies.
;
; MODIFICATION HISTORY:
;       2002/08/10 SG Copied from planck_bnu.
;-

result = 0D

if (n_params() lt 3) then begin
   y = 1.
endif

if (n_params() lt 2) then begin
   message, 'Requires at least two arguments.'
   return, result
endif

if (n_elements(tcmb) gt 1) then begin
   message, 'tcmb argument must be a scalar.'
   return, result
endif

h = 6.626e-34;  J s
c = 2.998e8;   m/s
k = 1.38e-23;   J/K

x = (h * nu)/(k * tcmb)

result = y * (2 * k * tcmb) * (nu/c)^2 $
         * x^2 * exp(x) * (exp(x) - 1)^(-2) $
         * ( x * (exp(x) + 1) * (exp(x) - 1)^(-1) - 4 )

return, result

end
