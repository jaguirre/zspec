function freq2freqid, freq

; Finds the nearest channel to a given frequency.  Input frequency
; assumed in GHz.

nfreq = n_e(freq)
whfreq = lonarr(nfreq)

nu = freqid2freq()

for i = 0,nfreq - 1 do begin

    whfreq[i] = find_nearest(nu,freq[i])

endfor

return,whfreq

end
