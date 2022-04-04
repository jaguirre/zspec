pro master_fts, filename, velocity, wlf_dist
; Input parameters:
; Filename     -FTS scan to be analyzed- with directory
; Velocity     -Velocity of mirror motion in cm/s

; Declaration of useful values
c=2.998e10          ; Speed of light in cm/s
chan_ind=[0,1,2,3,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,25,26,27,28,30,32,33,34,35,36,37,39,40,$
41,42,43,44,45,46,47,48,52,53,54,57,59,60,61,62,63,64,65,66,67,68,69,70,72,74,75,76,77,78,80,81,82,84,$
86,87,88,89,90,96,97,98,99,100,101,102,104,105,106,107,108,109,110,111,112,113,116,118,119,120,121,123,$
124,125,126,127,128,130,131,132,133,134,135,136,137,138,139,140,141,142,145,146,147,150,151,155,157,158,$
159,160,161,162,164,166,167,168,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,$
188,189,190,191] ; list of all usable channels


; Call truncate.pro to truncate time streams
truncate, filename, nyquist=nyquist, trunc=trunc, sec_trunc=sec_trunc, $
              mirror_position=mirror_position, sample_rate=sample_rate

if not keyword_set(velocity) then velocity=1    ; centimeters/s
if not keyword_set(wlf_dist) then wlf_dist=157  ; distance from start of scan to white light fringe in cm

; Declare variables
mean_fit=dblarr(8,24,1)				; Polynomial to be subtracted of degree 0
mean_sub=dblarr(8,24,n_elements(sec_trunc))	; Mean subtracted interferograms
betterind=dblarr(192,15699)			; Mean subtracted interferograms with more
						; reasonable indexing
fwhmstore=fltarr(151)				; Array for storing fwhm values from each chan
peakstore=fltarr(151)				; Array for storing peak heights --- 
pkindstore=intarr(151)				; Array for storing index value of each peak
nupkstore=fltarr(151)				; Array for storing frequency value of each peak
intstore=fltarr(151,29801)			; Array for storing phase corrected interferograms
specstore=fltarr(151,29801)			; Array for storing spectra
ind_right=fltarr(151)				; Array for storing point which is closest to fwhm on right
ind_left=fltarr(151)				; Array for storing point which is closest to fwhm on left
wlf=sample_rate*(wlf_dist/velocity)		; Estimate for location of wlf
hann=hanning(2*wlf+1,/double) 			; Array of cosine hanning window
nu=shift((findgen(2*wlf+1)-wlf)*nyquist/wlf,wlf-1)
tau = findgen(100)/100*2*.0105 - 0.0105
sin = fltarr(100)
cos = fltarr(100)

; Mean subtract interferograms
for i=0,7 do begin
   for j=0,23 do begin
       mean_fit[i,j,*]=poly_fit(sec_trunc,trunc[i,j,*],0)
       mean_sub[i,j,*]=trunc[i,j,*]-(mean_fit[i,j,0])
	betterind[i*24+j,*]=mean_sub[i,j,*]
   endfor
endfor

for i=0,150 do begin
    print,i
    x=max(betterind[i,14901:14999],ind)
       wlf=ind+14901-1
       wlfs[i,0]=wlf
       sym_rev = reverse(betterind[i,wlf-700:wlf+700],2)
       shtestrev = (shift(sym_rev,-700))
       ftshtest = fft(shtestrev)
       for k=0,99 do sin[k] = $
        stddev(imaginary(ftshtest*exp(dcomplex(0,-2.*!pi*f*tau[k]))))
       for k=0,99 do cos[k] = $
          stddev(float(ftshtest*exp(dcomplex(0,-2.*!pi*f*tau[k]))))
       cosind[i,0]=where(cos eq max(cos))
       sinind[i,0]=where(sin eq min(sin))
       biggun=dblarr(2*wlf+1)
       biggun[0:n_elements(mean_sub[1,1,*])-1]=reform(betterind[i,*])
       bigrev=reverse(biggun)
       bigshft=shift(bigrev,wlf+1)
       nuf = fft_f(95.1,n_elements(bigshft))
       ahh=shift(fft(fft(bigshft)*exp(dcomplex(0,-2.*!pi*nuf*tau[cosind[i,0]]))),-1)
       newint=fltarr(2*wlf+1)
       newint[0:wlf]=ahh[wlf:*]
       newint[wlf+1:2*wlf]=reverse(ahh[wlf:2*wlf-1])
       intstore[i,*]=newint[wlf-14900:wlf+14900]
       spec=abs(fft(shift(intstore[i,*]*hann,14901)))
       specstore[i,*]=spec
       if (total(spec) ne 0) then begin
          peak = float(max(spec[2000:8000], index_pk))
          index_pk=index_pk+2000
          nu_peak = nu[index_pk]
          peakstore[i]=peak	
          pkindstore[i]=index_pk
          nupkstore[i]=nu_peak
          index_left = index_pk
          index_right = index_pk
          keepgoing = 1
          while keepgoing do begin
             index_left = index_left-1
             if (index_left eq -1) then begin
                keepgoing = 0
       endif else begin
         if (spec[index_left] lt 0.5*peak) then keepgoing = 0
       endelse
       endwhile
       keepgoing = 1
       while keepgoing do begin
       index_right = index_right+1
       if (index_right eq n_elements(nu)) then begin
         keepgoing = 0
       endif else begin
         if (spec[index_right] lt 0.5*peak) then keepgoing = 0
       endelse
       endwhile
       if (index_left ge 0 and index_right le n_elements(nu)-1) then begin
           fwhm = nu[index_right] - nu[index_left]
       endif
       fwhmstore[i]=fwhm
       endif
       ind_right[i]=index_right
       ind_left[i]=index_left
endfor

; bestguess is an array of values to feed the gaussfit function to improve the Gaussian fit.  3 element
; array to match number of free variables in gaussfit.

pkheights=make_array(144,/float,value=1)
bestguess=fltarr(144,3)

for i=0,143 do begin
    bestguess[i,0]=pkheights[i]
    bestguess[i,1]=nupkstore[i]
    bestguess[i,2]=fwhmstore[i]
endfor

xfine=shift((findgen(100000)-50000)*nyquist/50000,50000)
ynewfit=fltarr(143,n_elements(nu))
ai=fltarr(143,3)
fwhm_gauss=fltarr(143)

for i=0,142 do begin
   yfit=gaussfit(nu,specstore[i,*]/peakstore[i],a,nterms=3,estimates=bestguess[i,*])
   ai[i,*]=a
   ynewfit[i,*]=yfit
   fwhm_gauss[i]=2*SQRT(2*ALOG(2))*ai[i,2]
endfor

end
