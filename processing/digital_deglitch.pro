function digital_deglitch, signal

sig = long(signal)
nsig = n_e(sig)

; Looks for cases cases in a digital signal, assumed to be either 0 or
; 1, in which there are transitions of only one sample, and removes
; them.

dsig = abs(fin_diff(signal))

whtrans = where(dsig eq 1)
if whtrans(0) ne -1 then begin
; The endpoints are a special case ...
if ((where(whtrans eq 0))[0] ne -1) then $
  message,/info,'WARNING: Found possible glitch at beginning of signal.'
if ((where(whtrans eq nsig-1))[0] ne -1) then $
  message,/info,'WARNING: Found possible glitch at end of signal.'

whtrans = whtrans[where(whtrans ne 0 and whtrans ne nsig-1)]

for i=0,n_e(whtrans)-1 do begin
    if ((sig[whtrans[i]-1] ne sig[whtrans[i]]) and $
        (sig[whtrans[i]+1] ne sig[whtrans[i]])) then $
      sig[whtrans[i]] = sig[whtrans[i]-1]
endfor
endif
return, sig

end
