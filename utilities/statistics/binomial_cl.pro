function $
   binomial_cl, $
      n, f, cl

; $Id: 
; $Log: 
;
;+
; NAME:
;	binomial_cl
;
; PURPOSE:
;	Calculate the desired confidence interval for a binomial
;       distribution with the specified parameters based on the
;       Neyman construction.
;
; CALLING SEQUENCE:
;	Write the calling sequence here. Include only positional parameters
;	(i.e., NO KEYWORDS). For procedures, use the form:
;
;       interval = binomial_cl(n, f, cl)
;
; INPUTS:
;	n: number of trials; e.g., number of coin flips
;       f: probability of a positive occurence; e.g., expected
;          fraction of the time the coin comes up heads, 0.5
;       cl: confidence level of interval desired.  CL = 90% will
;           cause the interval returned to be such that 90% of 
;           outcomes will fall in the interval
;       Inputs must all be scalars.
;
; OUTPUTS:
;	Returns the desired interval.  Due to discretization, the
;       interval may overcover the desired confidence level; i.e.,
;       the interval may encompass more than a fraction cl of
;       outcomes.  The interval will always err toward overcoverage.
;
; MODIFICATION HISTORY:
; 	2005/01/25 SG
;-


x = dindgen(n+1L)
c = fltarr(n+1L)
p = fltarr(n+1L)

; calculate the binomial distribution for the given n and f
for k = 0, n do c[k] = binomial(x[k], n, f)
p = c - shift(c, -1) 
p[n] = c[n]

; sort the x values by their probability
index = reverse(sort(p))
cumsum = total(p[index], /cum)

result = fltarr(n_elements(cl), 2)

; keep adding elements to the interval until we meet coverage cl
for k = 0, n_elements(cl)-1 do begin
   index_this = where(cumsum lt cl[k])
   index_this = [index_this, max(index_this) + 1L]
   x_this = index(index_this)
   result[k,*] = minmax(x_this)
endfor

return, result

end
