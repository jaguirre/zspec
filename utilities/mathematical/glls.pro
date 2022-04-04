pro glls, y, dm, sig_y = sig_y, $
          a = a, sig_a = sig_a, yfit = yfit, resid = resid, $
          covar = cov, chisq = chisq , corr = corr, $
          w = w, invw = invw, u = u, v = v, tol = tol

;------------------------------------------------------------------------------
;+
; NAME: glls.pro
;
; PURPOSE: A general linear least squares fitting algorithm.
;
; CALLING SEQUENCE: 
;
; ROUTINES NEEDED: DIAG.PRO
;
; INPUTS:  y:      The vector of data points to be fitted, length n.  
;          sig_y:  A vector of standard deviations for y.
;          dm:     The "design matrix" of the fit.  dm is assumed to be
;                  arranged such that the second index indexes the
;                  number of functions m, and the first indexes the n
;                  values of that function, i.e., 
;                     help, dm 
;                  yields 
;                     dm FLOAT = Array[n,m]  
;                  This is convenient so that a design matrix can be
;                  made from the statement 
;                    dm = [[mf1],[mf2], ... [mfn]]
;          
; OUTPUTS: a:      The best fit coefficients.
;          sig_a:  The errors on the fit coefficients.
;          yfit:   The best fit model, computed by multiplying the
;                  fitted coefficients times the design matrix.
;          resid:  y - yfit
;          covar:  the covariance matrix of the fitted parameters
;          corr:   the correlation matrix of the fitted parameters
;          u, v, w, invw: the bits of the SVD decomposition of the
;          matrix inversion problem
;          tol:    the tolerance to use in the SVD
;
; NOTES:
;
;
; MODIFICATION HISTORY: Created by JA 2001/06/05
;
;------------------------------------------------------------------------------

m = n_elements(dm[0,*])
n = n_elements(dm[*,0])

; If no errors are supplied, assume uniform weighting.
if (keyword_set(sig_y) eq 0) then sig_y = replicate(1.d,n)

; Apply the weighting.
y_nw = y / sig_y
dm_nw = dm
for i = 0, m-1 do begin
    dm_nw[*,i] = dm[*,i] / sig_y
endfor	

; Evaluate the SVD of the noise weighted design matrix.
svdc, transpose(dm_nw), w, u, v, /double, itmax = 60

; The w values come out ranked in order of size, so they don't
; trivially correspond to the columns of the design matrix.  However,
; as long as the covariance is computed using v, as below, the
; permutation of columns seems to take care of itself.

; Edit values of 1/w to preclude small pivots
   if (keyword_set(tol)) then tol = tol else tol = 1.e-6
   invw = dblarr(m)
; Compute a mimimum acceptable w
   wmin = max(w)*tol
   accept_w = where(w gt wmin)
; Set the invw vector to be 1/w everwhere that w is large enough.
; Other values are set to 0.
   invw[accept_w] = 1./w[accept_w]
; Warn the user if some weights are set to zero.  
   if (n_elements(accept_w) ne n_elements(w)) then $
     message,/info,'SVD has detected singular values.'

; Compute the solution to the least squares problem
a = reform(v ## ((u # y_nw)*invw))

; Compute the covariance
cov = v ## diag(invw^2) ## transpose(v)

; Compute the sigmas.
i = lindgen(m)
sig_a = reform(sqrt(cov[i,i]))

; Compute the correlation
corr = cov / (sig_a # sig_a)

; Compute the fitted model and the residuals
yfit = a ## dm 
resid = y - yfit

; Compute the chi squared per degree of freedom (dof is n-m).
chisq = total((resid / sig_y)^2)/(n-m)

end
