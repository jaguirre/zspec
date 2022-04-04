;=============================================================
;
; Plot line strength data depending on chopper frequency
;
; Determine time constants
;
; 2003/03/10 B. Schulz
;=============================================================


;-----------------------------------------------
; fit function for time constant

pro tausig,f1,A,F
	F = 1/sqrt(1.+(2.*!PI*f1*A)^2)
	return
end



pro blo_timeconst_20030520

path = '/data1/BoDAC/3_Pathfinder/20030520/'

goodpx = blo_getgoodpix()	;good pixel labels
npix = n_elements(goodpx)	;number of pixels


;read logfile with frequencies
logfname = path+'20030520_log.txt'
readfmt, logfname, 'a23, a41, f8, f5', lg_fname, lg_txt, lg_cfrequ, lg_SR780, /silent, skip=5

nf = n_elements(lg_fname)

bstart=0		;18
bstop =17		;nf-1

dat1 = dblarr(1,npix,6)
fnames = strarr(1)

dat = dblarr(nf, npix, 6)	;storage for data
nel = fltarr(nf,npix)	        ;storage  
biasflg1 = intarr(nf)
biasflg2 = intarr(1)

for ifil = 0, nf-1 do begin

  if ifil GT bstop then biasflg1[ifil] = 1	;set biasflag for averages

;------------------------------------
; find files and load data for same chopper frequency

  flist = findfile(path+strmid(lg_fname[ifil], 0, 13)+'*_pow_*.txt')
  nf1 = n_elements(flist)

  dummy = fltarr(nf1,npix,6)	;storage  
  for i=0, nf1-1 do begin
    blo_rd_linestr, flist[i], pxstore, finterval, srcfname
    dummy[i,*,*] = pxstore
  endfor

  dat1   = [dat1,dummy]
  fnames = [fnames,flist]
  biasflg2 = [biasflg2, replicate(biasflg1[ifil],nf1)]	;set biasflag for individual values

;------------------------------------

;  ix = where(dummy[35,0,*] GT 0, cnt)
;  print, lg_fname[ifil]
;  print, dummy[35,0,*], dummy[35,1,*]
;  print, '----'
;  print, avg(dummy[35,0,ix]), avg(dummy[35,1,ix])
;  print, '======='

  
;------------------------------------
; average over results of same frequency
 
  for ipix = 0, npix-1 do begin  
    ix = where(dummy[*,ipix,0] GT 0, cnt)	;valid entry?
    if cnt GT 0 then begin			
      nel[ifil,ipix] = cnt			;number of valid entries
      for i=0, 5 do dummy[0,ipix,i] = avg(dummy[ix,ipix,i])      ;average entries
    endif
  endfor
  dat[ifil,*,*] = reform(dummy[0,*,*])		;save result in first plane

;c=get_kbrd(1)

endfor

dat1 = dat1[1:*,*,*]
fnames = fnames[1:*]
biasflg2 = biasflg2[1:*]


;-----------------------------------------------
; plot single values

psinit, /letter, /full


!p.multi=[0,6,6]

openw, un, path+'timeconst_20030520)lo_bias.txt',/get_lun
printf, un, 'Low Bias (4.855mV)'
printf, un, systime()
printf, un
printf, un, 'pixel', 'tau', 'sigma/tau', format='(a12,x,a9,x,a9)'
printf, un, '--------------------------------'

for ipix=0, npix-1 do begin

  ix1 =  where(biasflg2 EQ 0)
  ix = where(dat1[ix1,ipix,0] GT 0.6 AND dat1[ix1,ipix,0] LT 1.4)
  norm = avg(dat1[ix1[ix],ipix,1])

  f1 = dat1[ix1,ipix,0] 
  y  = dat1[ix1,ipix,1]/norm
  ix = where((f1 LT 8. AND y LT 1.2) OR  y LT 1.)	;remove some notorious outliers 
  f1 = f1[ix]
  y = y[ix]


  plot_oo, f1, y, psym=6, $
  	title=goodpx[ipix]+' Bias Ampl. 4.855mV', symsize=0.5, $
	xtitle='frequency [Hz]', ytitle='rel. V rms', charsize=0.6, $
	xrange=[0.5,70], yrange=[0.07,2.], xstyle=3, ystyle=3

  A = [0.018]
  weights = y*0+1.0
  yfit = CURVEFIT(f1,y,weights,A,sigma,function_name='tausig',/noderivative,/double,tol=1e-5)

  oplot, f1,yfit, linestyle=2
  printf, un, goodpx[ipix], a, sigma/a, format='(a12,x,f9.6,x,f9.6)'

endfor


free_lun, un

;-----------------------------------------------


!p.multi=[0,6,6]

openw, un, path+'timeconst_20030520_hi_bias.txt',/get_lun
printf, un, 'High Bias (10.02mV)'
printf, un, systime()
printf, un
printf, un, 'pixel', 'tau', 'sigma/tau',  format='(a12,x,a9,x,a9)'
printf, un, '--------------------------------'

for ipix=0, npix-1 do begin

  ix1 =  where(biasflg2 EQ 1)
  ix = where(dat1[ix1,ipix,0] GT 0.6 AND dat1[ix1,ipix,0] LT 1.4 )
  norm = avg(dat1[ix1[ix],ipix,1])

  f1 = dat1[ix1,ipix,0] 
  y  = dat1[ix1,ipix,1]/norm
  ix = where((f1 LT 8. AND y LT 1.2) OR  y LT 1.)	;remove some notorious outliers 
  f1 = f1[ix]
  y = y[ix]

  plot_oo, f1, y, psym=6, $
  	title=goodpx[ipix]+' Bias Ampl. 10.02mV', symsize=0.5, $
	xtitle='frequency [Hz]', ytitle='rel. V rms', charsize=0.6, $
	xrange=[0.5,70], yrange=[0.07,2.], xstyle=3, ystyle=3
    
  A = [0.018]
  weights = y*0+1.0
  yfit = CURVEFIT(f1,y,weights,A,sigma,function_name='tausig',/noderivative,/double,tol=1e-5)

  oplot, f1,yfit, linestyle=2
  printf, un, goodpx[ipix], a, sigma/a, format='(a12,x,f9.6,x,f9.6)'
  
endfor

free_lun, un


;-----------------------------------------------
;plot averaged values
;
;for ipix=0, npix-1 do begin
;  ix1 =  where(biasflg1 EQ 0)
;  ix = where(dat[ix1,ipix,0] GT 0.6 AND dat[ix1,ipix,0] LT 1.4 )
;  norm = avg(dat[ix1[ix],ipix,1])
;
;  f1 = dat[ix1,ipix,0] 
;  y  = dat[ix1,ipix,1]/norm
;  ix = where((f1 LT 8. AND y LT 1.2) OR  y LT 1.)	;remove some notorious outliers 
;  f1 = f1[ix]
;  y = y[ix]
;
;  plot_oo, f1, y, psym=6, $
;	 title=goodpx[ipix]+' Bias Ampl. 4.855mV', symsize=0.5, $
;	 xtitle='frequency [Hz]', ytitle='V rms', charsize=0.6, xrange=[0.1,50], xstyle=3
;
;  A = [0.018]
;  weights = y*1
;  yfit = CURVEFIT(f1,y,weights,A,sigma,function_name='tausig',/noderivative,/double)
;
;  oplot, f1,yfit, linestyle=2
;  print, a
;endfor
;
;for ipix=0, npix-1 do begin
;  ix1 =  where(biasflg1 EQ 1)
;  ix = where(dat[ix1,ipix,0] GT 0.6 AND dat[ix1,ipix,0] LT 1.4 )
;  norm = avg(dat[ix1[ix],ipix,1])
;
;  f1 = dat[ix1,ipix,0] 
;  y  = dat[ix1,ipix,1]/norm
;  ix = where((f1 LT 8. AND y LT 1.2) OR  y LT 1.)	 ;remove some notorious outliers 
;  f1 = f1[ix]
;  y = y[ix]
;
;  plot_oo, f1, y, psym=6, $
;	 title=goodpx[ipix]+' Bias Ampl. 10.02mV', symsize=0.5, $
;	 xtitle='frequency [Hz]', ytitle='V rms', charsize=0.6, xrange=[0.1,50], xstyle=3
;
;  A = [0.018]
;  weights = y*0.1
;  yfit = CURVEFIT(f1,y,weights,A,sigma,function_name='tausig',/noderivative,/double)
;
;  oplot, f1,yfit, linestyle=2
;  print, a
;endfor

;-----------------------------------------------

!p.multi=0
psterm, file=path+'blo_timeconst_20030520.ps'

end


