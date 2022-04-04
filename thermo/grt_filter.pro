; Kind of kooky way to filter the GRT data, but it seems to be able to
; deal with glitches and with the oscillation in a way that looks
; reasonable, at least.
; for the APEX data this is not so great, It was just hacked so it doesn't crash...

function grt_filter, grt,apex=apex

ntod = n_e(grt)
if keyword_set(apex) then len=100L else len = 1000L
;if apex then begin
;mm=min(grt)
;wf=where(

;endif

nchunks = ntod/len
rem = ntod mod len

rises = 0
falls = 0

for i=0L,nchunks-1 do begin

    indx = lindgen(len)+i*len

    trans = get_choptrans(grt[indx])
    typetrans=size(trans,/tname)
    
 if typetrans eq 'STRUCT' then begin   
    rises = [rises,trans.rise+i*len]
    falls = [falls,trans.fall+i*len]
    endif 
endfor

; Deal with the last section
if (rem gt 0) then begin

    indx = lindgen(rem)+nchunks*len
    trans = get_choptrans(grt[indx])
    typetrans=size(trans,/tname)
    
    if typetrans eq 'STRUCT' then begin
    rises = [rises,trans.rise+i*len]
    falls = [falls,trans.fall+i*len]
    endif
    
    if n_e(rises) gt 1 then begin
    rises = rises[1:*]
    falls = falls[1:*]
    endif

endif

filt_grt = grt
nknots = max([1,n_e(rises)-2])
knots = fltarr(nknots)
knot_vals = fltarr(nknots)

if nknots eq 1 then begin 
knot_vals[0] = mean(filt_grt)
    knots[0] = n_e(grt)/2.
    filt_grt(*) = knot_vals[0]
endif else begin
for i=0L,nknots-1 do begin
    knot_vals[i] = mean(filt_grt[rises[i]:rises[i+1]])
    knots[i] = (rises[i] + rises[i+1])/2.
    filt_grt[rises[i]:rises[i+1]] = knot_vals[i]
endfor
endelse
; The ordinary deglitchers we're using seem to really struggle with
; the GRT data though.  Try a simpler approach ...
;;;whgood = where(fin_diff(knot_vals) lt 1d-4)
;;;
;;;filt_grt_interp = $
;;;  interpol(knot_vals[whgood],knots[whgood],findgen(ntod),/spline)
;;;

if n_e(knot_vals) lt 8 then $
  to_interp = dblarr(n_e(knot_vals)) + mean(knot_vals) $
else $
  to_interp = median(knot_vals,7)

if n_e(knots) eq 1 then filt_grt_interp = replicate(to_interp,ntod) else filt_grt_interp = interpol(to_interp,knots,findgen(ntod))

return,filt_grt_interp

end
