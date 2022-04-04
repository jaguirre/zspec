;+                                                                                                   
;=========================================================================
;  NAME: 
;		  bolo_get_g_beta
;
;  DESCRIPTION: 
;	          This procedure will calculate the G0 and Beta value
;	          by fitting P vs T						        
; 
;  INPUT: 
;    x 		  A pointer array to astructure 				        
;    Rstar	  A string array containing the Rstars  ( R = Rstar*exp(sqrt(Tstar/T))  
;    Tstar	  A string array containing the Tstars				        
; 
;  OUTPUT: 	
;    G0           A double array containing the G0 values			        
;    Beta         A double array containing the Beta values			        
; 
;  KEYWORD:	
;    plot	 If set, the program will plot LnR vs LnP 			        
;    Rload	 If set, the program will use the load resistances Rload	        
;	         otherwise the default load resisitance will be used
;    T_c          If set, the calculation and plot are done with the bath temperature    
;                 from the x data structure.  If not, T_c=min(T) is used	        
; 
;  AUTHOR: 
;		 L. Zhang
;
;  Edition History
;
;  Date		Author	      Remarks
;  --------     -----------   -----------------     
;  2003/09/12	L. Zhang      Initial Test version
;  2003/10/14   L. Zhang      T_c keyword added
;=========================================================================
;-

PRO bolo_get_g_beta, x, Rstar,Tstar, G0, Beta, Rload=Rload, $
   T_c=T_c
   
  common amoeb, T, P, Tc
 
  nchannel = n_elements((*x[0]).ubolo_label)  
  
  ;Initial guess parameters
  G0=dblarr(nchannel) + 4e-11	
  Beta=dblarr(nchannel)+1.50d0
  for channel=0, nchannel-1 do begin

     if Rstar[channel] LE 0. then begin
	G0[channel]=0.
   	Beta[channel]=0.
	message, /info, "Channel "+string(channel)+" bad!"
     endif else begin
      
	if keyword_set(Rload) then begin
	     if keyword_set(T_c) then begin
	      	 bolo_get_p_t_per_channel, x,  channel, Rstar, Tstar,  P, T, Tc,$
		 Rload=Rload,  T_c=T_c
	     endif else begin
	         bolo_get_p_t_per_channel, x,  channel, Rstar, Tstar, P, T, Tc, Rload=Rload
   	     endelse 
	endif else begin
	     if keyword_set(T_c) then begin 
                 bolo_get_p_t_per_channel, x,  channel, Rstar, Tstar,  P, T, Tc, T_c=T_c
             endif else begin
	         bolo_get_p_t_per_channel, x,  channel, Rstar, Tstar,  P, T, Tc
	    endelse
	endelse
	 
        a0 = G0[channel]						      
        a1=Beta[channel]+1.d0				    		      
         								      
        a = [a0, a1]					    		      
       
      
        R = AMOEBA(1.0e-5, SCALE=[1e-10,100.], P0 = a, FUNCTION_VALUE=fval, $ 
	       function_name='bolodark_amoebafunc_rvs') 		      
        if n_elements(r) EQ 2 then a = r				      
                  
        G0[channel]=a[0]	   
        Beta[channel]=a[1]-1.d0

      endelse
      
  endfor
      
      
     
 END 
       
        
        
