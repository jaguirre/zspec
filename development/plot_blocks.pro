pro plot_blocks, xl, xr, yb, yt, fullheight=fullheight, col = col

npts = n_e(xl)

if keyword_set(fullheight) then begin
    if !y.type eq 1 then ycrange=10.^!y.crange else ycrange=!y.crange
    yb = replicate(ycrange[0],npts)
    yt = replicate(ycrange[1],npts)
endif

if ~keyword_set(col) then col = 200

top = yt
bottom = yb
left = xl
right = xr

;stop

for i = 0,npts-1 do begin
   polyfill,[left[i],right[i],right[i],left[i]],$
            [top[i],top[i],bottom[i],bottom[i]],col=col,noclip=0
endfor

end
