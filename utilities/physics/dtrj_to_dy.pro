function dtrj_to_dy, nu, tcmb
;+
; NAME:
;       dtrj_to_dy
;
; PURPOSE: 
;       Converts from RJ temperature fluctuations to Compton y
;       fluctuations; i.e., from uK_RJ to y
;
; CALLING SEQUENCE: 
;       result = dtrj_to_dy(nu, tcmb) 
;
; INPUT PARAMETERS: 
;       nu: frequencies at which to calculate conversion
;       tcmb: CMB temperature
;
; OUTPUTS:
;       conversion factor: given a dtrj, one has
;          dy = dtrj_to_dy * dtrj
;
; MODIFICATION HISTORY:
;       2002/07/27 SG 
;       2002/08/10 SG Rewrite using sztherm_bnu
;-

result = 0D

if (n_params() lt 2) then begin
   message, 'Requires two arguments.'
   return, result
endif

if (n_elements(tcmb) gt 1) then begin
   message, 'tcmb argument must be a scalar.'
   return, result
endif

c = 2.998e8;   m/s
k = 1.38e-23;   J/K

; intuitive way to see it: go through a power density fluctuation
; at 100% throughput.  
; RJ: dPnu/dTRJ = 2 k
; y: dPnu/dy
;      = Pnu/y because SZ brightness function is linear in y
;      = lambda^2 * sztherm_bnu(nu, tcmb, 1)
; So then
; dy/dTRJ = (dPnu/dTRJ)/(dPnu/dy)
;         = 2 k y / Pnu
;         = 2 k / (lambda^2 sztherm_bnu(nu, tcmb, 1)
; NOTE: could also have done this in terms of brightness fluctuation
; dBnu so that througput never enters.  But that would give the same
; result; one would have gotten dBnu/dTRJ = 2 k / lambda^2 and
; dBnu/dy = sztherm_bnu(nu,tcmb,1)

lambda = c / nu
result =  2 * k * lambda^(-2) / sztherm_bnu(nu, tcmb, 1.)

return, result

end
