function bpfilt, data

; Do a stupid bandpass.  I can't believe I don't have a better way of
; doing this.

;message,/info,'Hey!'

ts = reform(data)
ts = ts - mean(ts)

n = 0L
while (2L^n lt n_e(ts)) do n=n+1

; pad ts with zeroes ...
ntod = n_e(ts)
npad = 2L^n - ntod

npad1 = npad/2L
npad2 = npad - npad1

ts = [replicate(0.,npad1),ts,replicate(0.,npad2)]

ftts = fft(ts)

freq = fft_f(35.5,n_e(ts))

sigma = 0.5

low_knee = 1.0
high_knee = 3.0

filter = dblarr(n_e(freq))

filter[where(freq lt low_knee and freq ge 0.)] = $
  exp(-((freq[where(freq lt low_knee and freq ge 0)]-low_knee)/sigma)^2)
filter[where(freq gt -high_knee and freq le 0.)] = $
  exp(-((freq[where(freq gt -high_knee and freq le 0.)]+low_knee)/sigma)^2)

; Bandpass
filter[where(abs(freq) ge low_knee and abs(freq) le high_knee)] = 1.

filter[where(freq gt high_knee)] = $
  exp(-((freq[where(freq gt high_knee)]-high_knee)/sigma)^2)
filter[where(freq lt -high_knee)] = $
  exp(-((freq[where(freq lt -high_knee)]+high_knee)/sigma)^2)

filtered = fft(filter * ftts, /inverse)

filtered = (double(filtered))[npad1+1 : npad1+ntod]

filtered = filtered - mean(filtered)

return, filtered

end
