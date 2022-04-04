;+
;===========================================================================
; NAME: 
;		  bolo_get_p_r_per_file
; 
; DESCRIPTION: 
;		  This procedure will read ubolo(bolometer voltage), 
;		  R( resistance) and ubias (bias voltage) 	   
;                 from the innput x (pointer array to the 	   
;                 structure, for sturcture defenition, please 	   
; 		  see program bolodark_read_loadcrv.pro) 	   
;                 and then calculate P (Power) and Ln(R) values.   
;                 The procedure will append the P and Ln(R) from   
;		  all the files into one big array.		   
;
; USAGE: 
;		  bolo_get_p_r_per_file, x, channel, P, R, Tc
; 
; INPUT:
;     x       	  A pointer array to a structure (The x is returned by      
;    	          bolodark_read_loadcrv 			          
;     channel     an integer containing bolometer channel index           
;
;
; OUTPUT:
;     P       	  Adouble precision array containging all the P (power)        
;   		  data from one file					 		      
;     LnR         A double precision array containging all the Ln(R)  	  
;   		  (R is resistance) data from one file  		 		      
;
;
;  KEYWORD: 
;    Rload 	  If not set, use the default Rload
;
; AUTHOR: 
;		  L. Zhang
; 
; Edition History
; 
; Date		Author	      Remarks
; ---------- 	---------     --------------------------
; 2003-12-10	L. Zhang      Initial Version
;===========================================================================
;-


 PRO bolo_get_p_r_per_file, x, ifile, channel, P, LnR, Rload=Rload

        ubias = reform((*x[ifile]).ubias)
        ubolo = reform((*x[ifile]).ubolo[channel, *])

        ;Find the zeropoint and remove the offset
        if keyword_set(Rload) then $
              bolodark_ipbolo, ubolo, ubias, uboloc, ibias, RLC=Rload[channel]  $
        else $
              bolodark_ipbolo, ubolo, ubias, uboloc, ibias      
        ubolo=uboloc
 
        ;calculate Power P and Resistance R
        P = abs ( ubolo * ibias )
        R = abs ( ubolo/ ibias ) 
	LnR = alog(R) 
  END     
