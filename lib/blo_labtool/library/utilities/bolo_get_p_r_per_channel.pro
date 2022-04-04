;+
;===========================================================================
; NAME: 
;		 bolo_get_p_r_per_channel
;
; DESCRIPTION: 
;		 This procedure will read V_bolo(bolometer voltage), 
;		 R( resistance) and V_bias (bias voltage) 	  
;	         from the innput x (pointer array to the 	  
;	         structure, for sturcture defenition, please 	  
;	         see program bolodark_read_loadcrv.pro) 	  
;	         and then calculate P (Power) and Ln(R) values.   
;	         The procedure will append the P and Ln(R) from   
;	         all the files into one big array.		  
;
; USAGE: 
;		 bolo_get_p_r_per_channel, x, channel, P, R, Tc
; 
; INPUT:
;     x       	 A pointer array to a structure (The x is returned by      
;    	         bolodark_read_loadcrv  			         
;     channel	 an integer containing bolometer channel index           
;
;
; OUTPUT:
;     P       	  Adouble precision array containging all the P (power) data from      
;   		  all the files 						       
;     LnR	  A double precision array containging all the Ln(R)(R is resistance)  
;   		  data from all the files					       
;     Tc          A double precision array containging all the T_c		       
;   		  data from all the files					       
;
;   Note          files here mean the number of x elements.  Each x element is from    
;   		  one input file						       
;
;  KEYWORDS: 
;       Rload     Load resistance. If not set, use the default Rload=20e7
;
; AUTHOR: 
;	          L. Zhang
;              
;
;  Algorithm used
;             	       P = V_bolo * I_bolo		  
;             	       R = V_bolo / I_bolo		  
;             	       I_bolo= (V_bias - V_bolo)/(2*RL)   
;  where
;   P: bolometer power; R: bolometer resistance; V_bolo: bolometer voltage
;   I_bolo: bolometer current; RL: the load resistance
;
;  Variables used 
;       current       : The bolometer current
;       P_chan        : A double precision array containing the bolometer 
;		        power
;       R_chan        : A double precision array containing the bolomenter 
;		        resistance
;       LnR_chan      : A double precision array containing the Ln(R) values
; 
; 
; Edition History
; 
; Date		Author	      Remarks
; ---------- 	---------     --------------------------
; 2003-07-23	L. Zhang      Initial Version
; 2003-12-10    L. Zhang      Introduced Rload keyword 
;                             Extract the common part as
;                             bolo_get_p_r_per_file.pro
;                             so bolo_plot_lnr_vs_power.pro
;                             can use bolo_get_p_r_per_file    
;
;===========================================================================
;-

 PRO bolo_get_p_r_per_channel, x, channel, P, LnR,  Rload=Rload

     
    no_of_files = n_elements(x)

    for i=0, no_of_files-1 do begin            ;Start for loop         
       
        bolo_get_p_r_per_file, x, i, channel, P_chan, LnR_chan, $
	   Rload=Rload
      
         if ( i eq 0 ) then begin
            
            P=P_chan
            LnR=LnR_chan
        
	 endif else begin
            
            P=[P,P_chan]
            LnR=[LnR,LnR_chan]
         
	 endelse
  
    endfor                                     ;End for loop  
    
    return
    
 END
;
;===================================================================================
