;+
;===========================================================================
;  NAME: 
;		   blo_tabstrcat.pro
;
;  DESCRIPTION: 
;		   Concatenate string array to tab separated single string
;
;  USAGE: 
;		   str = blo_tabstrcat(strarr)
;
;  INPUT:
;    infile 	   (strarr) array of strings to concatenate
;
;  OUTPUT:
;    function      string, with items separated by tab characters
;
;  KEYWORDS: 
;		   none    
;
;
;  Example:
;  IDL> a=['one','two','three']
;  IDL> help, blo_tabstrcat(a)
;  <Expression>    STRING    = 'one        two     three'
;  IDL>
 
;  
;  Author: Bernhard Schulz                                                                           
; 
;  History:
;  Date		Author		Remarks
;  2003/01/31   B. Schulz       initial test version
;
;=================================================================
;-


function blo_tabstrcat, strchain

n=n_elements(strchain)


str = strchain[0]

if n GT 0 then for i=1, n-1 do str = str+string(9b)+strchain[i]

return, str

end
