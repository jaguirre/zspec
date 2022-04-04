function rangegen, minval, maxval, step, npoints = npoints

; General findgen, etc, to an arbitrary interval

if (not(minval le maxval)) then message,'minval must be less than maxval'

if (keyword_set(npoints)) then begin
    n = double(npoints)
    step = (maxval-minval)/n
endif else begin
    n = (maxval - minval)/step
endelse

r = dindgen(n+1)*step + minval

return, r

end
