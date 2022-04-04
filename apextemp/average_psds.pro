function average_psds, psds, flags, median = median 

npts = n_e(psds[0,*])

avgpsd = dblarr(npts)

if ~keyword_set(median) then begin

    for i=0,160-1 do begin
    
        if (flags[i]) then begin
            avgpsd += psds[i,*]^2
        endif
        
    endfor
    avgpsd /= double(total(flags))
    avgpsd = sqrt(avgpsd)

endif else begin

    for i=0,npts-1 do begin
        avgpsd[i] = median(psds[*,i]/flags)
    endfor

endelse

return,avgpsd

end
