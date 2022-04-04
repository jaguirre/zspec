function poisson_pdf, x, lambda

; Returns the Poisson probability distribution function for mean
; lambda

; The numerical implementation is stupid, so it will only work for
; small numbers for the mean.  x is not assumed to be an integer.
; Choose what you want the distribution to mean in that case.

pdf = lambda^x * exp(-lambda) / factorial(x)

return, pdf

end
