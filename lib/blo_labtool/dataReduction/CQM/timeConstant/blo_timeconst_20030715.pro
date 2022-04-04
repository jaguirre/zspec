;=============================================================
;
; Plot line strength data depending on chopper frequency
;
; Determine time constants
;
; 2003/07/16 B. Schulz
; 
;=============================================================


;-----------------------------------------------
; fit function for time constant

pro tausig,f1,A,F
	F = 1/sqrt(1.+(2.*!PI*f1*A)^2)
	return
end



pro blo_timeconst_20030715

path = '/data1/SPIRE_CQM/20030715/'

goodpx = blo_getgoodpix()	;good pixel labels
npix = n_elements(goodpx)	;number of pixels


;read logfile with frequencies
logfname = path+'20030715_frequ.txt'
readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent

nf = n_elements(lg_fname)

dat1 = dblarr(1,npix,6)
fnames = strarr(1)

dat = dblarr(nf, npix, 6)	;storage for data
nel = fltarr(nf,npix)	        ;storage  

for ifil = 0, nf-1 do begin

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


;-----------------------------------------------
; plot single values

psinit, /letter, /full, /color


!p.multi=[0,4,6]

openw, un, path+'timeconst_20030715.txt',/get_lun
printf, un, systime()
printf, un
printf, un, 'pixel', 'tau', 'sigma/tau', format='(a12,x,a9,x,a9)'
printf, un, '--------------------------------'

for ipix=0, npix-1 do begin

  ix = where(dat1[*,ipix,0] GT 0.6 AND dat1[*,ipix,0] LT 1.4)
  norm = avg(dat1[ix,ipix,1])

  f1 = dat1[*,ipix,0] 
  y  = dat1[*,ipix,1]/norm
  ix = where((f1 LT 8. AND y LT 1.2) OR  y LT 1.)	;remove some notorious outliers 
  f1 = f1[ix]
  y = y[ix]

  ix1 = sort(f1)	;sort
  f1 = f1[ix1]
  y = y[ix1]
  


  A = [0.018]
  weights = y*0+1.0
  yfit = CURVEFIT(f1,y,weights,A,sigma,function_name='tausig',/noderivative,/double,tol=1e-5)

  plot_oo, f1, y, psym=6, $
  	title=goodpx[ipix]+' Bias Ampl. 10mV, Tau='+  $
	strtrim(string(a[0]*1000.,form='(f5.1)'),2)+' ms', $
	symsize=0.5, $
	xtitle='frequency [Hz]', ytitle='rel. V rms', charsize=0.6, $
	xrange=[0.5,70], yrange=[0.07,2.], xstyle=3, ystyle=3
  oplot, f1,yfit, linestyle=2
  printf, un, goodpx[ipix], a, sigma/a, format='(a12,x,f9.6,x,f9.6)'

endfor


free_lun, un


;-----------------------------------------------

!p.multi=0
psterm, file=path+'blo_timeconst_20030715.ps'

end


