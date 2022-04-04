
nu=fltarr(160)
snu=fltarr(160)
for i=0,159 do begin
    nu[i]=309.625-0.75*(159-i)
endfor

read, 'S_o (310 GHz)? ',s0_310
read, 'Noise level (rms)? ',rms
read,'Number of spectra? ',nspec

set_plot,'x'

for n=0,nspec-1 do begin
    arg1=n+1
    if (arg1 lt 10) then begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i1)')
    endif else begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i2)')
    endelse

    noise=randomn(seed,160)*rms
    for i=0,159 do begin
        snu[i]=s0_310*(nu[i]/nu[0])^2+noise[i]
    endfor

    plot,snu,/xst
    wait,1.0

    filename='fakespec.dat'+str1
    openw,1,filename
    for i=0,159 do begin
    printf,1,i,nu[i],snu[i],SQRT((0.1*snu[i])^2+noise[i]^2)
    endfor
    close,1
endfor

end
