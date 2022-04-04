;Gets the channel corresponding to the given frequency. 

function freq2freqid, freq, no_shift=no_shift

nu=freqid2freq(no_shift=no_shift)

for i=0, n_e(freq)-1 do begin

    diff=abs(nu-freq[i])
    w=where(diff eq min(diff))
    
    if i eq 0 then result=w[0] else result=[result, w[0]]
endfor 

return, result

end
