
nbolo=160
nobs=10
bolo=intarr(nbolo)
nu=fltarr(nbolo)
snu=fltarr(nbolo,nobs)
serr=fltarr(nbolo,nobs)
sum_err_sq=fltarr(nbolo)
snu_ave=fltarr(nbolo)

for n=0,nobs-1 do begin
    arg1=n+1
    if (arg1 lt 10) then begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i1)')
    endif else begin
        str1=STRING(STRCOMPRESS(arg1,/remove_all),format='(i2)')
    endelse

    filename='fakespec.dat'+str1
    readcol,filename,format='(i,f,f,f)',bolo,nu,temp1,temp2
    snu[*,n]=temp1
    serr[*,n]=temp2
endfor

sum_err_sq=total(serr^(-2),2)

for n=0,nbolo-1 do begin
    for k=0,nobs-1 do begin
        snu_ave[n]=snu[n,k]/serr[n,k]^2+snu_ave[n]
    endfor
    snu_ave[n]=snu_ave[n]/sum_err_sq[n]
endfor

set_plot,'x'
window,0
plot,snu_ave,/xst,xtitle='Bolometer',ytitle='Signal'

end
