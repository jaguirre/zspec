;+
;===========================================================================
; NAME: 
;		    bolo_get_tptc
;
; DESCRIPTION: 
;		    Extract bolometer temperature T and electrical power 
;		    from x-structure

; USAGE: 
;		    bolo_get_tptc, x, channel, ifile, Rstar, Tstar, T, P, $
;		    Rload=Rload
;
; 
; INPUT:
;    x      	    A pointer array to a structure (The x is returned by    	   
;    	     	    bolodark_read_loadcrv)				 	   
;    channel	    An integer containing bolometer channel index	 	   
;    ifile  	    index of load curve in x-structure  		 	   
;    Rstar  	    [array double] Rstar parameters for all channels		   
;    Tstar  	    [array double] Tstar parameters for all channels		   
;
; OUTPUT:
;    P       	    A double precision array containing the power data for given 	 
;		    channel and loadcurve	    					 
;    T      	    A double precision array containing the bolometer temperatures 	 
;		    for given channel and loadcurve   					 
;     
; KEYWORD: 
;    Rload	    Double precision array containing the load resistances. 		 
;		    If set, the Rload will be used. Otherwise, the default, 		 
;		    2.0e7 will be used							 
;   	      	    											   
;
;    Note           The index ifile designates one loadcurve as it is stored in  
;		    the x-structure. One loadcurve is usually taken at a given   
;		    temperature and recorded in one data file.			 
;
;
;  AUTHOR: 
;		    Bernhard Schulz
;
;  Edition History
;
;  Date		Programmer   Remarks
;  2003/09/22   B. Schulz    Initial version extracted fropm 
;			     bolo_get_p_r_per_channel.pro
;  2003/10/14	L. Zhang     Add T_c key word
;  2003/12/09   L. Zhang     Remove the minimum T_c=Mim(T), use constant T_c
;                            If T_c set, use T_c value otherwise using average
;                            bath temperature from the file: 
;				T_c=mean(x[ifile].T_c)
;                            finally: T_c code removed
;  2004/04/24   B. Schulz    Clean up of header, in particular references to T_c
;===========================================================================
;-
PRO bolo_get_tptc, x, channel, ifile, Rstar, Tstar, T, P, Rload=Rload

    ubias = reform((*x[ifile]).ubias)                                                   
    ubolo = reform((*x[ifile]).ubolo[channel, *])                                       
    
    if keyword_set(Rload) then $
        bolodark_ipbolo, ubolo, ubias, uboloc, ibias, RLC=Rload[channel]  $
    else $
        bolodark_ipbolo, ubolo, ubias, uboloc, ibias      
    
    ubolo=uboloc
    R_chan=abs(ubolo/ibias)
    P_chan=abs(ubolo*ibias)
  
    LnR=alog(R_chan)
    
    LnRstar = alog(Rstar[channel])
    
    T_chan = Tstar[channel]/(LnR - LnRstar)^2
   
    ix  = where(finite(T_chan) eq 1 AND P_chan GT 1e-17, cnt ) 
   
    if (cnt gt 1 ) then begin 
       T   = T_chan[ix]
       P   = P_chan[ix]  
    endif  else begin
        error_msg='no valid data in channel'+ $
	 strtrim(String(channel), 2)+':'+(*x[ifile]).ubolo_label[channel]
        message, error_msg
	
    endelse 
    
END
