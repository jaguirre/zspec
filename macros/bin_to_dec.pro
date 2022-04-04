; Bits (from left to right)
; 1: Obs number
; 2-4: obs type, no type 0
; 5: nodding

bin = [1, 0, 1, 0, 1, 0, 0, 0]

dec = 0
for i=7,0,-1 do begin

    dec = dec + bin[7-i]*2^i

endfor

print, dec

end
