function dtrj_to_dtcmb, nu, tcmb
;+
; NAME:
;       dtrj_to_dtcmb
;
; PURPOSE: 
;       Converts from RJ temperature fluctuations to CMB temperature 
;       fluctuations; i.e., from uK_RJ to uK_CMB.
;
; CALLING SEQUENCE: 
;       result = dtrj_to_dtcmb(nu, tcmb) 
;
; INPUT PARAMETERS: 
;       nu: frequencies at which to calculate conversion
;       tcmb: temperature for which to calculate conversion
;
; OUTPUTS:
;       conversion factor: given a dtrj, one has
;          dtcmb = dtrj_to_dtcmb * dtrj
;          check: expect dtcmb > dtrj because to get a given power
;             fluctuation, you always need a bigger CMB fluctuation
;             than a RJ fluctuation
;
; MODIFICATION HISTORY:
;       2001/06/26 SG 
;       2002/08/10 SG Rewrite using dpnu_to_dtcmb
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

k = 1.38e-23;   J/K

; intuitive way to see it: go through a power density fluctuation
; at 100% throughput.  
; RJ: dPnu/dTRJ = 2 k
; CMB: dPnu/dTCMB = (dpnu_to_dtcmb(nu,TCMB))^-1
; dTCMB/dTRJ = (dPnu/dTRJ)/(dPnu/dTCMB)
;            = 2 k dpnu_to_dtcmb(nu, TCMB)
; NOTE: could have done this in terms of a brightness fluctuation dBnu
; so that it was not necessary to use 100% throughput.  The lambda^2
; all cancel out, so it doesn't matter which way you do it.
; I like to think of Pnu as more fundamental than Bnu since 
; Pnu = 2 k T in RJ limit but Bnu = 2 k T / lambda^2.

result = 2 * k * dpnu_to_dtcmb(nu, tcmb)

return, result

end
