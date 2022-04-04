; quick-n-dirty deglitcher

function deglitch_quick_tc, data, nsigma=nsigma

if n_elements(nsigma) eq 0 then nsigma = 5.

result = data

; take out a poly
npts = n_elements(data)
ttemp = findgen(npts)
coeffs = poly_fit(ttemp,data,4)
bestpoly = poly(ttemp,coeffs)
data_pm = data - bestpoly

; get outlier-removed mean & sigma
meantemp = rm_outlier(data_pm,3.,goodmask,sigma,/sdev,/quiet)

; flag glitches
whgl = where(abs(data_pm - meantemp)/sigma gt nsigma,ngl,compl=whngl)

; interpolate
if ngl gt 0 then begin
    result_pm = interpol(data_pm[whngl],ttemp[whngl],ttemp)
    result = result_pm + bestpoly
endif

;stop

return, result

end
