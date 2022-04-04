; 11/7/06 Updated to use freqid2freq & freqid2bw functions

function mars_kkms,date

; calculates the flux of mars is Kkm/s
; returns a 160-element vector
;freq=bolo2freq(findgen(160))*0.988
;deltav=bolo2bw(findgen(160)) / freq * 2.9979e5 
freq=freqid2freq()
deltav=freqid2bw() / freq * 2.9979e5 
temp=mars_temperature(date)

return,temp*deltav
end
