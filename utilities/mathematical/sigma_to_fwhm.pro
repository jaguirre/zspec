function sigma_to_fwhm
;+ 
; NAME:
;        sigma_to_fwhm
;
; PURPOSE:
;        Conversion factor from sigma to fwhm; i.e. returns 
;        2. * sqrt(2. * alog(2.))
;
; CALLING SEQUENCE:
;        result = sigma_to_fwhm()
;
; INPUTS:
;        none
;
; OUTPUTS:
;       result = 2 * sqrt(2. * alog(2.))
;
; REVISION HISTORY
;        2003/11/12 SG
;-

result = 2. * sqrt(2. * alog(2.))

return, result

end
