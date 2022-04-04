function INTERSECT, array1, array2, nodata=nodata,xor_flag=xor_flag, $
	unique=unique,sorted=sorted,timed=timed

;+
; NAME:
;       INTERSECT
;
; PURPOSE:
;       Return the an array that is the intersection of the two input arrays.
;
; CATEGORY:
;       Array manipulation.
;
; CALLING SEQUENCE:
;       x = INTERSECT(array1, array2)
;
; INPUTS:
;  Arrays    The arrays to be scanned.  The type and number of dimensions
;            of the array are not important.  
;
; OPTIONAL INPUTS:
;   nodata:  This is the value returned if no value in the both of the
;            arrays.  The default is -1.
;
;   xor_flag if this keyword is set, only values are returned that belong
;            to one array or the other, but not both,
;            i.e., the complement of the set of intersection.
;
;   unique - set this keyword if the two arrays you're inputting have no
;		repeated elements
;
;   sorted - set this keyword if the two arrays you're inputting are already
;		sorted in ascending order.
;
;   timed - set this to time the routine
;            
;
; OUTPUTS:
;            result = An array of the values
;
; EXAMPLE:
;
;     x = [0,2,3,4,6,7,9]
;     y = [3,6,10,12,20]
;
;; print intersection of x and y
;
;     print,intersect(x,y)
;          3        6
;
;; print xor elements
;
;     print,intersect(x,y,/xor_flag)
;          0       2       4       7       9      10      12      20
;
;; print values in x that are not in y        
;
;     xyu=intersect(x,y,/xor_flag) & print,intersect(x,xyu)
;          0       2       4       7       9     
;
;
; COMMON BLOCKS:
;       None.
; 
; AUTHOR and DATE:
;     Jeff Hicke     12/16/92
;
; MODIFICATION HISTORY:
;
; Fixed mistake in sorting non-unique arrays, 16-Oct-01, TC
;
; Keywords UNIQUE, SORTED, and TIMED added, 16-May-01, TC.  For two 
;	pre-sorted, unique input arrays, setting the first two keywords 
;	reduces computation time by a factor of 2 (on a 416MHz Celeron
;	running Mandrake 7.2).
;
;
;	modified 3/6/01 by jeff Bezaire -added uniq()
;	to handle case where one of the arrays has
;	repeated values in it
;
;---------------------------------------------------------------------------

if keyword_set(timed) then t = systime(1)

if (keyword_set(nodata) eq 0) then nodata = -1

if keyword_set(unique) then begin
  if keyword_set(sorted) then array = [array1,array2] else $
	array = [array1[sort(array1)], array2[sort(array2)]]
endif else begin
  if keyword_set(sorted) then $
	array = [array1[uniq(array1)], array2[uniq(array2)]] else array = $
	[array1[uniq(array1,sort(array1))], array2[uniq(array2,sort(array2))]]
endelse

array = array(sort(array))

if keyword_set(xor_flag) then begin
  samp1=intarr(n_elements(array))
  samp2=samp1
  i1=where(array ne shift(array, -1),count)
  if count gt 0 then samp1(i1)=1
  i2=where(array ne shift(array,  1),count)
  if count gt 0 then samp2(i2)=1
  indices=where(samp1 eq samp2 , count)
  
endif else begin
  indices = where(array eq shift(array, -1), count)
endelse

if keyword_set(timed) then begin
	print, ''
	print, '  Took ', systime(1)-t, ' seconds CPU time'
	print, ''
endif

if (count GT 0) then return, array(indices) else return, nodata

end
