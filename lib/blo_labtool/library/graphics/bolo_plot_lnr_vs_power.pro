;+
;=============================================================================================
;
; NAME: 
;		  bolo_plot_lnr_vs_power
;
; DESCRIPTION: 
;		  This procedure will plot LnR vs Power where the LnR is calculated
;                 using the parameters a=[a0,a1,a2,a3] returned by curvefit function.
; 
; USAGE: 
;		  bolo_plot_lnr_vs_power,a, p, path, filename
; 
; INPUT:
;    Rstar	  A double precision one-dimension array containing the Rstar		    
;    Tstar	  A double precision one-dimension array containing Tstar		    
;    Gstar	  A double precision on-dimension array containing Gstar		    
;    Beta	  A double precision on-dimension array containing Beta 		    
;    x   	  Array of structure containing the loadcurve data			    
;
;  OUTPUT:
;      		  LnR vs LnP plots							    
;   
;  KEYWORDS:
;    T_c          If specifed, this T_c will be used, otherwise, the T_c will 		    
;                 be read in from X data structure					    
;    Rload        If specified, the specified load resistance will be used,		    
;                 otherwise, the deafult RL=2.0e7 will be used(two 1 Mhoms resistances)     
;    T0           If specifed, use definition of G as G(T)=G0*exp(T/T0)^(beta)		    
;                 otherwise, G(T)= Gstar*T^(beta)					    
;    
;   AUTHOR: 
;		  Lijun Zhang
;
;   Edition history
; 
;   Date         Programmer	Remarks    
;   2003-07-20	 L. Zhang       initial version
;   2003-09-15	 L. Zhang       add two keyword to make plot for two other 
;				algorthims T0=T0 for algorithm:
;          	                G(t)=G0(T/T0)^(beta) and G(T)=dP/dT
;   2003-09-18 	 B. Schulz      some formatting and typo corrected
;   2003-12-09   L. Zhang       Use the same T_c as in the bolo_get_tptc
;   2003-12-10   L. Zhang       Restructure the program to use a new
;                               procedure, bolo_get_p_r_per_file
;                               
;                               Fixed bug on calling bolo_get_p_r_per_channel
;   2004-06-08 	 B. Schulz      protect against bad pixels
;                               
;---------------------------------------------------------------------------
;-

 PRO bolo_plot_lnr_vs_power, x,  Rstar, Tstar, Gstar, Beta,T0=T0,Rload=Rload, T_c=T_c
               

    no_of_files = n_elements(x)

    ct = get_13colortable( )
    nct = n_elements(ct)
    nchannel = n_elements((*x[0]).ubolo[*,0])
    
     for ichannel=0, nchannel-1 do begin

        bolo_get_p_r_per_channel, x, ichannel, P, LnR, Rload=Rload
        Pmin=min(P)                                            
        Pmax=max(P) 
	                                         
        LnRmin=min(LnR)                                     
        LnRmax=max( LnR) 
	if Pmin EQ Pmax OR LnRmin EQ LnRmax then begin
        endif else begin
        
	plot, /nodata, [Pmin, Pmax], [LnRmin, LnRmax],  xstyle=1, ystyle=1 , $       
                       xtitle='LnP [W]',                                       $ 
                       Ytitle='LnR [ln ohms]'  , /xlog,                      $
                       title = (*x[0]).ubolo_label[ichannel], xthick=2,             $
                       ythick=2, charsize=1.6
        P=P(sort(P))											       
        ix=where(P gt Pmin)										       
        xp=P[ix[0]]											       
        xpos=[xp, xp, xp, xp, xp]										       
        ypos=[LnRmax-0.15, LnRmax-0.3,  LnRmax-0.45, LnRmax-0.6]						       
       	yp=LnRmax-0.75
        	      ;
        xyouts, xpos, ypos, ['Rstar='+strtrim(string(Rstar[ichannel]), 2),$					      ;
          'Tstar='+strtrim(string(Tstar[ichannel]), 2), 'Gstar='+strtrim(string(Gstar[ichannel]), 2),$		       
          'Beta='+strtrim(string(Beta[ichannel]), 2) ], charsize=0.8 					       
		
	      
	for ifile=0, no_of_files-1 do begin            ;Start for loop 
	
	        if not Keyword_set(T_c) then begin
	              T_c=mean((*x[ifile]).T_c, /double)
	        endif 
                T=fix(T_c*1000)
               
	        bolo_get_p_r_per_file, x, ifile,ichannel, P, LnR, Rload=Rload
	        
               
	        a0=alog(Rstar[ichannel])
                a1=sqrt(Tstar[ichannel])
                a3=Beta[ichannel]+1.d0
                a2=a3/Gstar[ichannel]
                if keyword_set(T0) then begin		; using d G(T) = G0 * (T/T0)^(beta)
                     F=a0+ a1*(a2*0.3^(Beta[ichannel])*P+T_c^(a3))^(-0.5/a3) 
                
		endif else begin 			; using G(T) = Gstar*T^(beta)
                     F = a0 + a1*(a2*P+T_c^(a3))^(-0.5d0/a3)
                endelse
		
		;chi_square=total( (LnR-F)^2, /double)/(1.d*n_elements(F))
		chi_square=total( (LnR-F)^2/F, /double)/(1.d*n_elements(F))
		

		;plot the testing data
                oplot, P, LnR,  psym=7, color=blo_color_get(ct[ifile MOD nct]), $
                symsize=0.4
                
		;plot the calculated data
               
                oplot,P , F, color=blo_color_get(ct[ifile MOD nct]), $
                linestyle = 0
		 
		xyouts, xp, yp, 'T ='+ strtrim(String(T), 2)+' mK', charsize=0.8
		xyouts, xp, yp-0.1, 'Chi_Square='+strtrim(String(chi_square),2), charsize=0.8
	endfor	
	
        endelse
   endfor
   
 
END    
