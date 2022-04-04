;+
;===========================================================================
;  NAME: 
;		  blo_noise_plot
;   
;  DESCRIPTION: 
;		  Plot Power Spectrum
;	
;  USAGE: 
;		  blo_noise_plot, x_s, s, title, ytitle, $
;	          minfreq, vnlim, freqlim, nepreq, calcvn, $     
;	          nsum=nsum, xrange=xrange, yrange=yrange        
; INPUT:
;    x_s           frequency [Hz]			         
;    s             power spectrum [V]			         
;    title	  (string) plot title			         
;    ytitle 	  (string) signal name			         
;    minfreq	  (2 elem vector) reference line on plot         
;    vnlim	  (2 elem vector) reference line on plot         
;    freqlim	  (2 elem vector) reference line on plot         
;    nepreq	  (2 elem vector)  reference line on plot        
;		  show NEP requirement in units of 10^-17W/rtHz  
;    calcvn	  (2 elem vector)  reference line on plot        
;		  NEP calculation reference		         
;
;  OUTPUT:
;    x_s	  frequency [Hz]			  
;    s		  power spectrum [V]			  
;
;  KEYWORDS:
;    nsum	  set to number of points to be averaged  
;		  before plotting			  
;    xrange	  same as in plot			  
;    yrange	  same as in plot			  
;
;  AUTHOR:
;		  Bernhard Schulz
;
;
; Edition History
;
; Date        Programmer Remarks
; ---------- ----------  -------
; 2002-05-02  B.Schulz   Extracted from coadd_spectra_files.pro
; 2002-05-03  B.Schulz   added nsum keyword
; 2002-05-07  B.Schulz   xrange, yrange keywords added, limit plotting fixed
;
;===========================================================================
;-

pro blo_noise_plot, x_s, s, title, ytitle, $
	    minfreq, vnlim, freqlim, nepreq, calcvn, $
         nsum=nsum, xrange=xrange, yrange=yrange

  if NOT keyword_set(nsum) then nsum=0
  plot, x_s(*), s(*), psym = 3, nsum = nsum, $
    /ylog, xstyle=3, $
    /xlog, /ystyle, $
    xtitle = 'Frequency (Hz)', $
    ytitle = 'Spectrum of ' + ytitle, $
    title = title, xrange=xrange, yrange=yrange
  ; Plot reference marks
  ;
  ; Show low frequency bound on requirement
  oplot, minfreq[*], vnlim[*] , line=1
;  oplot, freqlim[*], nepreq[*], line=1 	; show NEP requirement
;  							    		; in units of 10^-17W/rtHz
;  oplot, freqlim[*], calcvn[*], line=2 		 ; show calculated noise

  oplot, freqlim[*], sqrt(nepreq[*]*1e-17), line=1 ; show NEP requirement
  							    			 ; in units of 10^-17W/rtHz
  oplot, freqlim[*], sqrt(calcvn[*]*1e-17), line=2 ; show calculated noise

end



