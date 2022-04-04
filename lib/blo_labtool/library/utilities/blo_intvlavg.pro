;+
;========================================================================
;  NAME: 
;		  blo_intvlavg
; 
;  DESCRIPTION:   
;		  determine averages and standard deviations for a series of
;	          intervals in a dataset
;
;  USAGE: 
;		  avgs = blo_intvlavg(datax, datay, intervals)
;
;  INPUT: 
;     datax	 (float array) y-axis values (voltage.. etc.)		       
;     datay	 (float array) intervals for averaging  		       
;     intervals   array has structure [0:1,0:nintvl], where first index         
;		 determines 0: from value, 1: to value, and		       
;		 second index determines the interval			       
;       	 							       
;
;  OUTPUT:   
;    avgs	 (float array) averages and standard deviations for	       
;    		 all intervals specified				       
;    		 array has structure [0:2,0:nintvl],where first index	       
;    		 determines 0: average of datax, 1: average of datay,	       
;    		 2: standard deviation of datay 			       
;    		 and the second index determines the interval		       
;
;
;  KEYWORDS: 
;		  none
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
; 
;  Edition History:
;
;  Date    	Programmer 	Remarks
;  ---------- 	---------- 	--------------------
;  2003-08-07 	B. Schulz  	initial version
;
;========================================================================
;-
function blo_intvlavg, datax, datay, intervals

nintvls = n_elements(intervals[0,*])

avgs=fltarr(3,nintvls)


for i=0, nintvls-1 do begin

 ix1 = where(datax GT intervals[0,i] and datax LT intervals[1,i], cnt) 
 
 if cnt GT 0 then begin
   avgs[0,i] = avg(datax[ix1])
   avgs[1,i] = avg(datay[ix1])
   avgs[2,i] = stdev(datay[ix1])
 endif else begin
   avgs[0,i] = !VALUES.F_NAN
   avgs[1,i] = !VALUES.F_NAN
   avgs[2,i] = !VALUES.F_NAN
endelse

endfor

return, avgs

end
