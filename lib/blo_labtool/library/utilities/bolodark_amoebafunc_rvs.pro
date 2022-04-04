;+
;===========================================================================
;  NAME: 
;		  bolodark_amoebafunc_rvs		     	       
;
;  DESCRIPTION: 
;		  This function is called by curve fitting   	       
;                 amoeba calls  			     	       
;  INPUT:
;	a         a two-element array containing the initial 	       
;                 parameters				     	       
;
;  OUTPUT:
;		  A one dimension array containing the function values 
;
;  KEYWORD:
;		  none
;  Author: 
;		  B. Schulz
;  NOTE: 
;		  The returned funtion is 
;		  P = G_0 * T_0^(-beta)*(T^(beta+1)-T_c^(beta+1))/(beta+1)
;		  wherewith T_0 = 0.3 K 
;		
;  12/4/2003    : B. Schulz and L. Zhang
;               : Using fixed 300mK for T0
;  2003/12/09   : L. Zhang 
;                 Remove the commented codes.  Now the formula we use
;                 is G=G0*(T/T0)^beta
;                 F=G0/(T0)^beta*(T^(beta+1)-T_c^(beta+1))/(beta+1)
;==========================================================================
;-
function bolodark_amoebafunc_rvs, a

     common amoeb, T, P, Tc
    

     bx = 0.3^(-(a[1]-1.d)) * ((T)^a[1]-(Tc)^a[1]) / a[1]
     F = total((a[0] * bx - P)^2)
    
return, F
end
