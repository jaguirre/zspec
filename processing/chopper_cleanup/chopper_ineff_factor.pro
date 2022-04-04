;created by LE 2008-04-16
;
;This function returns (as a function of observation date & number)
;a scaling factor to multiply the demodulated amplitude (volts) by in
;order to refer all observations back to April 07 conditions.
;
;This is a dummy function for now.  It returns 1.25 if the chopper is
;faster than 1.3 Hz and returns 1 otherwise.
;
;It needs to be updated to compute the correct factor for each
;observation (because we vary the secondary parameters with weather).

function chopper_ineff_factor,freq

if freq le 1.3 then chop_fac=1. else chop_fac=1.25

return,chop_fac

end
