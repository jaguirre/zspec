;+
;===========================================================================
; NAME: 
;		  bolo_get_p_t_per_channel
; 
; DESCRIPTION: 
;		  This procedure will read ubolo(bolometer voltage), 
;		  R( resistance) and ubias (bias voltage) from the innput x   
;                 (pointer array to the structure, for sturcture defenition,  
;                 please see program bolodark_read_loadcrv.pro) and then      
;                 calculate P (Power) and Ln(R) values. 		      
;                 The procedure will append the P and Ln(R) from all the      
;		  files into one big array.				      
; 
; USAGE: 
;		  bolo_get_p_t_per_channel, x, channel, P, R, Tc
; 
; INPUT:
;     x      	  A pointer array to a structure (The x is returned by      
;    	          bolodark_read_loadcrv 				  
;     channel	  An integer containing bolometer channel index 	  
; 
;
; OUTPUT:
;     P       	  Adouble precision array containging all the P (power) data from   	   
;    		  all the files 					            	   
;     T           A double precision array containging all the bolometer temperature	   
;    	         								     
;
;  KEYWORD: 
;    Rload	  A double precision array containing the resistance of the bolometer.     
;		  If set, the Rload is used, otherwise the deafult Rload=2.0e7 is used     
;    T_c	  If set, the bath temperature from the measurement will be used.	   
;		  Otherwise, the T_c=min(T) will be used				   
;
;  AUTHOR: 
;		  Lijun Zhang
;
;  Algorithm used:
;                 P = ubolo * ibias
;                 R = ubolo / ibias
;                 ibias= (ubias - ubolo)/Rload
;  Note          Files here mean the number of x elements.  Each x element is from
;	  	 one input file
 
;  Edition History
;  Date		Author		Remarks
;  2003/09/12  	L. Zhang   	Initial version 
;  2003/09/22  	B. Schulz  	replaced parts by bolo_get_tptc.pro
;  2003/10/14	L. Zhang	T_c keyword added
;=============================================================================================
;-
 
PRO bolo_get_p_t_per_channel, x,  channel, Rstar, Tstar,  P, T, Tc, Rload=Rload, T_c=T_c
   
     
nfiles=n_elements(x)                                                              
for i=0, nfiles-1 do begin
    
    if keyword_set(Rload) then begin  
        bolo_get_tptc, x, channel, i, Rstar, Tstar, T_chan, P_chan, Rload=Rload
    endif else begin
        bolo_get_tptc, x, channel, i, Rstar, Tstar, T_chan, P_chan
    endelse                                                                                                                                                                   

    if Not keyword_set(T_c) then begin 
         T_c = mean((*x[i]).T_c,/double)
    endif 
   
    
    Tc_chan=replicate(T_c, n_elements(T_chan)) ;make Tc a same size array as T_chan
    
 
    if (i eq 0 ) then begin	     						   
       Tc=Tc_chan		     						   
       T=T_chan 		     						   
       P=P_chan 		     						   
    endif else begin		     						   
       Tc=[Tc, Tc_chan] 	     						   
       T=[T, T_chan]		     						   
       P=[P, P_chan]		     						   
    endelse			     						   
                                                                                   
endfor                                                                             
  
END

