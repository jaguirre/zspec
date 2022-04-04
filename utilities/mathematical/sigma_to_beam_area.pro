function sigma_to_beam_area, sigma
;+ 
; NAME:
;        sigma_to_beam_area
;
; PURPOSE:
;        Converts from beam sigma to beam area, assuming a Gaussian beam.
;
; CALLING SEQUENCE:
;        result = sigma_to_beam_area(sigma)
;
; INPUTS:
;        none
;
; OUTPUTS:
;       result = 2 pi sigma^2.
;
; REVISION HISTORY
;        2004/08/14 SG
;-

result = 2 * !DPI * sigma^2.

return, result

end
