;+
;===========================================================================
;  NAME: 
;		  bolodark_lcsymm_get
;
;  DESCRIPTION:   
;  
;  USAGE: 
;		  r = bolodark_lcsymm_get( ubias, ubolo )
;
;  INPUT:
;      ubibas     A double precision array containing the bias voltage	     
;      ubolo	  A double precision array containing the bolometer voltage  
;  
;  OUTPUT: 
; 
;  KEYWORD: 
;		  NONE
; 
;  AUTHOR:
;		  Bernhard Schulz
;===========================================================================
;-

function bolodark_lcsymm_get, ubias, ubolo

common lcsymm, ubias0, ubolo0


ubias0 = ubias
ubolo0 = ubolo

r = amoeba(1.0e-5, scale=0.0002, p0 = -0.0001, nmax = 100, function_name='bolodark_lcsymmfnc', $
		function_value=fval)

if r EQ -1 then begin
  message, /info, 'Amoeba not converged!'
  return, 0.0
endif

if abs(bolodark_lcsymm(ubias0, ubolo0, r)) GT   $
   abs(bolodark_lcsymm(ubias0, ubolo0, 0.0)) then begin
   message, /info, 'Bias offset rejected!'
endif else begin
  return, r[0]
endelse

end
