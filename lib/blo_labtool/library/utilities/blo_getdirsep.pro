;+
;=================================================================
;  NAME: 
;		 blo_getdirsep.pro
;
;  DESCRIPTION: 
;	 	return directory separator of operating system
;
;  USAGE: 
;		 sep = blo_getdirsep()
;
;  INPUT: 
;		 none
;
;  OUTPUT:
;     function   character containing '/' id Unix flavor 
;
;  KEYWORDS: 
;		 none	 
;
;                         or '\' if MS-Windows
;
;  Example:
;  IDL> a=['one','two','three']
;  IDL> help, blo_tabstrcat(a)
;  <Expression>    STRING    = 'one        two     three'
;  IDL>
 
;  
;  AUTHOR	: Bernhard Schulz                                                                           
; 
;  Edition History:
;
;  Date		Programmer   Remark
;  ----------   ---------    -----------------------
;  2003/01/31 	B. Schulz    initial test version
;
;=================================================================
;-


function blo_getdirsep

if strlowcase(!version.os_family) EQ 'unix' then str = '/' $
else str = '\'
return, str

end
