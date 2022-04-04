pro rvst_func, T, A, R, PDER
;+
; NAME:
;	rvst_func
;
; PURPOSE:
;       Given R0 and Delta, calculates the NTD resistance
;
;          R0 exp(sqrt(Delta/T))
;
;       and the partial derivatives with respect to R0 and Delta.
;
; CALLING SEQUENCE:
;       rvst_func, T, A, R, PDER
;
; INPUTS:
;       T: input array of temperatures
;          MUST BE A ROW ARRAY FOR PDER OUTPUT TO MAKE SENSE!
;       A: NTD parameters
;          A[0] = R0
;          A[1] = Delta
;
; OUTPUTS:
;       R: resistance at the input temperatures
;
; OPTIONAL OUTPUTS:
;       PDER: partial derivatives with respect to R0 and Delta
;             at the input temperatures
;
; MODIFICATION HISTORY:
;       2000/11/20 SFE
;       2001/03/22 SG document it
;-

R = A[0] * exp( sqrt( A[1]/ ( eps() + T ) ) )

PDER = [[ exp(sqrt(A[1]/( eps() + T ) )) ], $
        [ A[0] * exp( sqrt( A[1]/( T + eps() ) ) ) $
               * 0.5 * 1/sqrt( eps() + A[1] * T ) ] ]

end



