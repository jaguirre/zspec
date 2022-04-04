; TC's histogram gaussian fitter.  No better or worse than histogauss,
; but doesn't have a particular annoying failure mode.

function gaussfit_hist, values, nbins, minval, maxval, $
                        hist=hist, xtemp=xtemp, yfit=yfit, min2fit=min2fit, $
                        max2fit=max2fit, plot=plot, oplot=oplot, $
                        color=color, title=title, $
                        xtitle=xtitle, stopit=stopit, charsize=charsize, $
                        nofit=nofit, log=log

; if data is all NaNs, quit
whfin = where(finite(values),nfin)
if nfin eq 0 then return,fltarr(3)+!values.f_nan

if n_params() le 2 then begin
    medval = median(values)
    rms = stddev(values,/nan)
    minval = medval - 6.*rms
    maxval = medval + 6.*rms
endif
if n_params() eq 1 then nbins = n_elements(values)/4L
; make sure enough bins for fit
if nbins le 4 then nbins = 4

binsize = (maxval-minval)/(float(nbins-1))
xtemp = (findgen(nbins)+0.5)*binsize+minval

hist = histogram(double(values),min=minval,max=maxval,nbins=nbins)

if keyword_set(min2fit) then xmin = min2fit else xmin = min(xtemp)
if keyword_set(max2fit) then xmax = max2fit else xmax = max(xtemp)
wh2fit = where(xtemp ge xmin and xtemp le xmax,n2fit)
; if limits are stupid, then just use all data.
if n2fit eq 0 then wh2fit = lindgen(nbins)

if keyword_set(nofit) then begin
    yfit = findgen(n_elements(wh2fit))
    atemp = findgen(3)
endif else begin
    yfit = gaussfit(xtemp[wh2fit],hist[wh2fit],atemp,nterms=3)
    yfit = atemp[0]*exp(-(xtemp-atemp[1])^2/2./atemp[2]^2)
endelse

if keyword_set(plot) then begin
    do_log = keyword_set(log)
    if n_elements(title) eq 0 then title = ''
    if n_elements(xtitle) eq 0 then xtitle = 'values'
    if do_log then $
      plot,xtemp,hist,psym=10,thick=2,xtitle=xtitle,ytitle='# per bin',title=title,chars=charsize,/yl,yra=[1,max(hist)] $
    else $
      plot,xtemp,hist,psym=10,thick=2,xtitle=xtitle,ytitle='# per bin',title=title,chars=charsize
    oplot,xtemp,yfit,thick=2,line=2
    annot = 1.2
    X1 = !x.crange[0] + annot*(!x.crange[1]-!x.crange[0])/20./0.82 
    y1 = !y.crange[1] - annot*(!y.crange[1]-!y.crange[0])/23./0.82 
    ft = '(e12.3)'
    XYOUTS, X1, Y1, strcompress('mean = '+string(atemp[1],format=ft)+', sd = '+string(atemp[2],format=ft)), CHARSIZE=ANNOT
endif

if keyword_set(oplot) then begin
    if n_elements(color) eq 0 then color=!red
    oplot,xtemp,hist,psym=10,thick=2,color=color
    oplot,xtemp,yfit,thick=2,line=2,color=color
endif

if keyword_set(stopit) then stop

return, atemp

end
