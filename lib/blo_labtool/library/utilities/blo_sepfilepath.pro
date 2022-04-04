;+
;=====================================================================
;  NAME: 
;		  blo_sepfilepath
; 
;  DESCRIPTION: 
;		  Separate filename in path and name
;
;  USAGE: 
;		  blo_sepfilepath, filename, name, path
;
;  INPUT:	
;    filename	  (string)     
;
;  OUTPUT:    
;    name	  (string)     
;    path	  (string)     
;
;  KEYWORDS: 
;		   none
;
;  Edition History:
;
;  Date		Author	    Remarks
;  2002-09-13 	B. Schulz   initial test version
;
;=====================================================================
;-

pro blo_sepfilepath, filename, name, path

pieces = strsplit(filename, '/\')

n = n_elements(pieces)

path = strmid(filename, 0, pieces(n-1))
name = strmid(filename, pieces(n-1))

return
end
