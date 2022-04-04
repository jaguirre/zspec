function dpnu_to_dtcmb, nu, tcmb
;+
; NAME:
;       dpnu_to_dtcmb
;
; PURPOSE: 
;       Converts from power spectral density fluctuations to CMB temperature 
;       fluctuations at 100% throughput; i.e., from aW/Hz to uK_cmb.
;       NOTE: If your throughput deviates from lambda^2, you must
;       multiply by the throughput fraction as a function of
;       frequency; i.e., multiply by (throughput(nu))/lambda^2.
;
; CALLING SEQUENCE: 
;       result = dpnu_to_dtcmb(nu, tcmb) 
;
; INPUT PARAMETERS: 
;       nu: frequencies at which to calculate conversion
;       tcmb: CMB temperature for which to calculate conversion
;
; OUTPUTS:
;       conversion factor: given a dpnu, one has
;          dtcmb = dpnu_to_dtcmb * dpnu
;
; MODIFICATION HISTORY:
;       2001/08/10 SG 
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

h = 6.626e-34;  J s
c = 2.998e8;   m/s
k = 1.38e-23;   J/K

; algebra:
; CMB: Pnu
;      = lambda^2 * ( 2 k T / lambda^2 ) * ( h nu / k T) 
;                   / ( e^(h nu / k T) - 1) )
;      = 2 k T (h nu / k T) / ( e^(h nu / k T) - 1)
;      -> 2 k T in RJ limit
; then, calculate dPnu for a given dTCMB
; CMB: dPnu/dTCMB 
;         = 2 k (h nu / k T)^2 e^(h nu / k T) / [ e^(h nu / k T) - 1]^2
;         -> 2 k in RJ limit
; So then
; dTCMB/dPnu
;           = (2 k)^(-1) 
;             (k T / h nu)^2 e^(- h nu / k T) [ e^(h nu / k T) - 1]^2
;           -> (2 k)^(-1) in RH lilmit

x = (h*nu)/(k*tcmb)
result =  (2 * k)^(-1) * x^(-2) * exp(-x) * (exp(x) - 1)^2

return, result

end
