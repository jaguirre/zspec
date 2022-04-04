function tau2pwv,tau
; based on Conversion of PWV to tau_225, based on Chapman, Naylor, & Phillips,
; MNRAS 354 621
;m = 20.
;b = -0.32

; Fitting using the two data points in the fts_tau_dry and fts_tau_2mm
; data files
m = 21.0664
b = -0.236328

; Fitting based on Pardo atmosphere model relation
;m = 21.4
;b = -0.29

pwv=m*tau + b

return, pwv
end
