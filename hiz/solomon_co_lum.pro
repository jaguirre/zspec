; Takes the correlation between L_FIR and L'_CO from Solomon & van den
; Bout 2005 and spit out some predictions.

pro solomon_co_lum, l_fir, lp_co, z, dv, nu_obs, s_co, l_co, lumdist = lumdist

forward_function lumdist

; l_fir is in solar luminosities
; lp_co is in K km/s pc^2
; dv is in km/s
; s_co is in Jy
; nu in GHz
; luminosity distance in Mpc
lp_co = 10.d^((alog10(l_fir)+5.0)/1.7)

if (keyword_set(lumdist)) then ld = lumdist else ld = lumdist(z,/silent)

; This is equation 3 in Solomon & Vanden Bout 2005
s_co = lp_co / 3.25d7 / dv * nu_obs^2 / ld^2 * (1+z)^3 

l_co = 1.04e-3 * s_co * dv * nu_obs * ld^2

end
