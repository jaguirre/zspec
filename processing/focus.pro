pro focus, filename

;filename=''
;read,'Name of data file? ',filename

restore,filename

outfile=change_suffix(filename,'_focus.ps')

; get focus offsets from rpc_params (from .sav file)
f_off = get_focus_offset(rpc_params)
IF f_off.npoints NE N_E(nod_struct) THEN BEGIN
   MESSAGE, /INFO, 'Number of nods and number of focus offsets are not equal'
   MESSAGE, /INFO, 'Are you sure you want to proceed?'
ENDIF
focus_offset = f_off.focusoff

; Just use good bolos
whgood = where(bolo_flags eq 1)
nbolos = n_e(whgood)
bolos = bolos[whgood]
snu = snu[whgood,*]
serr = serr[whgood,*]

sum_err_sq=fltarr(nbolos)
snu_ave=fltarr(nbolos)

tvlct,[0,255,0,0],[0,0,255,0],[0,0,0,255]
set_plot,'x'

print,'Do you want to: '
print,'   Use all bolometers (0) '
print,'   Co-add bolometers (1)? '
print,'   Co-add all bolometers (2)? '
print,'   Use only 230 GHz bolometer (3) '
read,iopt

if (iopt eq 1) then begin
    read,'Number of bolometers to co-add? ',nsum
    nbin=floor(nbolos/nsum)
    if (nbolos mod nsum ne 0) then nbin=nbin+1
    snu_bin=fltarr(nbin,n_nods)
    serr_bin=fltarr(nbin,n_nods)
    nu_bin=fltarr(nbin)
    for n=0,n_nods-1 do begin
        for k=0,nbin-1 do begin
            if(k ne nbin-1) then begin
                temp1=snu[k*nsum:(k+1)*nsum-1,n]
                temp2=serr[k*nsum:(k+1)*nsum-1,n]
                nel=nsum
            endif else begin
                temp1=snu[k*nsum:*,n]
                temp2=serr[k*nsum:*,n]
                nel=n_elements(temp1)
            endelse
            sum_err_sq=total(temp2^(-2)) ;/nel
            for i=0,nel-1 do begin
                snu_bin[k,n]=temp1[i]/temp2[i]^2+snu_bin[k,n]
;                snu_bin[k,n]=temp1[i]+snu_bin[k,n]
            endfor
            snu_bin[k,n]=snu_bin[k,n]/sum_err_sq
            serr_bin[k,n]=sqrt(total(temp2^2))/nel
;            snu_bin[k,n]=snu_bin[k,n]/nel
        endfor
    endfor
    for k=0,nbin-1 do begin
        if(k ne nbin-1) then begin
            temp3=nu[k*nsum:(k+1)*nsum-1]
            nel=nsum
        endif else begin
            temp3=nu[k*nsum:*]
            nel=n_elements(temp1)
        endelse
        for i=0,nel-1 do begin
            nu_bin[k]=temp3[i]+nu_bin[k]
        endfor
        nu_bin[k]=nu_bin[k]/nel
    endfor
endif else if (iopt eq 2) then begin
    snu_bin=fltarr(1,n_nods)
    serr_bin=fltarr(1,n_nods)
    for n=0,n_nods-1 do begin
        snu_bin[0,n]=TOTAL(snu[*,n])/nbolos
        serr_bin[0,n]=sqrt(TOTAL(serr[*,n]^2))/nbolos
    endfor
endif else if (iopt eq 3) then begin
    snu_bin=fltarr(1,n_nods)
    serr_bin=fltarr(1,n_nods)
    for n=0,n_nods-1 do begin
        snu_bin[0,n]=snu[nco,n]
        serr_bin[0,n]=serr[nco,n]
    endfor
endif else begin
    snu_bin=snu
    serr_bin=serr
    nbin=nbolos
endelse

if (iopt eq 1) then begin
    smax=1.1*max(snu_bin)
    smin=min(snu_bin)
    window,0
    plot,focus_offset,snu_bin[0,*],/xst,yrange=[smin,smax],/yst,/nodata,$
      xtitle='Focus setting',ytitle='Signal'
    oplot,focus_offset,snu_bin[0,*],color=1
;    errplot,focus_offset,snu_bin[0,*]-serr_bin[0,*],snu_bin[0,*]+serr_bin[0,*],$
;      color=1
    for n=1,nbin-1 do begin
        if(n ne nbin-1) then begin
            oplot,focus_offset,snu_bin[n,*]
;            errplot,focus_offset,snu_bin[n,*]-serr_bin[n,*],$
;              snu_bin[n,*]+serr_bin[n,*]
        endif else begin
            oplot,focus_offset,snu_bin[n,*],color=2
;            errplot,focus_offset,snu_bin[n,*]-serr_bin[n,*],$
;              snu_bin[n,*]+serr_bin[n,*],color=2
        endelse
    endfor
    strlab1='!7m!D!6eff!N = '+STRING(STRCOMPRESS(nu_bin[0],/remove_all))
    strlab2='!7m!D!6eff!N = '+STRING(STRCOMPRESS(nu_bin[nbin-1],/remove_all))
    xyouts,1.1*min(focus_offset),0.9*smax,strlab1,charsize=1.5,color=1
    xyouts,1.1*min(focus_offset),0.85*smax,strlab2,charsize=1.5,color=2

    print,'Hardcopy is ',outfile
    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/encapsulated,/color
    device,filename=outfile,font_size=18
    plot,focus_offset,snu_bin[0,*],/xst,yrange=[smin,smax],/yst,/nodata,$
      xtitle='Focus setting',ytitle='Signal',charthick=2.0
    oplot,focus_offset,snu_bin[0,*],color=1,thick=3.0
;    errplot,focus_offset,snu_bin[0,*]-serr_bin[0,*],snu_bin[0,*]+serr_bin[0,*],$
;      color=1,thick=3.0
    for n=1,nbin-1 do begin
        if(n ne nbin-1) then begin
            oplot,focus_offset,snu_bin[n,*],thick=3.0
;            errplot,focus_offset,snu_bin[n,*]-serr_bin[n,*],$
;              snu_bin[n,*]+serr_bin[n,*],thick=3.0
        endif else begin
            oplot,focus_offset,snu_bin[n,*],color=2,thick=3.0
;            errplot,focus_offset,snu_bin[n,*]-serr_bin[n,*],$
;              snu_bin[n,*]+serr_bin[n,*],color=2,thick=3.0
        endelse
    endfor
    xyouts,1.1*min(focus_offset),0.9*smax,strlab1,charsize=1.5,charthick=2.0,$
      color=1
    xyouts,1.1*min(focus_offset),0.85*smax,strlab2,charsize=1.5,charthick=2.0,$
      color=2
    device,/close
    set_plot,'x'

endif

if (iopt eq 2 or iopt eq 3) then begin
    
    window,1
    plot,focus_offset,snu_bin,/xst,xtitle='Focus setting',ytitle='Signal'
;    errplot,focus_offset,snu_bin-serr_bin,snu_bin+serr_bin
    print,'Hardcopy is ',outfile

    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/color
    device,filename=outfile,font_size=18
    plot,focus_offset,snu_bin,/xst,xtitle='Focus setting',ytitle='Signal',$
      charthick=2.0,thick=3.0
;    errplot,focus_offset,snu_bin-serr_bin,snu_bin+serr_bin,thick=3.0
    device,/close
    set_plot,'x'

endif else if (iopt eq 0) then begin

    ans=''
    read,'Do you want to look at all bolometers? ',ans
;    ans=STRING(ans)
    if (ans eq 'yes' or ans eq 'Yes' or ans eq 'y') then begin
        iplot=1
        window,1
        for n=0,nbolos-1 do begin
            if (iplot ne 0) then begin
                smax=1.1*max(snu_bin[n,*])
                smin=min(snu_bin[n,*])
                plot,focus_offset,snu_bin[n,*],/xst,yrange=[smin,smax],/yst,$
                  xtitle='Focus setting',ytitle='Signal'
;                errplot,focus_offset,snu_bin[n,*]-serr_bin[n,*],$
;                  snu_bin[n,*]+serr_bin[n,*]
                strlab='!7m!6 = '+STRING(STRCOMPRESS(nu[n],/remove_all))
                xyouts,1.1*min(focus_offset),0.9*smax,strlab,charsize=1.5
                read,'Hit 1 to go to next bolometer, 0 for no more plots ',iplot
            endif
        endfor
    endif else begin
        read,'Number of bolometers to plot? ',nplot
        n_bolo_plot=intarr(nplot)
        print,'Bolometer numbers? '
        read,n_bolo_plot
        iplot=1
        giro=''
        set_plot,'x'
        window,1
        for n=0,nplot-1 do begin
            nb=n_bolo_plot[n]
            smax=1.1*max(snu_bin[nb,*])
            smin=min(snu_bin[nb,*])
            plot,focus_offset,snu_bin[nb,*],/xst,yrange=[smin,smax],/yst,$
              xtitle='Focus setting',ytitle='Signal',charthick=1.5,thick=2.0
;            errplot,focus_offset,snu_bin[nb,*]-serr_bin[nb,*],$
;              snu_bin[nb,*]+serr_bin[nb,*],thick=2.0
            strlab='!7m!6 = '+STRING(STRCOMPRESS(nu[nb],/remove_all))
            xyouts,1.1*min(focus_offset),0.9*smax,strlab,charsize=1.5
            read, 'Hit return to go to next bolometer',giro
        endfor

        outfile=STRING('focus_'+name+'_bolonumber.ps')
        print,'Hardcopies are ', outfile
        set_plot,'ps'
        device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
          /color
;        device,filename='focus.ps',font_size=18
        for n=0,nplot-1 do begin
            nb=n_bolo_plot[n]
            file='focus_'+name+'_'+STRING(STRCOMPRESS(nb,/remove_all))+'.ps'
            device,filename=file,font_size=18
            smax=1.1*max(snu_bin[nb,*])
            smin=min(snu_bin[nb,*])
            plot,focus_offset,snu_bin[nb,*],/xst,yrange=[smin,smax],/yst,$
              xtitle='Focus setting',ytitle='Signal',charthick=2.0,thick=3.0
;            errplot,focus_offset,snu_bin[nb,*]-serr_bin[nb,*],$
;              snu_bin[nb,*]+serr_bin[nb,*],thick=2.0
            strlab='!7m!6 = '+STRING(STRCOMPRESS(nu[nb],/remove_all))
            xyouts,1.1*min(focus_offset),0.9*smax,strlab,charsize=1.5,charthick=2.0
        device,/close
        endfor
        set_plot,'x'
    endelse
endif

end
