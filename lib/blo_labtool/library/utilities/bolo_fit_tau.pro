;+
;===========================================================================
;  NAME: 
;		      bolo_fit_tau					   
;
;  DESCRIPTION:       								   
;		      Using gaussian fit to determine the time constant 	   
;
;  USAGE: 
;		      bolo_fit_tau, data, goodpx, tau, sigma_over_tau, $	   
;                     plot=plot 				      	     	 
;
;  INPUT:
;     data            3 dimensional array containg the line strength output  	 
;     goodpx          A string array containing the good pixle labels 	     	 
;
;  OUTPUT:
;     tau             A double precision array containing the time constant
;     sigma_over_tau
;                     A double array containing the ratio or sigma/tau 
;
;  KEYWORDS:
;     plot            If set, the plot will be produced 			 
;     bias            It is a string of character.  It set, use it in the titile 
;
;  AUTHOR:  
;		      L. Zhang
;		     							 
;
;  Edition History
; 
;  date         Programmer      Remarks
;  2003-10-02   L. Zhang        Initial test version (extract from the 
;                               data reduction procedure)
;  2003-10-14   L. Zhang        Make y linear for plots
;  2003-12-17   L. Zhang        Add keyword bias
;                               change the f1 and y filter values  
;  2004-08-06   B. Schulz       allowed higher frequencies for norm
;				if lower ones not found
;===========================================================================
;-
;  fit function for time constant
;  Function to fit S(f) = A/SQRT(1 + 2 * PI * F *tau^2) 
;  where tau is the time contant
;---------------------------------------------------------------------------
PRO tausig,f1,A,F
	F = A[1]/sqrt(1.+(2.*!PI*f1*A[0])^2)
	return
END
;---------------------------------------------------------------------------
Function  bolo_fit_amoebafunc, a
  common share, f1, y
	F = A[1]/sqrt(1.+(2.*!PI*f1*A[0])^2)
	return,  total((y-F)^2)
	;return,  max(abs(y-F))
END 
;---------------------------------------------------------------------------

PRO bolo_fit_tau, data, goodpx, tau, sigma_over_tau, bias=bias, plot=plot
  
   common share, f1, y
   
   npix = n_elements(goodpx)
 
   tau=dblarr(npix)
   sigma_over_tau=dblarr(npix)
  
   
   for ipix=0, npix-1 do begin
	norm=0		;find norm at low frequencies
        ix = where(data[*,ipix,0] GT 0.6 AND data[*,ipix,0] LT 1.4, cnt)
        if cnt LE 0 then $    ;nothing found, try higher frequ.
          ix = where(data[*,ipix,0] GT 0.6 AND data[*,ipix,0] LT 4., cnt)

        if (cnt ge 1) then norm = max(data[ix,ipix,1]) $
	else message, 'Lower frequencies not found for norm!'

        f1 = data[*,ipix,0] 
        if norm NE 0 then y  = data[*,ipix,1]/norm
        ;ix = where(((f1 LT 59. AND y LT 1.2) OR  y LT 0.7) $
        ;             AND y GT 0.1 AND f1 GT 0 and f1 gt 65 and f1 le 59.5, cnt )  ;remove some notorious outliers 
        
	;ix changed 2003/12/17 
	ix = where( ((f1 lt 59.0 and y lt 1.0) or f1 gt 61 ) $
	 AND y gt 0.1 AND f1 GT 0, cnt)

	if (cnt ge 1) then begin 
	  f1 = f1[ix]
          y = y[ix]
        endif
	
        ix1 = sort(f1)        ;sort
        f1 = f1[ix1]
        y = y[ix1]
	
     	a = [0.02, 1.0]
     	weights = y*0+1.0
        	     
     	yfit = CURVEFIT(f1,y,weights,A,sigma,function_name='tausig',/noderivative, $
     		itmax=500, /double,tol=1e-25)
     	
        if finite(a[1]) then norm = a[1] else norm = 1.0      ;correct norm
        a[0] = abs(a[0])                      ;ensure positive time constant
        tau[ipix]=a[0]
      
        sigma_over_tau[ipix]=sigma[0]/a[0]
     
        if keyword_set(plot) then begin 
       		;10/16/03 Hien wants Y axis linear and x log
		;plot_oo, f1, y/norm, psym=6, $
		
		 if keyword_set(bias) then begin
		    title_str = goodpx[ipix] +', Bias Ampl.:' + bias+', Tau='+  $
                   strtrim(string(a[0]*1000.,form='(f5.1)'),2)+' ms'
		 endif else begin
		    title_str = goodpx[ipix]+' Tau='+  $
                     strtrim(string(a[0]*1000.,form='(f5.1)'),2)+' ms'
		 endelse 
  		 plot, f1, y/norm, psym=6, /xlog, $
                   title=title_str, symsize=0.5, $
                   xtitle='frequency [Hz]', ytitle='rel. V rms', charsize=0.7, $
                   xrange=[0.5,70], yrange=[0.1,1.5], xstyle=3, ystyle=3
             oplot, f1,yfit/norm, linestyle=2
        endif 
        
 
   endfor


END

