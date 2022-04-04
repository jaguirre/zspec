;+
;===========================================================================
;  NAME: 
;		  bolodark_sh_timeevol
;
;  DESCRIPTION: 
;		  get times, temperatures and time sequence for 
; 		    loadcurve structure
;
;  USAGE: 
;		  bolodark_sh_timeevol, x, time, T_c, ix
;
;  INPUT:
;       x	  A pointer array to the structure			      
;   
;  OUTPUT:
;       time	  Adouble precision variable containing the time	      
;       T_c	  The double precision array containing the bath temperature  
;       ix	  The integer array containing the index of the time in       
;	          acending order					      
;   
;   KEYWORDS:	    
;		  none
;
;   AUTHOR: 
;		  B. Schulz
;
;   EDITION History
;
;   Date          Programmer     Remarks
;   2003/05/07	  B. Schulz      Initial Version
;
;===========================================================================
;-

pro bolodark_sh_timeevol, x, time, T_c, ix

nf = n_elements(x)

t_c = dblarr(nf)
time = dblarr(nf)

for ifile=0, nf-1 do begin

  t_c[ifile] = avg((*x[ifile]).T_c)

  t1 = (*x[ifile]).h_date_obs

  
  jtime=julday(fix(strmid(t1,5,2)),fix(strmid(t1,8,2)), $
               fix(strmid(t1,0,4)), double(strmid(t1,11,2)), $
	       double(strmid(t1,14,2)),double(strmid(t1,17,2)))

  ;print, (*x[ifile]).h_date_obs, jtime, T_c[ifile]
  
  time[ifile] = jtime
endfor

ix = sort(time)

end


