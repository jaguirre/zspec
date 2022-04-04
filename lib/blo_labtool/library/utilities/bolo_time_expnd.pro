;===============================================================
; Provide index array for lower frequency times
; to higher frequency time array so that always last
; value is kept until new one turns up.
; This is useful if low frequency telemetry is used
; to fill in values on high frequency telemetry but
; interpolation is to be avoided.
;
;
; t1    (double) times high frequency
; t2    (double) times low frquency
; ix    (long) pointers to t2 but same number of elements as t1
;
; Edition History
; 2004/07/16 B. Schulz  initial test version
; 2004/07/20 B. Schulz  bugfix
;
;===============================================================

pro bolo_time_expnd, t1, t2, ixout

ixout = lonarr(n_elements(t1))        ;output index array
nt2 = n_elements(t2)

t2start = min(t2)

ix = where(t1 LT t2start, cnt)      ;no data area
if cnt GT 0 then ixout[ix] = -1L   ;no valid pointer


ix1 = where(t1 GE t2start, cnt1)      ;common region
if cnt1 GT 0 then begin

  ;ixout[ix1[0]] = 0L    ;index of first element in t2 array

  it2 = 0L                      ;array counter for t2
  while t1[ix1[0]] GE t2[it2] AND it2 LT nt2-1 do it2 = it2 + 1  ;incr t2 counter
  ixout[ix1[0]] = it2-1
  ixlast = it2-1

  for it1=1L, cnt1-1 do begin

;if it2 EQ nt2-2 then stop

    if t1[ix1[it1]] LT t2[it2] then begin

      ixout[ix1[it1]] = ixlast     ;index of last element of t2

    endif else begin

      while t1[ix1[it1]] GE t2[it2] AND it2 LT nt2-1 do begin
        ixlast = it2
        it2 = it2 + 1  ;incr t2 counter
      endwhile

      if t1[ix1[it1]] GE t2[it2] AND it2 EQ nt2-1 then ixlast = nt2-1

      ixout[ix1[it1]] = ixlast

    endelse

  endfor   ;it1
endif   ;common region

return
end