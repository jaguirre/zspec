function conv_hp, sig,dt,Tconst
;+
; NAME:
;    convolve_highpass
;
; PURPOSE:
;    convolves input signal with Bolocam highpass filter
; A.G. 2002-05-12
;-

dt = (size(dt,/tname) EQ 'UNDEFINED') ? 0.02 : float(dt)
;Tconst = 10.0                   ; 10 seconds one pole filter for now
Tconst = (size(Tconst,/tname) EQ 'UNDEFINED') ? 10.0 : float(Tconst)
rate = 1.0/dt
npts = n_elements(sig)
npad = long(ceil(5*Tconst*rate)) ;5 tau later....
nsize = fft_padsize(npad+npts)
npad = nsize - npts

sig1 = [complex(sig),replicate(complex(0.0),npad)]

freq = fft_mkfreq(dt,npts+npad)
;x = !pi*freq*dt
;x(0)=1e-3                       ; no division by 0
freq(0)=freq(1)*1e-3
pt = complex(0, 2*!pi*freq* Tconst)

TF = (pt/(1.0+pt));* sin(x)/x
sf = fft(tf*fft(sig1),/inverse)
return, float(sf(0:npts-1))
end
