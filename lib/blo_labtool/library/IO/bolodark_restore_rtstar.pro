;+
;===========================================================================
;  NAME: 
;		  bolodark_restore_rtstar
;
;  DESCRIPTION: 
;		  Restire R_star and T_star from file
;
;  INPUT: 
;		  none
;
;  OUTPUT:
;    chan	  (string arr) channel name  
;    rstar	  (float arr) R_star	     
;    tstar	  (float arr) T_star	     
;
;  KEYWORD:
;    filename     A string of characters 
;
;  AUTHOR: 
;		  Bernhard Schulz
;
;  Edition History
;
;  Date	        Programmer    Remarks
;  2003-05-12   B. Schulz     initial test version
;
;
;===========================================================================
;-

pro bolodark_restore_rtstar, chan, rstar, tstar, path=path, filename=filename

if NOT keyword_set(path) then $
  path = '/data1/BoDAC/3_Pathfinder/20030402/'

if NOT keyword_set(filename) then $
  filename = 'RstarTstar20030319200402.txt'

readcol, /silent, path+filename, chan1, chan2, rstar, tstar, format='A, a, f,f'

chan = chan1 + ' ' + chan2

return
end
