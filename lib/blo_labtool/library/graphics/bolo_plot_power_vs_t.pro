;+
;==========================================================================
;
; NAME: 
;		  bolo_plot_power_vs_t
;
; DESCRIPTION: 
;		  This procedure will plot Power (P)  vs T (temperature), 
;		  where the Power is calcualted using the parameters G0 (  
;		  (Gstar), Beta  where thereturned by curvefit function.   
;
; USAGE: 
;		  bolo_plot_power_vs_t,x,  Rstar, Tstar,  Gstar, Beta, $
;		  Rload=Rload
; 
; INPUT:
;    Rstar	  A double precision one-dimension array containing 	         
;	          the Rstar		  				         
;    Tstar	  A double precision one-dimension array containing Tstar        
;    Gstar	  A double precision on-dimension array containing Gstar         
;    Beta	  A double precision on-dimension array containing Beta          
;    x   	  Array of structure containing the loadcurve data	         
;    		  							  
; KEYWORDS: 	
;    Rload        Load Resistance. If set, use the Rload, otherwise 	         
;                 use the default Rload (Rload=2.0e7)			         
;
;    T_c          If set the bath temperature from the measurement will be used  
;                 otherwise, T_c=min(T) is used 			         
;
; AUTHOR:  
;		  Lijun Zhang
;
; Edition History
;
; Date	       Programmer	Remarks
; 2003-07-30   L. Zhang 	initial version
; 2003-09-22   B. Schulz 	replaced parts by bolo_get_tptc.pro
; 2003-10-14   L. Zhang		Add T_c keyword
; 2003-12-09   L. Zhang         Simplified codes using contant T_c  
; 2004-06-08   B. Schulz        protect against bad pixels
;===========================================================================
;-

 PRO bolo_plot_power_vs_t, x,  Rstar, Tstar,  Gstar, Beta, Rload=Rload, T_c=T_c
   
    no_of_files = n_elements(x)
    
    
    ct = get_13colortable( )
    nct = n_elements(ct)
    nchannel = n_elements((*x[0]).ubolo[*,0])

    for ichannel=0, nchannel-1 do begin
      if Rstar[ichannel] GT 0 and Tstar[ichannel] GT 0 and Gstar[ichannel] GT 0 and Beta[ichannel] GT 0 $
      	then begin      
        for ifile=0, no_of_files-1 do begin            ;Start for loop 
              no_data=0
   	      if keyword_set(Rload) then begin  					  
   	     	 bolo_get_tptc, x,  ichannel, ifile, Rstar, Tstar, T, P, Rload=Rload  
   	      endif else begin								  
   	     	 bolo_get_tptc, x, ichannel, ifile,  Rstar, Tstar, T, P		  
              endelse								      											   

    	      if Not keyword_set(T_c) then begin 					  
    	     	 T_c = mean((*x[ifile]).T_c,/double)					  
    	      endif 									  
 	      
   	      Tbath=fix(T_c*1000)
             										  
              a0=Gstar[ichannel]			  					  
              a1=Beta[ichannel]+1.d0			  					  
             		    								  
              F= a0*(0.3)^(-Beta[ichannel])*( T^a1 - T_c^a1 )/a1  				  
             
	       								  
              ix=sort(T) ; connecting order from small T to big T			  
              P=P[ix]									  
              T=T[ix]									  
              F=F[ix]									  
              										  
              ix = where ( P gt 0 and F gt 0, cnt)					  
	      if(cnt gt 1) then begin
	     	 P=P[ix]
	     	 T=T[ix]
	     	 F=F[ix]
	      endif else begin
	         error_msg='No valid points in channe1 ' + $
		   strtrim(String(ichannel), 2)+':'+(*x(ifile)).ubolo_label[ichannel]
	         message, error_msg, /continue
		 no_data=1
	      endelse
	      
	      
	      ;chi_square=total( (F-P)^2, /double)/(1.d*n_elements(F))
	      chi_square=total( (F-P)^2/F, /double)/(1.d*n_elements(F))

              ;change the Power unit							  
              P=P*1e12									  
              F=F*1e12									  
	      
	      no_of_points_P=n_elements(P)
	      no_of_points_F=n_elements(F)
	      no_of_points=min([no_of_points_P,no_of_points_F])
	      
	      if (no_of_points le 1 or no_data eq 1) then begin
	      
	     	    plot, [0, 10], [0, 0.8], xtitle='T (K)', ytitle='P (pW)', /nodata,$			      			           
   	             linestyle = 0, Title= 'Channel:'+strtrim((*x[0]).ubolo_label[ichannel],2)+ $		           
             	     ', T_c='+strtrim(String(Tbath),2)+'mK, Chi_Square='+strtrim(String(chi_square),2)  	           
		
			           
               endif else begin
	      
	      	  if ( ifile eq 0 ) then begin      
              	  				      								           
	      	     plot, T, F, xtitle='T (K)', ytitle='P (pW)', $			      			           
             	     linestyle = 0, Title= 'Channel:'+strtrim((*x[0]).ubolo_label[ichannel],2)+ $		           
             	     ', T_c='+strtrim(String(Tbath),2)+'mK, Chi_Square='+strtrim(String(chi_square),2)  	           
		  									      			           
             	      ;oplot, T, P, psym=6, color=blo_color_get(ct[ifile MOD nct]), $		      		           
             	      ;symsize=0.05							      			           
             	      oplot, T, P, psym=7, color=blo_color_get(ct[ifile MOD nct]), $		      		           
             	      symsize=0.5							      			           
             	     												           
             	  									      			           
		  									      			           
              	  endif else begin							      			           
              	  									      			           
              	     ;plot the data points						      			           
             	      oplot, T, P, psym=7, color=blo_color_get(ct[ifile MOD nct]), $		      		           
             	      symsize=0.5							      			           
             	      ;oplot, T, P, psym=6, color=blo_color_get(ct[ifile MOD nct]), $		      		           
             	      ;symsize=0.05							      			           
             	  									      			           
              	     ;plot the calculated data									           
	     	     oplot, T, F, color=blo_color_get(ct[ifile MOD nct]), $		      			           
             	     linestyle = 0							      			           
             	  endelse								      			           
	     	  									      			           
              	  ;xyouts, T[1], F[n_elements(F) - 150], 'Chi_Square='+strtrim(String(Chi_Square),2), charsize=1.0          
	       endelse   
	endfor
     endif  
   endfor
   
 
END    
