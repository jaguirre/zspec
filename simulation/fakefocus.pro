
nbolos=160
nfoc=10
nco=54
bolos=fltarr(nbolos)
nu=fltarr(nbolos)
snu=fltarr(nbolos,nfoc)
serr=fltarr(nbolos,nfoc)
thetab=fltarr(nbolos)
foc_val=fltarr(nfoc)
ico=0
ans=''
for i=0,nbolos-1 do begin
    nu[i]=309.625-0.75*(159-i)
    thetab[i]=37.4*nu[0]/nu[i]
endfor

foc_val=[0.14,0.16,0.18,0.20,0.22,0.24,0.26,0.28,0.30,0.32]

read, 'S_o (310 GHz)? ',s0_310
read, 'Noise level (rms)? ',rms
read, 'Add CO 2-1 line? ',ans
if (ans eq 'yes' or ans eq 'Yes' or ans eq 'y') then begin
    read, 'Line flux? ',sco
    ico=1
endif

; perfect focus (foc_val=0.25)
noise=randomn(seed,160)*rms
for i=0,nbolos-1 do begin
    bolos[i]=i
    snu[i,0]=s0_310*(nu[i]/nu[159])^2+noise[i]
    serr[i,0]=SQRT((0.1*snu[i,0])^2+noise[i]^2)
    if (i eq nco and ico eq 1) then snu[i,0]=snu[i,0]+sco
endfor

;offset positions. Source flux is reduced by assumed parabolic focus term

for n=0,nfoc-1 do begin
    focus=0.005/(0.005+(0.25-foc_val[n])^2)
    print,focus
    noise=randomn(seed,160)*rms
    for i=0,nbolos-1 do begin
        serr[i,n]=SQRT((0.1*snu[i,0])^2+noise[i]^2)
        if (ico eq 1 and i eq 54) then begin
            snu[i,n]=focus*(s0_310*(nu[i]/nu[159])^2+sco)+noise[i]
        endif else begin
            snu[i,n]=focus*s0_310*(nu[i]/nu[159])^2+noise[i]
        endelse
    endfor
endfor

for n=0,nfoc-1 do begin
    arg1=n+1
    if (arg1 lt 10) then begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i1)')
    endif else begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i2)')
    endelse

    filename='fakefocus.dat'+str1
    openw,1,filename
    for i=0,nbolos-1 do begin
    printf,1,i,nu[i],snu[i,n],SQRT((0.1*snu[i,n])^2+noise[i]^2)
    endfor
    close,1
endfor

n_nods=nfoc
save,filename='20050525_003_uranus.sav',nbolos,n_nods,bolos,snu,serr,nu,nco,$
  foc_val

set_plot,'x'


end
