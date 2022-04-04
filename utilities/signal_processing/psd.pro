function psd, data, avg_len = avg_len, $
              two_sided = two_sided, sample_interval = sample_interval
;+
; NAME:
;	psd_scan
;
; PURPOSE:
;	Computes the PSD of a BOLOCAM scan.  Subtracts the mean
;       and then applies a Hanning window.
;
; CALLING SEQUENCE:
;
;       psd = psd_scan(scan, two_sided = two_sided)
;
; INPUTS:
;	scan: a time trace
;
; KEYWORD PARAMETERS:
;	two_sided: set this flag to get a 2-sided PSD
;
; OUTPUTS:
;	psd: (2 x N) matrix:
;            psd(0,*) = frequency array
;            psd(1,*) = standard power spectral density, units are
;                       (data units)/rtHz
;            if two_sided is not set, then freq goes from 0 to 
;               (N div 2)
;            if two_sided is set, then freq goes from -(N div 2) to 
;               (N div 2) - 1 if N is even and from -(N div 2) to 
;               (N div 2) if N is odd.
;
; MODIFICATION HISTORY:
; 	2000/??/?? BK
;       2002/01/01 SG Speed up by killing loop at end, clean up.
;       2004/08/23 JS added sample_interval
;-

meandata = (moment(data))[0]
newdata = data - meandata

; Number of timestream elements
N = long(n_elements(newdata))

; Deal with averaging
if (keyword_set(avg_len)) then begin
    nchunks = long (n / avg_len)
    temp = newdata[0:nchunks*avg_len-1]
    newdata = reform(temp,avg_len,nchunks)
    n = avg_len
endif else begin
    avg_len = n
    nchunks = 1
    newdata = reform(newdata,avg_len,nchunks)
endelse

;help,avg_len,nchunks

; flat window:
;h = (fltarr(n) + 1.0) # replicate(1.d,nchunks)

; hann window:
;exactly the same as idl hanning function w/ alpha=0.5
h = 0.5 * (1. - cos(2.*!DPI*(findgen(N)+1.)/N)) # replicate(1.d,nchunks)
wss=(1./N)*total(h^2)			 

absft = reform(abs(fft(h*newdata,-1,dim=1))^2,avg_len,nchunks)
 
g = 1.	
if not keyword_set(sample_interval) then $
  dt = 0.02 $
else $
  dt = sample_interval
df = 1./(dt * N)

; 2-sided version
psd = fltarr(2,N)
psd[0,*] = fft_mkfreq(dt, N)
;help,absft
psd[1,*] = sqrt(total(absft,2)) / g / sqrt( wss * df)
;sqrt(total(absft,2)/nchunks) / g / sqrt( wss * df)

if keyword_set(two_sided) then begin
   psd[0,*] = fft_shift(psd[0,*])
   psd[1,*] = fft_shift(psd[1,*])
endif else begin
   ; convert to 1-sided if so desired
   psd = psd[*,0:(N/2)]
   ; simple way to get frequencies to be right; if N is even, then
   ; the last element of psd[0,*] is -N/2, so this makes it positive 
   psd[0,*] = abs(psd[0,*])
   ; rather than adding positive and negative (which should be the same)
   ; just multiply by sqrt(2)
   psd[1,*] = sqrt(2) * psd[1,*]
endelse

psd_struct = create_struct('freq',reform(psd[0,*]), $
                           'psd', reform(psd[1,*]))

return, psd_struct

end

