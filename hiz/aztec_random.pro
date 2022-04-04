;This just calls the IDL RANDOMU program, but enforces the generic 
; aztec seed at all times.  By always using this program, you won't 
; (i don't think) run the risk of accidentally ending up 
; with the same "random" numbers after successive calls to your
; program, which can happen when playing with the fire that is 
; the IDL generic seed (specifically if you define your own seed FROM
; the IDL generic seed and re-use it... big no-no).    

;You can use this program to get normal, uniform, or poisson deviated 
; random numbers.  Other RANDOMU keywords are possible as well. 
; Except at this time only one input dimension is accepted.

;The big difference is that you don't send a seed.

;See description of RANDOMU for details of other keywords

;DEFAULT BEHAVIOUR IS TO RETURN A UNIFORM DISTRIBUTION

;10/09/07 - JA - Created
;------------------------------------------------------------------------

FUNCTION aztec_random, d1, $
                       binomial=binomial, $
                       double=double, $
                       gamma=gamma, $
                       normal=normal, $
                       poisson=poisson, $
                       uniform=uniform, $
                       long=long

common aztec_random_number_seed, aztec_random_number_seed

;make sure user proper defined seed in their startup
;if they didn't, define seed
if not keyword_set(aztec_random_number_seed) then $
   aztec_random_number_seed=systime(/seconds)/!dpi

;see if it's just a scalar
if not keyword_set(d1) then d1 = 1
;return scalar if just want scalar, not array of 1
if d1 eq 1 then begin
   d1 = 1
   temp = randomu(aztec_random_number_seed, $
                  d1, $
                  binomial=binomial, $
                  double=double, $
                  gamma=gamma, $
                  normal=normal, $
                  poisson=poisson, $
                  uniform=uniform, $
                  long=long)
   return, temp[0]
endif else begin
   return, randomu(aztec_random_number_seed, $
                   d1, $
                   binomial=binomial, $
                   double=double, $
                   gamma=gamma, $
                   normal=normal, $
                   poisson=poisson, $
                   uniform=uniform, $
                   long=long)
endelse



end

                       
