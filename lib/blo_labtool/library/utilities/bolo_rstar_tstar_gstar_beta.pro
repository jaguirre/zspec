;+
;===========================================================================
; NAME: 
;		   bolo_rstar_tstar_gstar_beta
;
; DESCRIPTION: 
;		   This procedure will calculate the Rstar, Tstar, Gstar 
;		   and Beta 
;
; USAGE:
;		   bolo_rstar_tstar_gstar_beta, x, KeepRT, Rstar, Tstar,$
;		   Gstar, Beta
;
; INPUT:
;      x   	   A ponter array to the structure		        
;     Rstar	   A double precision one-dimension array containing    
;          	   the Rstar values				        
;     Tstar	   A double precision one-dimension array containing    
;          	   he Tstar values				        
;     Gstar	   A double precision one-dimension array containing    
;          	   the Gstar values (optional)			        
;     Beta 	   A double precision one-dimension array containing    
;                  the Beta values (optional)			        
;	
; KEYWORDS: 
;     KeepRT	   It works as a switch.  If set, the Rstar and Tstar will    
;           	   keep  unchanged during the curvefiting		      
;     plot  	   If set, the program will plot LnR vs P (in log unit)       
; OUTPUT:          							     
;       Rstar      A double precision one-dimension array containing  	      
;                  the Rstar  values					      
;       Tstar      A double precision one-dimension array containing 	      
;                  the Tstar values					      
;       Gstar      A double precision one-dimension array containing  	      
;                  the Gstar values					      
;       Beta       A double precision one-dimension array containing	      
;                  the Beta values					      
;
;  AUTHOR: 
;		   Lijun Zhang 
;
; ALTHORITHM    :  To use IDL curvefit function, we need to estimate the initial 
;                  parameters. We can get A0, A1 by Rstar0, and Tstar0 and let 
;                  beta0=1.0, Gstar0 can be estimated at the highest Power by 
;		   the formula
;                 
;                  G_star0=Pmax*(beta0+1.0)/[(LnRmax-LnR_star0)^(-0.5/(beta0+1))
;                                           *T_star0^(beta0+1) - T_c^(bata0+1)]
; 
; FORMULA USED  :
;                 a0=LnR_star0; a1=sqrt(T_star0); a3=beta0+1; a2=a3/G_star0
; VARIABLES USED:
;    Rstar0     : A double precision one-dimenstion array containing the initial
;                 Rstar values for all the channels
;                 
;    Tstar0     : A double precision one-dimenstion array containing the initial
;                 Tstar values for all the channels
;    Pmax       : The maximum power
;    LnRamx     : The LnR value corresponding to the Pmax
;    T_cmax     : The T_c value corresponding to the Pmax
;    weights    : A double precision one-dimension array of the same size as P. 
;                 It contains the weight factor for the curvefit function.
;    tol        : The tolerance for the curvefit
;    sigma      : A named variable that will contain a vector of standard 
;                 deviations for the elements of the output vector A.
;    itmax      : The maximum iteration 
;
;
; 
;  Edition History
;
;  Date         Programmer  Remarks					     
;  2003/07/30	L. Zhang    initial version				     
;  2003/07/31	B. Schulz   changed recognition of need of start parameters  
;
;===========================================================================
;-

 PRO bolo_rstar_tstar_gstar_beta, x, Rstar, Tstar, Gstar, Beta,  $
   KeepRT=KeepRT, plot=plot
 
    common share_block, T_c, KeepRT_On
    

    nchannel = n_elements((*x[0]).ubolo[*,0])

    ;initial values
    Rstar0=Rstar
    Tstar0=Tstar

    if n_elements(Gstar) EQ 0 OR n_elements(Beta) EQ 0 then begin
      Beta  = dblarr(nchannel)+1.d0	;default value for beta
      Gstar = dblarr(nchannel) 	        ;space for Gstar
      GstarBetaStartP = 0		;no start params for  Gstar and beta
    endif

    if (n_elements(Gstar) NE n_elements(R_star) AND Gstar[0] EQ 0) then  begin
      Beta  = dblarr(nchannel)+1.d0	;default value for beta
      Gstar = dblarr(nchannel) 	        ;space for Gstar
      GstarBetaStartP = 0		;no start params for  Gstar and beta
    endif else begin
      GstarBetaStartP = 1      ;flag you have start parameters for Gstar and beta
    endelse
    Beta0  = Beta
    Gstar0 = Gstar
    
    
    for channel=0, nchannel-1 do begin
        
        bolo_get_p_r_per_channel, x, channel, P, LnR, T_c
        Pmax = max(P, pmax_index)
        LnRmax = LnR[pmax_index]
        T_cmax = T_c[pmax_index]
        if NOT GstarBetaStartP then begin
            Gstar0[channel] =  Pmax*(beta0[channel]+1.0d0)/( $
              ( (LnRmax-alog(Rstar0[channel]))^(-2.0d0*(beta0[channel] $
                +1.0d0)))*Tstar0[channel]^(beta0[channel]+1.0d0) $
                - T_cmax^(beta0[channel]+1.0d0))
        endif
         
        tol =1.0d-6
        weights = replicate(1.0d0, n_elements(P))
        
        a0 = alog(Rstar0[channel])
        a1 = sqrt(Tstar0[channel])
        a3 = beta0[channel]+1.0d0
        a2 = a3/Gstar0[channel]
        
        if keyword_set(KeepRT) then begin
            KeepRT_On=1
            a = [a2, a3]
        endif else begin
            a = [a0, a1, a2, a3]
            KeepRT_On=0
        endelse
	
       
       result = curvefit(P, LnR, weights, a, sigma,  $
                   function_name ='bolodark_function',$
                   itmax         = 10000L            ,$
                   tol=1.0d-6                        ,$
                   /noderivative                     ,$
                   /double                            )
      
        ;check for fit problems
        ix = where(finite(sigma) NE 1, nancnt)      
        if nancnt GT 0 then message, /inform, 'Failed to converge!!'
        

        if keyword_set(KeepRT) then begin
            Rstar[channel]=Rstar0[channel]
            Tstar[channel]=Tstar0[channel]
            beta[channel]  = a[1]-1.0d0
            Gstar[channel] = a[1]/a[0]
        endif else begin
            Rstar[channel]=exp(a[0])
            Tstar[channel]=(a[1])^2
            beta[channel]  = a[3]-1.0d0
            Gstar[channel]= a[3]/a[2]
        endelse
         
        ;Rstar_sig = exp(sigma[0])
        ;Tstar_sig = (sigma[1])^2
        ;beta_sig  = sigma[3]-1.0d0
        ;Gstar_sig = sigma[3]/a[2]
        
    ENDFOR  
    
    if keyword_set(plot) then begin
       bolo_plot_lnR_vs_power, x,  Rstar, Tstar, Gstar, Beta
    endif
       
 END
;
;=============================================================================================
