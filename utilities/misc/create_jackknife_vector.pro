; Returns n/2 1's and n/2 -1's, randomly arranged, in an n-element
; vector.  This is useful for creating jackknife maps in which one
; half of the data is multiplied by -1.  Obviously, to get an equal
; number of each value, n must be even.  nshuffles=n*1000 is overly
; conservative; the rule-of-thumb for shuffling cards is that 7 riffle
; shuffles (n*7/2 swaps) produces a sufficiently randomized deck.
; However, for reasonably small n, the run-time is still insignificant.
function create_jackknife_vector, n

common random_seed, seed

;seed=systime(/seconds)
nshuffles=n*1000L

; n=1 is a degenerate case, but we'll allow it for debugging/robustness purposes
if(n eq 1) then return,[1.]

jackknife_vector=[replicate(1.,FLOOR(n/2)),replicate(-1.,n-FLOOR(n/2))]
for i=1L,nshuffles do begin
    rnd_i=fix(randomu(seed)*n) & jk_i=jackknife_vector[rnd_i]
    rnd_j=fix(randomu(seed)*n) & jk_j=jackknife_vector[rnd_j]
    
    jackknife_vector[rnd_i]=jk_j
    jackknife_vector[rnd_j]=jk_i
endfor

return,jackknife_vector
end
