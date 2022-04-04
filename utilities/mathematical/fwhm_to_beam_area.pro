function fwhm_to_beam_area, fwhm
;+ 
; NAME:
;        fwhm_to_beam_area
;
; PURPOSE:
;        Converts from beam FWHM to beam area, assuming a Gaussian beam.
;
; CALLING SEQUENCE:
;        result = fwhm_to_beam_area(fwhm)
;
; INPUTS:
;        none
;
; OUTPUTS:
;       result = 2 pi (fwhm / 2 sqrt( 2 ln 2))^2
;
; REVISION HISTORY
;        2004/08/14 SG
;-

result = 2 * !DPI * (fwhm / sigma_to_fwhm())^2.

return, result

end
