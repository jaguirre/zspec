pro fivepoint_apex, filename, off, use_co = use_co, stopit=stopit,dx=dx,dy=dy,bmx=bmx,bmy=bmy

;12/19/2012 - KSS - committed latest revision to svn

if ~keyword_set(use_co) then use_co=0
!p.charsize = 2

restore,filename;,/VERBOSE
nbolos = 160
bolo_flags = lonarr(nbolos)+1
bolo_flags[[81,86]] = 0
; Create some additional variables for compatibility with functions that
; used to work with output from npt_obs
bolos = INDGEN(nbolos)
n_nods = N_ELEMENTS(nod_struct)
nu = freqid2freq(bolos)
nco = WHERE(ABS(nu-230.) EQ MIN(ABS(nu-230.)))
snu = vopt_spectra.in1.nodspec
serr = vopt_spectra.in1.noderr
; ------

d_tel = 12.

fwhm_difflim = 1.22 * (2.99d8/(nu*1.d9)) / d_tel / !dtor * 3600.

; Create output filenames for PS files
outfile1=change_suffix(filename,'_5pt_positions_ja.ps')
outfile2=change_suffix(filename,'_5pt_fwhm_ja.ps')
outfile3=change_suffix(filename,'_5pt_spectra_ja.ps')

bolos_plot = bolos
snu_plot = snu
for i = 0,n_e(snu[0,*])-1 do begin
    snu_plot[*,i] = snu[*,i]/reform(bolo_flags)
endfor

; Just use good bolos
whgood = where(bolo_flags eq 1)
if use_co then whgood=where(freqid2freq() lt 231.4 and freqid2freq() gt 229.4)
nbolos = n_elements(whgood)
bolos = bolos[whgood]
nu = nu[whgood]
snu = snu[whgood,*]
serr = serr[whgood,*]

; Offsets should come from file, but I don't know how yet
xoff = [-1.,0,1.,0,0]*off
yoff = [0,0,0,-1.,1.]*off

; Again, don't have APEX pointing model
fazo = 0.
fzao = 0.

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

smaxc[0]=1.2*max(snu[*,0])
smaxc[1]=1.2*max(snu[*,x_ind])
smax=max(smaxc)
sminc[0]=min(snu[*,0])
sminc[1]=min(snu[*,x_ind])
smin=min(sminc)

!p.multi = [0,1,3]

; Plot spectra, both in hardcopy and not
norm = max(snu_plot[*,0],/nan)
for ps = 0,0 do begin

    if(ps) then begin
        set_plot,'ps'
        device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
          language_level=2,/color,font_size=12,filename = outfile3
    endif else begin
        window,0,xs=600,ys=700
    endelse

; Plot X-spectra
; Plot everything normalized to the center position.  Easier to use.
    plot,bolos_plot,snu_plot[*,icen],/xst,$
      yrange=[smin,smax],/yst, $
      xtitle='Bolometer number',ytitle='Signal',title=name, $
      psym=10,charsize=1.5
    oplot,bolos_plot,snu_plot[*,x_ind[0]],$
      color=2,psym=10
    oplot,bolos_plot,snu_plot[*,x_ind[1]],color=3,psym=10

    legend,/top,/right,['Central','neg X off','pos X off'],box=0,$
      textcolor=[ps-1,2,3]

; Plot Y-spectra
    plot,bolos_plot,snu_plot[*,icen],/xst,yrange=[smin,smax],/yst,$
      xtitle='Bolometer number',ytitle='Signal',title=name,$
      psym=10
    oplot,bolos_plot,snu_plot[*,y_ind[0]],color=2,psym=10
    oplot,bolos_plot,snu_plot[*,y_ind[1]],color=3,psym=10

    legend,/top,/right,['Central','neg Y off','pos Y off'],box=0,$
      textcolor=[ps-1,2,3]

    if(ps) then begin
        device,/close_file
        set_plot,'x'
    endif
    
endfor 

; -----------------------------------------------------------------------------

snu_bin=snu
serr_bin=serr
nbin=nbolos

amp=fltarr(nbin)
x0=fltarr(nbin)
y0=fltarr(nbin)
fwhmx=fltarr(nbin)
fwhmy=fltarr(nbin)
;fwhmxt=fltarr(nbin)
;fwhmyt=fltarr(nbin)
for n=0,nbin-1 do begin
;; vectors with signal and errors for x-direction
;    svecx=[snu_bin[n,icen],snu_bin[n,icen],snu_bin[n,x_ind[0]],$
;           snu_bin[n,x_ind[1]]]
;    errvecx=[serr_bin[n,icen],serr_bin[n,icen],serr_bin[n,x_ind[0]],$
;             serr_bin[n,x_ind[1]]]
;; vectors with signal and errors for y-direction
;    svecy=[snu_bin[n,icen],snu_bin[n,icen],snu_bin[n,y_ind[0]],$
;           snu_bin[n,y_ind[1]]]
;    errvecy=[serr_bin[n,icen],serr_bin[n,icen],serr_bin[n,y_ind[0]],$
;             serr_bin[n,y_ind[1]]]

;;fit Gaussian in x-direction
;    gfitx=gaussfit(xvec,svecx,xpar,measure_errors=errvecx,nterms=3,$
;                   sigma=sigmax)
;;    fwhmx[n]=2*sqrt(2*alog(2))*xpar[2]
;;fit Gaussian in y-direction
;    gfity=gaussfit(yvec,svecy,ypar,measure_errors=errvecx,nterms=3,$
;                   sigma=sigmay)
;;    fwhmy[n]=2*sqrt(2*alog(2))*ypar[2]
 
    ;***testing***
    x2fit = [xoff, -80., 80.,   0.,  0.]
    y2fit = [yoff,   0.,  0., -80., 80.]
    s2fit = [transpose(snu_bin[n,*]), 0., 0., 0., 0.]
    se2fit = [transpose(serr_bin[n,*]), replicate(serr_bin[n,0]*3.,4)]
    fwhm_guess = 30.;arcsec
    sp = [max(s2fit,whmx), x2fit[whmx], y2fit[whmx], fwhm_guess/2.35, fwhm_guess/2.35]
    fp = mpfit2dfun('zspec_2d_gauss', x2fit, y2fit, s2fit, se2fit, $
                    sp, bestnorm=chi2, dof=dof, perror=fperr, /quiet, $
                    status=status, yfit=yfit)
    amp[n] = fp[0]
    x0[n] = fp[1]
    y0[n] = fp[2]
    fwhmx[n] = 2.35*fp[3]
    fwhmy[n] = 2.35*fp[4]

endfor

; throw out any values that are negative or highly discrepant
min_fwhm = 20.
max_fwhm = 40.
    goodfitx=where(fwhmx gt min_fwhm  and fwhmx lt max_fwhm and fwhmx ne fwhm_guess)
    goodfity=where(fwhmy gt min_fwhm and fwhmy lt max_fwhm and fwhmy ne fwhm_guess)

; FWHM
    plot,fwhmx(goodfitx),/xst,xtitle='Bolometer',ytitle='FWHM',psym=10
    oplot,fwhm_difflim,col=1

    xyouts,0.6*nbin,0.95*max(fwhmx(goodfitx)),'FWHM (x)',charsize=2.0
    oplot,fwhmy(goodfity),color=2,psym=10
    xyouts,0.6*nbin,0.85*max(fwhmx(goodfitx)),'FWHM (y)',color=2,charsize=2.0
    
;  plot mean values as function of position
    strlab0=STRING(mean(snu_bin[*,icen]))
    strlab1=STRING(mean(snu_bin[*,x_ind[0]]))
    strlab2=STRING(mean(snu_bin[*,x_ind[1]]))
    strlab3=STRING(mean(snu_bin[*,y_ind[0]]))
    strlab4=STRING(mean(snu_bin[*,y_ind[1]]))
    strlab5='Fitted center:'
    strlab6=STRING('('+STRCOMPRESS(mean(x0),/remove_all))+','+$
      STRING(STRCOMPRESS(mean(y0),/remove_all))+')'

!p.multi = 0
window,1,xs=500,ys=500,xpos=400,ypos=1000

; Offsets
    plot,xvec[1:3],yz,xrange=[xmin,xmax],yrange=[ymin,ymax],$
      xtitle='!7D!6x',ytitle='!7D!6y',/nodata,$
      title='Mean values (averaged over all bolos)',/iso,$
      subtit = string('Fitted center: ',mean(x0[goodfitx]),mean(y0[goodfity]),$
;                      fazo+mean(x0),fzao-mean(y0),$
                      format='(A,F7.1,",",F7.1)'),$
;"!C","FAZO",F7.1,"  ","FZAO",F7.1)'),$
      ymarg=[6,4]

; The centroid
    oplot,[mean(x0[goodfitx])],[mean(y0[goodfity])],psym=1,color=1,symsize=6.0
; Values at each position
    xyouts,xoff[icen],yoff[icen],strlab0,charsize=1.3,alignment=0.5
    xyouts,xoff[x_ind[0]],yoff[icen],strlab1,charsize=1.3,alignment=0.5,color=2
    xyouts,xoff[x_ind[1]],yoff[icen],strlab2,charsize=1.3,alignment=0.5,color=3
    xyouts,xoff[icen],yoff[y_ind[0]],strlab3,charsize=1.3,alignment=0.5,color=2
    xyouts,xoff[icen],yoff[y_ind[1]],strlab4,charsize=1.3,alignment=0.5,color=3

    print,'Hardcopy of FWHM vs bolo/bin number is ',outfile2
    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/encapsulated,/color
    device,filename=outfile2,font_size=12

    plot,fwhmx(goodfitx),/xst,xtitle='Bolometer',ytitle='FWHM',thick=2.0,$
      charthick=2.0,psym=10

    xyouts,0.6*nbin,0.95*max(fwhmx(goodfitx)),'FWHM (x)',charthick=2.0
    oplot,fwhmy(goodfity),color=2,psym=10,thick=2.0
    xyouts,0.6*nbin,0.85*max(fwhmx(goodfitx)),'FWHM (y)',color=2,charthick=2.0
    device,/close
    set_plot,'x'

    print,'Hardcopy of flux density vs position is ',outfile1
    set_plot,'ps'
    device,/inches,xsize=8.,ysize=8,xoff=.25,yoff=.25,/portrait,$ 
      language_level=2,/encapsulated,/color
    device,filename=outfile1,font_size=12
    plot,xvec[1:3],yz,xrange=[xmin,xmax],yrange=[ymin,ymax],$
      xtitle='!7D!6x',ytitle='!7D!6y',/nodata,$
      title='Mean values (averaged over all bolos)'
    oplot,[mean(x0)],[mean(y0)],psym=1,color=1,symsize=6.0

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
;stop
if keyword_set(stopit) then stop

dx = mean(x0[goodfitx])
dy = mean(y0[goodfity])

sx = size(goodfitx)
sy = size(goodfity)
sx = sx[1]
sy=sy[1]


if  sx gt 80 and sy gt 80 then begin
     bmx = mean(fwhmx(goodfitx))
     bmy = mean(fwhmy(goodfity))
 endif
if  sx lt 80 and sy lt 80 then begin
     bmx = -1
     bmy= -1
endif

end
