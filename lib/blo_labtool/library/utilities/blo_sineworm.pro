;+
;===========================================================================
;  NAME: 
;		   BLO_SINEWORM
;
;
;  DESCRIPTION:    
;		   Derive flagarray separating upper and lower
;  		   sinewave from switched double sinewave
;
;  USAGE: 
;		   blo_sineworm, time, signal, swflag, ngroup, flg
;
;  INPUT:
;    time	  (array float) time				    
;    signal	  (array float) sine signal			    
;    swflag  	  (array int) flagarray, where > 0 possible switch  
;    ngroup  	  (int) typical number of datapoints in group	    
;
;  OUTPUT:
;    flg          (array int) flagarray,   1 = first sine wave	    
;		  			   2 = second sine wave
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  Edition History:
;   
;  Date		Author	    Remarks 
;  04/10/2002   B.Schulz    initial test version    	       
;
;
;===========================================================================
;-

pro blo_sineworm, time, signal, swflag, ngroup, flg

nsig = n_elements(signal)

flg = fix(signal)		;output flags
lastswitch = -1
lastvalid = 1
flg(0) = 1			;first point always ok
dt = time(1)-time(0)	;sampling interval
forceflag = 0

for i=0, nsig-2 do begin

  swdet = 0
  if swflag(i+1) NE 0 then begin			;switch possible?

    if lastswitch LT 0 then begin			;first?
      swdet = 1
    endif else begin
      if i-lastswitch $
      		GT ngroup-1 then begin		;correct position ?
        swdet = 1
      endif
    endelse

  endif else begin						;no switch detected

    if i-lastswitch GT ngroup  then begin ;missed one?
      ;swdet = 1

      ;if forceflag EQ 1 then begin
        forceflag = 0
        swdet = 2
      ;endif else forceflag = 1
    endif

  endelse

  if swdet GT 0 then begin
    lastswitch = i					;set # last switch
    lastvalid = -lastvalid 			; flag invalid
    if swdet EQ 2 then begin
      lastswitch = i-1
      flg(i) = lastvalid			;revise last flag
    endif
  endif

  flg(i+1) = lastvalid

  ;print, time(i), signal(i), swflag(i), swdet, flg(i), i,lastswitch, lastvalid
  ;c = get_kbrd(1)

endfor

end
