;; This function creates a vector with n/2 +1 and n/2 -1 (if n is odd and
;; greater than 1, there will also be one 0), randomly ordered via a
;; Knuth shuffling algorithm.  If n = 1, then half the time it returns
;; [+1], and half the time it will return [-1].  It executes about 1000
;; times faster than create_jackknife_vector and applies a more properly
;; concieved shuffling method.
FUNCTION create_jack_vec_knuth, n

  COMMON random_seed_knuth, seed
  
  nrands = 1L + 1 + 1 + n
  randnums = RANDOMU(seed,nrands,/UNIFORM,/DOUBLE)
  roff = 0L

  IF n EQ 1 THEN $
     IF randnums[roff] GT 0.5 THEN $
        RETURN, [+1.] ELSE RETURN, [-1.]
  roff += 1.
  
  jack_vec = [[REPLICATE(+1.,FLOOR(n/2.))],[REPLICATE(-1.,FLOOR(n/2.))]]
  nvec = N_ELEMENTS(jack_vec)
  IF randnums[roff] GT 0.5 THEN $
     jack_vec = (TRANSPOSE(jack_vec))[INDGEN(nvec)] $
  ELSE jack_vec = (TRANSPOSE(jack_vec))[nvec-INDGEN(nvec)-1]
  roff += 1

  IF n MOD 2 GE 1 THEN BEGIN
     zeroloc = LONG(n * randnums[roff])
     IF zeroloc EQ 0 THEN jack_vec = [0,jack_vec] $
     ELSE IF zeroloc EQ FLOOR(n-1) THEN jack_vec = [jack_vec,0] $
     ELSE jack_vec = [jack_vec[0:zeroloc-1],0,jack_vec[zeroloc:*]]
  ENDIF
  roff += 1

  FOR i = n-1,0,-1 DO BEGIN
     j = LONG((i+1) * randnums[roff])
     temp = jack_vec[i]
     jack_vec[i] = jack_vec[j]
     jack_vec[j] = temp
     roff += 1
  ENDFOR

  RETURN, jack_vec
END

