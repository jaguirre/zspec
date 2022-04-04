; Stole Sunil's code for gauss2d_fit_func, added the
; wiener-filtering step.  This is intended to be called
; by source2dfit[_sim], which defines gauss2dfit_wf_cmn.
function gauss2d_wf_fit_func, X, A

common gauss2dfit_wf_cmn

   ON_ERROR,2                      ;Return to caller if an error occurs

   xtrans = (X[0,*] - A[4]) * cos(A[6]) - (X[1,*] - A[5]) * sin(A[6])
   ytrans = (X[0,*] - A[4]) * sin(A[6]) + (X[1,*] - A[5]) * cos(A[6])

   map = fltarr(nx,ny)
   map[X[0,*],X[1,*]] = A[0] + A[1]*exp( - 0.5 * ( (xtrans/A[2])^2 + (ytrans/A[3])^2 ) )
   wf_map = wiener_filter_map(map,wiener_filter,resolution,fwhm)

   f = reform(wf_map[X[0,*],X[1,*]])
   return, f
end
