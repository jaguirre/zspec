function  fft_padsize, n
;+ given minimal size of array, find array slightly larger that can be
; factored in 2 and 3
; Useful for FFT convolution. Greatly speeds things up.
; A.G., 2002-05-12, suffering from the lack of oxygen at Mauna Kea summit. 
;-
n2 = long(ceil(alog(n)/alog(2)))
n3 = long(ceil(alog(n)/alog(3)))

arr = long(2^findgen(n2))#long(3^findgen(n3)) ;powers of 2 and 3
arr = reform(arr, n_elements(arr))
ind = sort(arr)
arr= arr(ind)
ind =  where(arr ge n)
return, arr(ind(0))
end
