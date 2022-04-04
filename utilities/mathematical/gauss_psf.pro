function gauss_psf, l_over_D, theta, theta_0
;+ 
; NAME
;        gauss_psf
; PURPOSE
;        Gaussian approximation to Airy function
; USAGE
;        gauss_psf, l_over_D, theta
; INPUTS
;        l_over_D - lambda/D, the ratio of the wavelength to the aperture
;                   diameter
;        theta - angles at which Airy function is desired, in radians
;        theta_0 - angle of center of airy function
;                  (optional, theta_0 = 0 is assumed)
; OUTPUTS
;        The approximation we make is to use a gaussian whose FWHM is
;        1.22 lambda/D and which is properly normalized.
;        Unlike the Airy function, this gives the power, not the electric
;        field!
; REVISION HISTORY
;        2000/09/27 SG
;-

if n_params() lt 3 then begin
   theta_0 = 0.0D
endif

theta = double(theta)
theta_0 = double(theta_0)
theta_new = theta - theta_0

sigma = 1.22 * l_over_D / 2.355

; don't normalize
;norm = ( 2.0 * !PI * sigma^2 )^(-1.0)
;y = gauss_funct_func(theta_new, [norm, 0.0, sigma])

y = gauss_funct_func(theta_new, [1.0, 0.0, sigma])

y = y[0,*]

return, y

end



