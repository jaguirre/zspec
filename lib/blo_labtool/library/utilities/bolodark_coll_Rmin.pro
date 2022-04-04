;+
;===========================================================================
;  NAME: 
;		  bolodark_coll_Rmin
; 
;  DESCRIPTION:   
;		  Collect resistances and temperatures at minimum power
; 		  from data structure for one channel and fit Rstar and Tstar
;
;  USAGE: 
;		  bolodark_coll_Rmin, x, ichan, Rmin, Rmin_err, T_c, $
;		  T_c_err, Rstar, Tstar
;
;  INPUT: 	  
;     x           (struct) data structure produced by bolodark_read_loadcrv.pro  
;     ichan	  (long) channel number 				         
;
;  OUTPUT:	  
;     Rmin        (array float) resistance at minimum power	 (nfiles)        
;     Rmin_err    (array float) uncertainty of Rmin		 (nfiles)        
;     T_ca        (array float) mean temperature at Rmin	 (nfiles)        
;     T_ca_err    (array float) uncertainty of T_ca		 (nfiles)        
;     Rstar       (float) first fit parameter 				         
;     Tstar       (float) second fit parameter  			         
;
;  KEYWORDS:
;	plot	  if set plotting diagrams
;
;  AUTHOR: 
;		  Bernhard Schulz
;	
; 
;  Edition History:
;
;  Date    	Programmer   Remarks
;  ----------   ----------   -------
;  2003-05-02   B. Schulz    initial test version
;  2004-04-24   B. Schulz    bugfix: removed bias current conversion
;                            routine still needs further checking
;
;===========================================================================
;-
pro bolodark_coll_Rmin, x, ichan, Rmin, Rmin_err, T_c, T_c_err, $
	 Rstar, Tstar, plot=plot

nf = n_elements(x)

Rmin = fltarr(nf)
T_c  = fltarr(nf)
Rmin_err = fltarr(nf)
T_c_err  = fltarr(nf)


;-------------------------------------------
; collect data from all files (temperatures)

for ifile=0, nf-1 do begin						    

  									    
  bolodark_r_lowpow, (*x[ifile]).ubolo[ichan,*], (*x[ifile]).ubias, (*x[ifile]).T_c, $  
		      R, T					    

  Rmin[ifile] = R 						    
  T_c[ifile]  = T 						    
  ;Rmin_err[ifile] = Re						    
  ;T_c_err[ifile]  = Te						    

endfor									    

;-------------------------------------------
; 
T_c05 = T_c^(-0.5)					     	        
lgRmin = alog(Rmin)					     	        

ix = where(finite(T_c05) EQ 1 AND finite(lgRmin) EQ 1, cnt)   		        
if cnt GT 1 then begin  				     		        

  a = linfit( T_c05[ix], lgRmin[ix], sdev=alog(Rmin_err[ix]))	        

  if keyword_set(plot) then begin					        

    plot, T_c05[ix], lgRmin[ix], ystyle=3, charsize=1.8, xthick=2, ythick=2, $  
     color=blo_color_get('white'), $					        
     title = (*x[0]).ubolo_label[ichan] + ' at Low Power', $		        
     xtitle = 'T!U-1/2!N [K!U-1/2!N]', $				        
     ytitle = 'ln(R) [Ohms]', /nodata					        

    oplot, T_c05[ix], lgRmin[ix], psym=6,$ 				        
     color=blo_color_get('yellow'), symsize=0.5 			        

    oplot,T_c05[ix], a[0] + a[1]*T_c05[ix], linestyle=1, $		        
      color=blo_color_get('magenta')					        

    legend, ['R* = '+string(exp(a[0]),form='(f6.1)')+  $		        
	       ' T* = '+string(a[1]^2,form='(f6.2)')], linestyle=1, $	        
	       color=blo_color_get('magenta')
  endif  ;plot								        

endif else begin      ;finite						        

  a = [!values.f_nan,!values.f_nan]					        

endelse       ;finite							        

Rstar = exp(a[0])						        
Tstar = (a[1])^(-0.5d)						        

return
end


