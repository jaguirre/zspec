;+
;=================================================================
;  NAME: 
;		   blo_coor2data
; 
;  DESCRIPTION:    
;		   Convert diagonal corner coordinates of rectangle 
;		   from device to data coordinates and exchange 
;		   so that x1 < x2 and y1 < Y2				    
; 
;
;  USAGE: 
;		   blo_coor2data, a, b, x, y
;
;  INPUT: 
;	 a	   x 2-el.-Vector in device coord.  
;        b	   y 2-el.-Vector in device coord.  
;
;  OUTPUT:
;	 x	   x 2-el.-Vector in data coord.    
;        y	   y 2-el.-Vector in data coord.    
;
;  AUTHOR: 
;		   Bernhard Schulz (IPAC)
;
;
;  Edition History:
;
;  08/28/2002	separated out from blo_labtool	B.Schulz
;
;---------------------------------------------------------
;-


pro blo_coor2data, a, b, x, y

dc = convert_coord([a(0),a(1)], $
		   [b(0),b(1)], $
		/device, /to_data)
	
;reverse order of cornerpoints if necessary

if dc(0,0) GT dc(0,1) THEN dc(0,*) = dc(0,[1,0])
if dc(1,0) GT dc(1,1) THEN dc(1,*) = dc(1,[1,0])

x = dc(0,*)
y = dc(1,*)

end
