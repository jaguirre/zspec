
nbolos=160
npt=5
nco=54
ico=0
nu=fltarr(nbolos)
bolos=fltarr(nbolos)
snu=fltarr(nbolos,npt)
serr=fltarr(nbolos,npt)
thetab=fltarr(nbolos)
xoff=fltarr(npt)
yoff=fltarr(npt)

for i=0,nbolos-1 do begin
    nu[i]=309.625-0.75*(159-i)
    thetab[i]=37.4*nu[0]/nu[i]
endfor

xoff=[0.,15.,0.,-15.,0.]
yoff=[0.,0.,15.,0.,-15.]
;xoff=[7.5,22.5,7.5,-7.5,7.5]
;yoff=[10.,10.,25.,10.,-5.]

read, 'S_o (310 GHz)? ',s0_310
read, 'Noise level (rms)? ',rms
ans=''
read, 'Add CO 2-1 line? ',ans
if (ans eq 'yes' or ans eq 'Yes' or ans eq 'y') then begin
    read, 'Line flux? ',sco
    ico=1
endif

; central position
noise=randomn(seed,160)*rms
for i=0,nbolos-1 do begin
    bolos[i]=i
    snu[i,0]=s0_310*(nu[i]/nu[159])^2+noise[i]
    serr[i,0]=SQRT((0.1*snu[i,0])^2+noise[i]^2)
    if (i eq nco and ico eq 1) then snu[i,0]=snu[i,0]+sco
endfor

;offset positions. Source flux is constant for fixed nu (all offsets
;are symmetric), but noise is different

for n=1,npt-1 do begin
    noise=randomn(seed,160)*rms
    rsq=xoff[n]^2+yoff[n]^2
    for i=0,nbolos-1 do begin
        beamfac=EXP(-2.77259*rsq/thetab[i]^2)
        if (ico eq 1 and i eq nco) then begin
            snu[i,n]=beamfac*(s0_310*(nu[i]/nu[159])^2+sco)+noise[i]
            serr[i,n]=SQRT((0.1*snu[0,n])^2+noise[i]^2)
        endif else begin
            snu[i,n]=beamfac*s0_310*(nu[i]/nu[159])^2+noise[i]
            serr[i,n]=SQRT((0.1*snu[0,n])^2+noise[i]^2)
        endelse
    endfor
endfor

for n=0,npt-1 do begin
    arg1=n+1
    if (arg1 lt 10) then begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i1)')
    endif else begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i2)')
    endelse

    filename='fakefive.dat'+str1
    openw,1,filename
    for i=0,nbolos-1 do begin
    printf,1,i,nu[i],snu[i,n],SQRT((0.1*snu[0,n])^2+noise[i]^2)
;    printf,1,i,nu[i],snu[i,n],SQRT((0.1*snu[i,n])^2+noise[i]^2)
    endfor
    close,1
endfor

n_nods=npt
save,filename='20050525_001_uranus.sav',nbolos,n_nods,bolos,snu,serr,nu,nco,$
  xoff,yoff


set_plot,'x'


end
