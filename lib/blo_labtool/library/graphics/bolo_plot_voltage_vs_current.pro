;+
;=============================================================================================
;
; NAME: 
;		  bolo_plot_voltage_vs_current.pro
; DESCRIPTION: 
;		  This procedure will plot voltage vs current where the 
;
; USAGE:
;	          bolo_plot_voltage_vs_current, x,  Rstar, Tstar, Gstar, $
;	          Beta, Rload=Rload, T_c=T_c
; 
; INPUT:
;    Rstar	  A double precision one-dimension array containing the Rstar   	    
;    Tstar	  A double precision one-dimension array containing Tstar        
;    Gstar	  A double precision on-dimension array containing Gstar         
;    Beta	  A double precision on-dimension array containing Beta          
;    x   	  Array of structure containing the loadcurve data	         
;
; OUTPUT:
;                 Voltage vs Current plots
;
; AUTHOR:
;		  Lijun Zhang
;           
; Edition history
; 12/15/03       Initial test version
; 
;---------------------------------------------------------------------------------------------
;-

PRO bolo_plot_voltage_vs_current, x,  Rstar, Tstar, Gstar, Beta, Rload=Rload, T_c=T_c
   
    no_of_files = n_elements(x)

    ct = get_13colortable( )
    nct = n_elements(ct)
    nchannel = n_elements((*x[0]).ubolo[*,0])
    for i=0, nchannel-1 do begin
      if Rstar[i] GT 0 and Tstar[i] GT 0 and Gstar[i] GT 0 and Beta[i] GT 0 $
      	then begin      
      
        for j=0, no_of_files-1 do begin            ;Start for loop 
                
		no_data=0
		
	        if Not Keyword_set(T_c) then begin
		    T_c=mean((*x[j]).T_c, /double)
		endif
	   	Tbath=fix(T_c*1000)
		
                ubias = reform((*x[j]).ubias)
                ubolo = reform((*x[j]).ubolo[i, *])
   	      
	        if keyword_set(Rload) then $
   	            bolodark_ipbolo, ubolo, ubias, uboloc, ibias, RLC=Rload[i]  $
   	        else $
   	            bolodark_ipbolo, ubolo, ubias, uboloc, ibias      
   	        ubolo=uboloc
	
                
	        ;calcualte Power P and Resistance R
                R = abs ( ubolo/ ibias ) 
                LnR = alog(R) 
		
	         
               ;calculate P using the fitting parameters
                a0=Gstar[i]                         
                a1=Beta[i]+1.d0                     
                T=Tstar[i]/( LnR - alog(Rstar[i]))^2
               
	       
	        P=a0*(0.3d)^(-Beta[i])*( T^a1 - T_c^a1 )/a1  
		
		
                ix  = where(finite(T) eq 1 AND P GT 1e-17  AND R gt 0, cnt) 
		
		if (cnt gt 1) then begin 
                   P=P[ix]
                   R=R[ix]
		   ubolo=ubolo[ix]
		   ibias=ibias[ix]
		endif else begin
        	    error_msg='no valid data in channel '+ $
		    strtrim(String(i), 2)+':'+(*x[j]).ubolo_label[i]
                    message, error_msg, /continue
		    no_data=1
		endelse
		
		   
		Voltage=sqrt( P*R)
                Current=sqrt(P/R)
		
		;chi_square=total( (Voltage-ubolo)^2, /double)/(1.d*n_elements(ubolo))
	        chi_square=total( (Voltage-ubolo)^2/Voltage, /double)/(1.d*n_elements(ubolo))
	       
		;Only plot the same range as ibias
		max_ibias=max(ibias, imax, /NAN)
           	
		ix = where( finite(current) eq 1 and current le max_ibias, cnt)
		if (cnt gt 1) then begin
		    Current=Current[ix]
		    Voltage=Voltage[ix]
		endif else begin
	           error_msg='No valid points in channe1 ' + $
		   strtrim(String(i), 2)+':'+(*x(j)).ubolo_label[i]
	           message, error_msg, /continue
	           no_data=1
		endelse 
		 
		
		ix=where(ubolo ge 0, cnt)
		if (cnt gt 1) then begin
		    ubolo=ubolo[ix]
		    ibias=ibias[ix]
		endif else begin
	           error_msg='No valid points in channe1 ' + $
		   strtrim(String(i), 2)+':'+(*x(j)).ubolo_label[i]
	           message, error_msg, /continue
		   no_data=1
		endelse
		
			       
	       ;Sort the data and change the units
	        ix=sort(Current)
	        Current=Current[ix]*1e9
	        Voltage=Voltage[ix]*1000

		ix=sort(ibias)
                ubolo=ubolo[ix]*1000
		ibias=ibias[ix]*1e9
		
		
		no_of_points_voltage=n_elements(Voltage)
		no_of_points_ubolo=n_elements(ubolo)
		
		no_of_points=min([no_of_points_voltage,no_of_points_ubolo])
		
		if (no_of_points le 1 or no_data eq 1) then begin 
		
		      plot, [0, 10], [0, 0.1], /nodata, xtitle='Current (nA)', ytitle='Voltage (mV)', $
	 	       linestyle = 0, Title= 'Channel:'+strtrim((*x[0]).ubolo_label[i],2)+ $
		       ', T_c='+strtrim(String(Tbath), 2)+'mK, Chi_Square='+strtrim(String(chi_square),2)

		
		endif else begin 
	
                     if ( j eq 0 ) then begin
	            	 ;plot the calcuated data
		    	 plot, Current, Voltage, xtitle='Current (nA)', ytitle='Voltage (mV)', $
	            	 linestyle = 0, Title= 'Channel:'+strtrim((*x[0]).ubolo_label[i],2)+ $
		    	 ', T_c='+strtrim(String(Tbath), 2)+'mK, Chi_Square='+strtrim(String(chi_square),2)
		    	 
                    	 ;plot the data points
		    	 oplot, ibias, ubolo, psym=7, color=blo_color_get(ct[j MOD nct]), $
                    	 symsize=0.5
 	       
                    endif else begin
                     
		    	;plot the calcuated data
                    	 oplot, Current, Voltage, color=blo_color_get(ct[j MOD nct]), $
                    	 linestyle = 0
		    	
		    			
                    	;plot the data points
                    	 oplot, ibias, ubolo, psym=7, color=blo_color_get(ct[j MOD nct]), $
                    	 symsize=0.5

   	             endelse
		     
               endelse
	       
	endfor	
	
     endif

   endfor
   
 
END    
