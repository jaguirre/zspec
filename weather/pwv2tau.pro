function pwv2tau, pwv, apex = apex

; Conversion of PWV to tau_225, based on Chapman, Naylor, & Phillips,
; MNRAS 354 621
;m = 20.
;b = -0.32

; Fitting using the two data points in the fts_tau_dry and fts_tau_2mm
; data files
if (keyword_set(apex)) then begin
    pwv2fit = [0.5,1.0,1.5,2.0,3.0,4.0]
    tau2fit = [0.0302,0.0501,0.0705,0.0914,0.1345,0.1795]
    a = linfit(tau2fit,pwv2fit)
    m = a[1]
    b = a[0]
endif else begin
    m = 21.0664
    b = -0.236328
endelse
; Fitting based on Pardo atmosphere model relation
;m = 21.4
;b = -0.29

tau = (pwv - b)/m

return, tau

end
