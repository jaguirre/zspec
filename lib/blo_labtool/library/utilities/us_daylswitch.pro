;+
;===========================================================================
;  NAME: 
;		   us_daylswitch
;
;  DESCRIPTION: 
;		   Determine if 1hour must be subtracted from local time 
;	  	   in US to come to time with fixed offset w.r.t. UT
;
;  INPUT: 
;		   yr, mon, day, hr, min, sec
;
;  OUTPUT:  
;	offset 	   set to 1 if 1hour is to be subtracted from local time   
;		   during daylight savings interval			   
;
;  KEYWORD: 	   none
;
;  AUTHOR:	
;		   Bernhard Schulz
;
;  Example:
;	IDL> print, us_daylswitch(2002,10,27,2.9)
;	       1
;	IDL> print, us_daylswitch(2002,10,27,3.1)
;	       0
;
;  Remarks:
;	Rules obtained from Wolfram Research at
;	http://scienceworld.wolfram.com/astronomy/DaylightSavingTime.html
;
;  AUTHOR	: Bernhard Schulz
;
;
;  Edition History
;
;  Date         Programmer   Remarks
;  2002-12-10	B. Schulz    initial test version
;
;===========================================================================
;-

function us_daylswitch, yr, mon, day, hr


ds = $                 		;daylight savings time start/end
 [[2001, 4, 1, 10, 28], $
  [2002, 4, 7, 10, 27], $
  [2003, 4, 6, 10, 26], $
  [2004, 4, 4, 10, 31], $
  [2005, 4, 3, 10, 30]]


ix = where(ds[0,*] EQ yr, cnt)

if cnt EQ 1 then begin

  jdcnv,ds[0,ix],ds[1,ix],ds[2,ix],2., switchstart
  jdcnv,ds[0,ix],ds[3,ix],ds[4,ix],3., switchend
  jdcnv,yr,mon,day,hr, pstjuldate

  if pstjuldate[0] GT switchstart[0] AND pstjuldate[0] LT switchend[0] THEN $
  	output = 1 ELSE output = 0

endif else begin
  message, 'Date not within range!'
endelse

return, output
end
