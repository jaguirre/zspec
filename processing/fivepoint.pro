pro fivepoint, filename

restore,filename,/VERBOSE

; Create output filenames for PS files
outfile1=change_suffix(filename,'_5pt_positions.ps')
outfile2=change_suffix(filename,'_5pt_fwhm.ps')
outfile3=change_suffix(filename,'_5pt_spectra.ps')

bolos_plot = bolos
snu_plot = snu
for i = 0,n_e(snu[0,*])-1 do begin
    snu_plot[*,i] = snu[*,i]/reform(bolo_flags)
endfor

; Just use good bolos
whgood = where(bolo_flags eq 1)
nbolos = n_elements(whgood)
bolos = bolos[whgood]
nu = nu[whgood]
snu = snu[whgood,*]
serr = serr[whgood,*]

; Extract pointing information from the rpc_params element of the .sav file
p_info = get_pointings(rpc_params)
IF p_info.npoints NE 5 OR N_E(nod_strcut) NE 5 THEN BEGIN
   MESSAGE, /INFO, 'Number of nods or number of pointings not equal to five'
   MESSAGE, /INFO, 'Are you sure you want to process this as a fivepoint?'
ENDIF
xoff = p_info.azoff
yoff = p_info.eloff

; Determine index of central position and indices of x- and y-segments
; Center position is repeated in xvec and yvec to fool IDL gaussfit routine
icen=where(xoff eq 0. and yoff eq 0.)
x_ind=where(xoff ne 0.)
y_ind=where(yoff ne 0.)
; For a five point, x_ind and y_ind damn well ought to be the same length.  
if (n_e(x_ind) ne n_e(y_ind)) then $
  message,/info,'Determinations of x and y in fivepoint are kerflooie.'
xvec=[xoff[icen],xoff[icen],xoff[x_ind]]
yvec=[yoff[icen],yoff[icen],yoff[y_ind]]
xmax=1.2*max(xoff)
xmin=1.2*min(xoff)
ymax=1.2*max(yoff)
ymin=1.2*min(yoff)
xz=fltarr(3)
yz=fltarr(3)
smaxc=fltarr(2)
sminc=fltarr(2)
sum_err_sq=fltarr(nbolos)
snu_ave=fltarr(nbolos)

tvlct,[0,255,0,0],[0,0,255,0],[0,0,0,255]
;set_plot,'x'

;smax=1.1*max(snu[*,0])
smaxc[0]=1.2*max(snu[*,0])
smaxc[1]=1.2*max(snu[*,x_ind])
smax=max(smaxc)
sminc[0]=min(snu[*,0])
sminc[1]=min(snu[*,x_ind])
smin=min(sminc)

; Plot spectra, both in hardcopy and not
for ps = 0,1 do begin

    if(ps) then begin
        set_plot,'ps'
        device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
          language_level=2,/color,font_size=12,filename = outfile3
    endif else begin
        window,0
    endelse

; Plot X-spectra
    plot,bolos_plot,snu_plot[*,0],/xst,yrange=[smin,smax],/yst, $
      xtitle='Bolometer number',ytitle='Signal',title=name, $
      psym=10
    xyouts,0.1*nbolos,0.95*max(snu[*,icen]),'Central position',$
      charsize=2.0
    
    oplot,bolos_plot,snu_plot[*,x_ind[0]],color=2,psym=10
    xyouts,0.1*nbolos,0.85*max(snu[*,0]),'1st x off-position',$
      charsize=2.0,color=2
    
    oplot,bolos_plot,snu_plot[*,x_ind[1]],color=3,psym=10
    xyouts,0.1*nbolos,0.75*max(snu[*,0]),'2nd x off-position',$
      charsize=2.0,color=3

    if not(ps) then begin
        window,1
    endif    

; Plot Y-spectra
    plot,bolos_plot,snu_plot[*,0],/xst,yrange=[smin,smax],/yst,$
      xtitle='Bolometer number',ytitle='Signal',title=name,$
      psym=10
    xyouts,0.1*nbolos,0.95*max(snu[*,icen]),'Central position',$
      charsize=2.0
    
    oplot,bolos_plot,snu_plot[*,y_ind[0]],color=2,psym=10
    xyouts,0.1*nbolos,0.85*max(snu[*,0]),'1st y off-position',$
      charsize=2.0,color=2
    
    oplot,bolos_plot,snu_plot[*,y_ind[1]],color=3,psym=10
    xyouts,0.1*nbolos,0.75*max(snu[*,0]),'2nd y off-position',$
      charsize=2.0,color=3

    if(ps) then begin
        device,/close_file
        set_plot,'x'
    endif
    
endfor 

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
            endfor
            snu_bin[k,n]=snu_bin[k,n]/sum_err_sq
            serr_bin[k,n]=sqrt(total(temp2^2))/nel
        endfor
    endfor
endif else if (iopt eq 2) then begin
    snu_bin=fltarr(1,n_nods)
    serr_bin=fltarr(1,n_nods)
    for n=0,n_nods-1 do begin
        temp1=snu[*,n]/serr[*,n]^2
        sum_err_sq=total(serr[*,n]^(-2))
;        snu_bin[0,n]=TOTAL(snu[*,n])/nbolos
        snu_bin[0,n]=total(temp1)/sum_err_sq
;        serr_bin[0,n]=sqrt(TOTAL(serr[*,n]^2))/nbolos
        serr_bin[0,n]=1./sqrt(sum_err_sq)
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
   window,0
;   smax=1.1*max(snu_bin[*,0])
   smaxc[0]=1.1*max(snu_bin[*,0])
   smaxc[1]=1.1*max(snu_bin[*,x_ind])
   smax=max(smaxc)
   sminc[0]=min(snu_bin[*,0])
   sminc[1]=min(snu_bin[*,x_ind])
   smin=min(sminc)
   plot,bolos_plot,snu_plot_bin[*,icen],/xst,xtitle='Bin number',ytitle='Signal',$
     yrange=[smin,smax],/yst,psym=10,tit=name
   xyouts,0.1*nbin,0.95*max(snu_bin[*,0]),'Central position',charsize=2.0
;   errplot,bolos_plot,snu_plot_bin[*,0]-serr_bin[*,0],snu_bin[*,0]+serr_bin[*,0]
   oplot,bolos_plot,snu_plot_bin[*,x_ind[0]],color=2,psym=10
;   errplot,bolos_plot,snu_plot_bin[*,x_ind[0]]-serr_bin[*,x_ind[0]],$
;     snu_bin[*,x_ind[0]]+serr_bin[*,x_ind[0]],color=2
   xyouts,0.1*nbin,0.85*max(snu_bin[*,0]),'1st x off-position',$
     charsize=2.0,color=2
   oplot,bolos_plot,snu_plot_bin[*,x_ind[1]],color=3,psym=10
;   errplot,bolos_plot,snu_plot_bin[*,x_ind[0]]-serr_bin[*,x_ind[0]],$
;     snu_bin[*,x_ind[1]]+serr_bin[*,x_ind[1]],color=3
   xyouts,0.1*nbin,0.75*max(snu_bin[*,0]),'2nd x off-position',$
     charsize=2.0,color=3
   window,1
   plot,bolos_plot,snu_plot_bin[*,icen],/xst,xtitle='Bin number',ytitle='Signal',$
     title=name,psym=10
;   errplot,bolos_plot,snu_plot_bin[*,0]-serr_bin[*,0],snu_bin[*,0]+serr_bin[*,0]
   xyouts,0.1*nbin,0.95*max(snu_bin[*,0]),'Central position',charsize=2.0
   oplot,bolos_plot,snu_plot_bin[*,y_ind[0]],color=2,psym=10
;   errplot,bolos_plot,snu_plot_bin[*,y_ind[0]]-serr_bin[*,y_ind[0]],$
;     snu_bin[*,y_ind[0]]+serr_bin[*,y_ind[0]],color=2
   xyouts,0.1*nbin,0.85*max(snu_bin[*,0]),'1st y off-position',$
     charsize=2.0,color=2
   oplot,bolos_plot,snu_plot_bin[*,y_ind[1]],color=3,psym=10
;   errplot,bolos_plot,snu_plot_bin[*,y_ind[1]]-serr_bin[*,y_ind[1]],$
;     snu_bin[*,y_ind[1]]+serr_bin[*,y_ind[1]],color=3
   xyouts,0.1*nbin,0.75*max(snu_bin[*,0]),'2nd y off-position',$
     charsize=2.0,color=3
endif else if (iopt ne 0) then begin
   window,2
   plot,bolos_plot,snu_plot_bin,/xst,xtitle='Position',ytitle='Signal',psym=10
endif

if (iopt eq 2 or iopt eq 3) then begin
; vectors with signal and errors for x-direction
    svecx=[snu_bin[0,icen],snu_bin[0,icen],snu_bin[0,x_ind[0]],$
           snu_bin[0,x_ind[1]]]
    errvecx=[serr_bin[0,icen],serr_bin[0,icen],serr_bin[0,x_ind[0]],$
             serr_bin[0,x_ind[1]]]
; vectors with signal and errors for y-direction
    svecy=[snu_bin[0,icen],snu_bin[0,icen],snu_bin[0,y_ind[0]],$
           snu_bin[0,y_ind[1]]]
    errvecy=[serr_bin[0,icen],serr_bin[0,icen],serr_bin[0,y_ind[0]],$
             serr_bin[0,y_ind[1]]]

; fit Gaussian in x-direction
    gfitx=gaussfit(xvec,svecx,xpar,measure_errors=errvecx,nterms=3,sigma=sigmax)
; gfitx=gaussfit(xvec,svecx,xpar,nterms=3,sigma=sigmax)
    fwhmx=2*sqrt(2*alog(2))*xpar[2]
    print,'FWHM (x) = ',fwhmx
; fit Gaussian in y-direction
    gfity=gaussfit(yvec,svecy,ypar,measure_errors=errvecx,nterms=3,sigma=sigmay)
; gfity=gaussfit(yvec,svecy,ypar,nterms=3,sigma=sigmay)
    fwhmy=2*sqrt(2*alog(2))*ypar[2]
    print,'FWHM (y) = ',fwhmy
; x- and y-values of center of Gaussians
    print, 'Fitted center:'
    print, 'X_o = ',xpar[1]
    print,' Y_o = ',ypar[1]

; plot binned values as function of x- and y-position
    strlab0=STRING(snu_bin[0,icen])
    strlab1=STRING(snu_bin[0,x_ind[0]])
    strlab2=STRING(snu_bin[0,x_ind[1]])
    strlab3=STRING(snu_bin[0,y_ind[0]])
    strlab4=STRING(snu_bin[0,y_ind[1]])
    strlab5='FWHM(x) = '+STRING(STRCOMPRESS(fwhmx,/remove_all))
    strlab6='FWHM(y) = '+STRING(STRCOMPRESS(fwhmy,/remove_all))
    strlab7='Fitted center:'
    strlab8=STRING('('+STRCOMPRESS(xpar[1],/remove_all))+','+$
      STRING(STRCOMPRESS(ypar[1],/remove_all))+')'

    window,3
    plot,xvec[1:3],yz,xrange=[xmin,xmax],yrange=[ymin,ymax],$
      xtitle='!7D!6x',ytitle='!7D!6y',/nodata
    oplot,xpar[1:1],ypar[1:1],psym=1,color=1,symsize=6.0
;    oplot,xz,yvec[1:3]
    xyouts,xoff[icen],yoff[icen],strlab0,charsize=1.3,alignment=0.5
    xyouts,xoff[x_ind[0]],yoff[icen],strlab1,charsize=1.3,alignment=0.5,color=2
    xyouts,xoff[x_ind[1]],yoff[icen],strlab2,charsize=1.3,alignment=0.5,color=3
    xyouts,xoff[icen],yoff[y_ind[0]],strlab3,charsize=1.3,alignment=0.5,color=2
    xyouts,xoff[icen],yoff[y_ind[1]],strlab4,charsize=1.3,alignment=0.5,color=3
    xyouts,0.95*xmin,0.95*ymax,strlab5,charsize=1.2
    xyouts,0.95*xmin,0.85*ymax,strlab6,charsize=1.2
    xyouts,0.9*xoff[x_ind[1]],0.8*yoff[y_ind[0]],strlab7,charsize=1.6,$
      alignment=0.5,color=1
    xyouts,0.9*xoff[x_ind[1]],0.7*yoff[y_ind[0]],strlab8,charsize=1.3,$
      alignment=0.5
    print,'Hardcopy of flux density vs position is ',outfile1
    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/encapsulated,/color
    device,filename=outfile1,font_size=12
    plot,xvec[1:3],yz,xrange=[xmin,xmax],yrange=[ymin,ymax],$
      xtitle='!7D!6x',ytitle='!7D!6y',/nodata
    oplot,xpar[1:1],ypar[1:1],psym=1,color=1,symsize=6.0
;    oplot,xz,yvec[1:3]
    xyouts,xoff[icen],yoff[icen],strlab0,charthick=2.0,alignment=0.5
    xyouts,xoff[x_ind[0]],yoff[icen],strlab1,charthick=2.0,alignment=0.5,color=2
    xyouts,xoff[x_ind[1]],yoff[icen],strlab2,charthick=2.0,alignment=0.5,color=3
    xyouts,xoff[icen],yoff[y_ind[0]],strlab3,charthick=2.0,alignment=0.5,color=2
    xyouts,xoff[icen],yoff[y_ind[1]],strlab4,charthick=3.0,alignment=0.5,color=3
    xyouts,0.98*xmin,0.95*ymax,strlab5,charthick=2.0
    xyouts,0.98*xmin,0.85*ymax,strlab6,charthick=2.0
    xyouts,0.9*xoff[x_ind[1]],0.8*yoff[y_ind[0]],strlab7,charthick=2.0,$
      alignment=0.5,color=1
    xyouts,0.7*xoff[x_ind[1]],0.7*yoff[y_ind[0]],strlab8,charthick=2.0,$
      alignment=0.5
    device,/close
    set_plot,'x'


endif else begin
    fwhmx=fltarr(nbin)
    fwhmy=fltarr(nbin)
    for n=0,nbin-1 do begin
; vectors with signal and errors for x-direction
        svecx=[snu_bin[n,icen],snu_bin[n,icen],snu_bin[n,x_ind[0]],$
           snu_bin[n,x_ind[1]]]
        errvecx=[serr_bin[n,icen],serr_bin[n,icen],serr_bin[n,x_ind[0]],$
                 serr_bin[n,x_ind[1]]]
; vectors with signal and errors for y-direction
        svecy=[snu_bin[n,icen],snu_bin[n,icen],snu_bin[n,y_ind[0]],$
               snu_bin[n,y_ind[1]]]
        errvecy=[serr_bin[n,icen],serr_bin[n,icen],serr_bin[n,y_ind[0]],$
                 serr_bin[n,y_ind[1]]]

;fit Gaussian in x-direction
        gfitx=gaussfit(xvec,svecx,xpar,measure_errors=errvecx,nterms=3,$
                       sigma=sigmax)
;gfitx=gaussfit(xvec,svecx,xpar,nterms=3,sigma=sigmax)
        fwhmx[n]=2*sqrt(2*alog(2))*xpar[2]
;fit Gaussian in y-direction
        gfity=gaussfit(yvec,svecy,ypar,measure_errors=errvecx,nterms=3,$
                       sigma=sigmay)
;gfity=gaussfit(yvec,svecy,ypar,nterms=3,sigma=sigmay)
        fwhmy[n]=2*sqrt(2*alog(2))*ypar[2]
        print,'n = ',n,' FWHM (x) = ',fwhmx[n],' FWHM (y) = ',fwhmy[n],$
          format='(a,i3,3x,a,f8.4,3x,a,f8.4)'
    endfor

; throw out any values that are negative or highly discrepant
    goodfitx=where(fwhmx gt 0 and fwhmx lt 100.)
    goodfity=where(fwhmy gt 0 and fwhmy lt 100.)
    window,2
    if (iopt eq 0) then begin
        plot,fwhmx(goodfitx),/xst,xtitle='Bolometer',ytitle='FWHM',psym=10
    endif else begin
        plot,fwhmx(goodfitx),/xst,xtitle='Bin number',ytitle='FWHM',psym=10
    endelse
    xyouts,0.6*nbin,0.95*max(fwhmx(goodfitx)),'FWHM (x)',charsize=2.0
    oplot,fwhmy(goodfity),color=2,psym=10
    xyouts,0.6*nbin,0.85*max(fwhmx(goodfitx)),'FWHM (y)',color=2,charsize=2.0

    print,'Hardcopy of FWHM vs bolo/bin number is ',outfile2
    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/encapsulated,/color
    device,filename=outfile2,font_size=12
    if (iopt eq 0) then begin
        plot,fwhmx(goodfitx),/xst,xtitle='Bolometer',ytitle='FWHM',thick=2.0,$
          charthick=2.0,psym=10
    endif else begin
        plot,fwhmx(goodfitx),/xst,xtitle='Bin number',ytitle='FWHM',thick=2.0,$
          charthick=2.0,psym=10
    endelse
    xyouts,0.6*nbin,0.95*max(fwhmx(goodfitx)),'FWHM (x)',charthick=2.0
    oplot,fwhmy(goodfity),color=2,psym=10,thick=2.0
    xyouts,0.6*nbin,0.85*max(fwhmx(goodfitx)),'FWHM (y)',color=2,charthick=2.0
    device,/close
    set_plot,'x'


;  plot mean values as function of position
    strlab0=STRING(mean(snu_bin[*,icen]))
    strlab1=STRING(mean(snu_bin[0,x_ind[0]]))
    strlab2=STRING(mean(snu_bin[0,x_ind[1]]))
    strlab3=STRING(mean(snu_bin[0,y_ind[0]]))
    strlab4=STRING(mean(snu_bin[0,y_ind[1]]))
    strlab5='Fitted center:'
    strlab6=STRING('('+STRCOMPRESS(xpar[1],/remove_all))+','+$
      STRING(STRCOMPRESS(ypar[1],/remove_all))+')'

    window,3
    plot,xvec[1:3],yz,xrange=[xmin,xmax],yrange=[ymin,ymax],$
      xtitle='!7D!6x',ytitle='!7D!6y',/nodata,$
      title='Mean values (averaged over all bolos)'
    oplot,xpar[1:1],ypar[1:1],psym=1,color=1,symsize=6.0
    xyouts,xoff[icen],yoff[icen],strlab0,charsize=1.3,alignment=0.5
    xyouts,xoff[x_ind[0]],yoff[icen],strlab1,charsize=1.3,alignment=0.5,color=2
    xyouts,xoff[x_ind[1]],yoff[icen],strlab2,charsize=1.3,alignment=0.5,color=3
    xyouts,xoff[icen],yoff[y_ind[0]],strlab3,charsize=1.3,alignment=0.5,color=2
    xyouts,xoff[icen],yoff[y_ind[1]],strlab4,charsize=1.3,alignment=0.5,color=3
    xyouts,0.9*xoff[x_ind[1]],yoff[y_ind[0]],strlab5,charsize=1.6,$
      alignment=0.5,color=1
    xyouts,0.9*xoff[x_ind[1]],0.85*yoff[y_ind[0]],strlab6,charsize=1.3,$
      alignment=0.5

    print,'Hardcopy of flux density vs position is ',outfile1
    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/encapsulated,/color
    device,filename=outfile1,font_size=12
    plot,xvec[1:3],yz,xrange=[xmin,xmax],yrange=[ymin,ymax],$
      xtitle='!7D!6x',ytitle='!7D!6y',/nodata,$
      title='Mean values (averaged over all bolos)'
    oplot,xpar[1:1],ypar[1:1],psym=1,color=1,symsize=6.0
;    oplot,xz,yvec[1:3]
    xyouts,xoff[icen],yoff[icen],strlab0,charthick=2.0,alignment=0.5
    xyouts,xoff[x_ind[0]],yoff[icen],strlab1,charthick=2.0,alignment=0.5,color=2
    xyouts,xoff[x_ind[1]],yoff[icen],strlab2,charthick=2.0,alignment=0.5,color=3
    xyouts,xoff[icen],yoff[y_ind[0]],strlab3,charthick=2.0,alignment=0.5,color=2
    xyouts,xoff[icen],yoff[y_ind[1]],strlab4,charthick=3.0,alignment=0.5,color=3
    xyouts,0.9*xoff[x_ind[1]],0.8*yoff[y_ind[0]],strlab5,charthick=2.0,$
      alignment=0.5,color=1
    xyouts,0.7*xoff[x_ind[1]],0.7*yoff[y_ind[0]],strlab6,charthick=2.0,$
      alignment=0.5
    device,/close
    set_plot,'x'


endelse


;sum_err_sq=total(serr^(-2),2)

;for n=0,nbolos-1 do begin
;    for k=0,nobs-1 do begin
;        snu_ave[n]=snu[n,k]/serr[n,k]^2+snu_ave[n]
;    endfor
;    snu_ave[n]=snu_ave[n]/sum_err_sq[n]
;endfor

end
