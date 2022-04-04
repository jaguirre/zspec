function airy, l_over_D, theta, theta_0
;+ 
; NAME
;        airy
; PURPOSE
;        Airy function -- PSF due to diffraction by a circular aperture
; USAGE
;        airy, l_over_D, theta
; INPUTS
;        l_over_D - lambda/D, the ratio of the wavelength to the aperture
;                   diameter
;        theta - angles at which Airy function is desired, in radians
;        theta_0 - angle of center of airy function
;                  (optional, theta_0 = 0 is assumed)
; OUTPUTS
;        Airy function = [ J1(pi * D/lambda * theta) / theta ],
;                        normalized to peak at 1
;        This gives the electric field -- you must square to get the
;        intensity.
; REVISION HISTORY
;        2000/09/17 SG
;-

if n_params() lt 3 then begin
   theta_0 = 0.0D
endif

theta = double(theta)
theta_0 = double(theta_0)
theta_new = theta - theta_0

y = beselj(sin(theta_new) * !PI / l_over_D,1) / (sin(theta_new))
y = y/(0.5 * !PI / l_over_D);  because J1 asymptotes to x/2 as x -> 0


if total(theta_new eq 0.0) gt 0 then begin
   index = where(theta_new eq 0.0)
   y[index] = 1.0
endif

return, y

end



