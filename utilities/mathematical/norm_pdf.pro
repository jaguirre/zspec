function norm_pdf, x
;+ 
; NAME
;        norm_pdf
;
; PURPOSE
;        Calculates variance = 1 normal distribution PDF at x.
;        Integral of PDF is 1.
;
; USAGE
;        result = norm_pdf(x)
;
; INPUTS
;        x = value at which to evaluate function
;
; OUTPUTS
;       result = (2 pi)^(-1/2) * exp( - x^2 / 2 ) 
;
; REVISION HISTORY
;        2002/10/22 SG
;-

result = (2 * !DPI)^(-0.5) * exp( -x^(2D) / 2D)

return, result

end
