;+
;NAME
;  plot_uber_spectrum_ks
;
;CALLING SEQUENCE:
;  plot_uber_spectrum_ks, sf[, plotfilename, /mars, /plot_sens, $
;                              z2plot=z2plot, $
;                              zilf_fit_file=zilf_fit_file, $
;                              _extra=ex]
;
;REQUIRED INPUTS:
;  sf - [string] The name of the output saveset from
;       uber_spectrum.pro. Must include source name subdirectory, e.g.:
;       'Mars/Mars_blahblahblah.sav'
;
;OPTIONAL INPUTS:
;  mars - [boolean] If set, will compute the expected model spectrum
;         for Mars and overplot on measured spectrum. Will also make a
;         plot of the residuals ( = 100*(measured_spectrum -
;         model_spectrum)/model_spectrum ), and will print the median
;         residuals of all channels to the screen.
;  plot_sens - [boolean] If set, will plot an estimate of the
;              sensitivity for each channel.
;  z2plot - [float] The redshift to assume for overplotting lines. If
;           not set, will use the redshift stored in the uber_spectrum
;           saveset.
;  zilf_fit_file - [string] The name of an output saveset from
;                  zilf. Set this if you want to subtract the
;                  continuum from the spectrum before plotting.
;  plot_lines - [boolean] Set this if you want to overplot positions
;               of lines.
;
;  Additionally, can pass basic IDL graphics keyword to the plot
;  command
;
;OPTIONAL OUTPUTS:
;  plotfilename - [string] If set, will output the plot in a
;                 postscript file (plots to screen by default) of this
;                 name. (Do NOT include the source name subdirectory
;                 here.)
;
;MODIFICATION HISTORY:
;  04/21/2010 - KS - Added a long time ago but poorly documented; gave
;               it a proper heading; fixed problem with colors; made
;               output postscript file an option, and now the default
;               is to plot to the screen. Added keyword PLOT_LINES,
;               and now will not plot lines unless this is set.
; 10/19/2010 -REL - Sorry Kim, I have to hack this thing to work with APEX data.
;		Don't kill me if I break something :-)
; 10/21/2010 - REL - more hacking: new uranus keyword to check
;              calibration/coupling
; 12/05/2012 - JRK - Added keyword custom_title.
; 12/19/2012 - KSS - committed latest revision to svn
;------------------------------------------------------
;CREATED ~DEC 2009 BY KIM SCOTT
;------------------------------------------------------
;-

pro plot_uber_spectrum_ks, sf, plotfilename, $
                           mars=mars, uranus=uranus,$
                           plot_sens=plot_sens, $
                           z2plot = z2plot, $
                           zilf_fit_file = zilf_fit_file, $
                           plot_lines=plot_lines, $
                           _extra=ex,xflat=xflat,custom_title=custom_title

;grab spectrum
sf2=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+sf
restore,sf2
nu = freqid2freq()
nfreq = n_elements(nu)
gind = lindgen(nfreq)
gind = [gind[0:80],gind[82:*]] ;exclude noisy channel 81
nu = nu[gind]
zspec_spectrum = uber_psderror.in1.avespec[gind]
zspec_err = uber_psderror.in1.aveerr[gind]

;define output ps filename
if keyword_set(plotfilename) then begin
    oplotfile=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+source_name+'/'+plotfilename
    set_plot,'ps',/copy
    !p.thick=2
    !p.charthick=2
    !x.thick=2
    !y.thick=2
endif

;set default plotting parameters
fnameind = strpos(file_list, '/', /reverse_search)+1
fname = strmid(file_list, fnameind)
if n_e(fname) ne 0 then fname = ' '
plottitle = fname
; Lo siento, this is a Julia hack...
if keyword_set(custom_title) then plottitle=custom_title else plottitle=source_name+' observed for '+STRING(total_n_sec/3600,format='(F5.1)')+' hours'
xr=[180,310]
ymin=1e-4
ymax=1e4

;subtract continuum?
if keyword_set(zilf_fit_file) then begin
    restore, zilf_fit_file
    zspec_spectrum = zspec_spectrum - fit.cspec[gind]
endif

if not keyword_set(z2plot) then z2plot = z

;these are default values for yrange to plot
whlow = where(nu ge 220 and nu le 240)
yrange = [median(zspec_spectrum[whlow])*0.3,$
          max(zspec_spectrum)*1.1]
;reset yrange if defined by user via _extra keyword
if keyword_set(ex) then begin
    if tag_exist(ex, 'yr') then yrange = ex.yr
    if tag_exist(ex, 'yrange') then yrange = ex.yrange
endif

;These are generally approximate, probably won't work for all cases.
label_positions_linear=[yrange[1]*0.9,yrange[1]*0.8,yrange[1]*0.7]
label_positions_log=[yrange[1]*0.7,yrange[1]*0.3,yrange[1]*0.2]

;****************************************************

;set up output file if ps
if keyword_set(plotfilename) then begin
    device,file=oplotfile,/color,/inches,/portrait,xsize=7.5,$
      ysize=8,yoffset=0.5,xoffset=0.5
endif

;decide # of plots
nmult=1
if keyword_set(mars) then nmult = keyword_set(mars) + 1
if keyword_set(uranus) then nmult = keyword_set(uranus) + 1
if keyword_set(plot_sens) then nmult+=1
erase
if not keyword_set(plotfilename) then window, 0, xsize=700, ysize=300*nmult
multiplot, [1, nmult]

;plot up spectrum
if nmult gt 1 then xtit=' ' else xtit='Detector Channel [GHz]'
plot, nu, zspec_spectrum, $
  psym=10, /ynoz, /yst, ytit='Flux Density [Jy]',$
  xrange=xr,tit=plottitle,/xst,/nodata,charsize=1.3,yrange=yrange,$
  ymarg=[20,3], xtitle=xtit, _extra=ex
oploterror, nu, zspec_spectrum, $
  zspec_err,psym=10
labelpos = label_positions_linear
if keyword_set(ex) then begin
    if tag_exist(ex, 'ylog') then labelpos = label_positions_log
endif

if keyword_set(plot_lines) then $
  printlines_uber_spectra, labelpos, z2plot, ymin, ymax, /all_lines

;overplot expected mars spectrum?
if keyword_set(mars) then begin
    ;get expected mars spectrum
	;stop
    fnameind = strpos(file_list(0), '/', /reverse_search)+1
    fname = strmid(file_list(0), fnameind)
    ckapex=strmid(fname,0,4)
    if (ckapex eq 'APEX') then begin 
    dname=strmid(file_list(0),fnameind+11)
	year=strmid(fname,11,4)
 	mo=strmid(fname,16,2)
	day=strmid(fname,19,2)
    date=year+mo+day;long(strmid(dname,0,8))
    endif else date = long(strmid(fname, 0, 8))
	print,date
    if (ckapex eq 'APEX') then mars_flux = mars_jy(date,/apex) else  mars_flux = mars_jy(date)
    mars_flux = mars_flux[gind]
    oplot, nu, mars_flux, linestyle=2
   
    ;now plot up residuals
    multiplot
    resids = (zspec_spectrum-mars_flux)/mars_flux*100
    if nmult gt 2 then xtit=' ' else xtit='Detector Channel [GHz]'
    plot, nu, resids, $
      psym=10,/yno,/yst,ytit='Residuals [%]',$
      xrange=xr,tit=' ',/xst,/nodata,charsize=1.3,$
      yrange=[min(resids),max(resids)],ymarg=[20,3], xtitle=xtit
    xflat=zspec_spectrum/mars_flux
    oploterror,nu,resids, $
      zspec_err/mars_flux*100.,psym=10
    oplot, nu, fltarr(nfreq),linestyle=2
    print, 'Median Residuals = ', median(resids), '%'
endif


;overplot expected uranus spectrum?
if keyword_set(uranus) then begin
    ;get expected uranus spectrum
	;stop
    fnameind = strpos(file_list(0), '/', /reverse_search)+1
    fname = strmid(file_list(0), fnameind)
    ckapex=strmid(fname,0,4)
    if (ckapex eq 'APEX') then begin 
    dname=strmid(file_list(0),fnameind+11)
	year=strmid(fname,11,4)
 	mo=strmid(fname,16,2)
	day=strmid(fname,19,2)
    date=year+mo+day;long(strmid(dname,0,8))
    endif else date = long(strmid(fname, 0, 8))
	print,date
stop
    if (ckapex eq 'APEX') then uranus_flux = uranus_jy(date,/apex) else  uranus_flux = uranus_jy(date)
    uranus_flux = uranus_flux[gind]
    oplot, nu, uranus_flux, linestyle=2
   
    ;now plot up residuals
    multiplot
    resids = (zspec_spectrum-uranus_flux)/uranus_flux*100
    if nmult gt 2 then xtit=' ' else xtit='Detector Channel [GHz]'
    plot, nu, resids, $
      psym=10,/yno,/yst,ytit='Residuals [%]',$
      xrange=xr,tit=' ',/xst,/nodata,charsize=1.3,$
      yrange=[min(resids),max(resids)],ymarg=[20,3], xtitle=xtit
    xflat=zspec_spectrum/uranus_flux
    oploterror,nu,resids, $
      zspec_err/uranus_flux*100.,psym=10
    oplot, nu, fltarr(nfreq),linestyle=2
    print, 'Median Residuals = ', median(resids), '%'
endif



;plot implied sensitivity?
if keyword_set(plot_sens) then begin
    multiplot
    plot,nu,zspec_err*sqrt(total_n_sec),$
      /yno,ytit=textoidl('Sensitivity [Jy s^{1/2}]'),$
      xrange=xr,/xst,/nodata,charsize=1.3,$
      xtit='Detector Channel [GHz]',/yst,$
      /ylog,yrange=[0.1,20.];[0.,20.]

    oplot,nu,zspec_err*sqrt(total_n_sec),$
      psym=10,col=240
endif

multiplot,/reset
if keyword_set(plotfilename) then begin
    device,/close
    set_plot,'x',/copy
    print,'Postscript plot at: '+oplotfile+'.'
endif

end
