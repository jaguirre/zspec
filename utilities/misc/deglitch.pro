; This deglitcher finds glitches in two steps: first, points whose 
; derivative is larger than step are elimininated, then points 
; which are more than sigma times the standard deviation away from 
; the mean are excluded.  The mean and standard deviation are 
; computed over all of glitchy_data.  The function returns a vector 
; of the same length as glitchy_data that has been interpolated 
; where glitches were found, unless NO_INTERPOLATE is set. After 
; execution, goodmask is a vector with length equal to glitchy_data 
; where the points are either 1 or 0 to identify good or bad 
; points, respectively.  Keyword QUIET suppresses output messages.
;
; EDITS: 2006 08 26 BN added goodmask, NO_INTERPOLATE, QUIET & 
;                       inital comment.

function deglitch, glitchy_data, goodmask, step = step, $
                   stop = stop, sigma = sigma, $
                   NO_INTERPOLATE = NO_INTERPOLATE, $
                   QUIET = QUIET

; step is maximum allowed step between successive time samples
if (keyword_set(step)) then step = step else step = 0.1
if (keyword_set(sigma)) then sigma = sigma else sigma = 3.

data = glitchy_data
goodmask = FLTARR(N_E(glitchy_data)) + 1.0 ; All points are ok at start

; Use the derivative as a first diagnostic
ddata = data[1:*]-data[0:n_e(data)-2]
ddata = [ddata[0],ddata]

whgood = where(abs(ddata) lt step)

if (whgood[0] eq -1) then begin
    message,/info,'No good data points remaining after cut'
    message,/info,'Returning original data'
    goodmask -= 1.0 ; Mark all points as bad
    return,glitchy_data
endif else begin
; Then cut on stddev
    mn = mean(data[whgood])
    sd = stddev(data[whgood])
    
; Make the cut
    if (sd ne 0.) then $
      whgood = where(abs(ddata) lt step and abs((data-mn)/sd) lt sigma)
    
    if (whgood[0] eq -1) then begin
        message,/info,'No good data points remaining after cut'
        message,/info,'Returning original data'
        goodmask -= 1.0 ; Mark all points as bad
        return,glitchy_data
    endif else begin

; Interpolate around the glitchy points if requested
       IF ~(KEYWORD_SET(NO_INTERPOLATE)) THEN BEGIN
          t = lindgen(n_e(glitchy_data))
          slightly_better_data = interpol(glitchy_data[whgood],t[whgood],t)
       ENDIF ELSE BEGIN
          slightly_better_data = glitchy_data
       ENDELSE 
    
        if (keyword_set(stop)) then stop 
    
        IF ~(KEYWORD_SET(QUIET)) THEN BEGIN
           message,/info,'Cut '+ $
                   STRING(n_e(glitchy_data)-n_e(whgood),F='(I0)') + $
                   ' of ' + STRING(n_e(glitchy_data),F='(I0)') + ' points'
        ENDIF
       goodmask -= 1.0         
        goodmask[whgood] += 1.0 ; Mark good points as good
        return, slightly_better_data

    endelse

endelse

end
