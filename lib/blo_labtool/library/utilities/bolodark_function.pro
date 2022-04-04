;+
;===========================================================================
;
; NAME: 
;		   bolodark_function
;
; DESCRIPTION: 
;		   This procedure is used for curvefit and is called by 
;		   curvefit.
;
; USAGE: 
;		   As a curvefit argument
;
; INPUT:
;     p  	   A double precision array containing the power data		  
;     a  	   An one dimension array containing  the initial		  
;   	 	   parameters							  
;     T_c	   A double precision array containing the temperature  	  
;		   data T_c from all the channels 				  
;                 				       
;     KeepRT_On    When the KeepRT switch is set, the KeepRT_On=1. Then a only	  
;    	           contains two elements otherwise a contains 4 elements	  
;
;  OUTPUT:
;      f           A double precision array containg the data points of 	  
;		   the fomula							  
;      Note        The procedure used shared block to get the T_c values	  
;
;  KEYWORD: 
;		   NONE  
;
;  AUTHOR: 
;		   Lijun Zhang
;  
;  Edition History
;
;  Date		Programmer   Remarks
;  2003-07-31	L. Zhang     Initial test version
;===========================================================================
;-


 PRO bolodark_function, p, a,  f
    
    common share_block, T_c, KeepRT_On
    
    if( keepRT_On ) then  f=(a[0]*P+T_c^(a[1]))^(-0.5d0/a[1]) $
    
    else f = a[0] + a[1]*(a[2]*P+T_c^(a[3]))^(-0.5d0/a[3])
   
    return
    
 END
;
;===================================================================================
