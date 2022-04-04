function smart_sixty, ain
;+
; Routine to take a 0D, 1D, or 2D matrix of angles in HH,MM,SS or DD,MM,SS
; and convert to a decimal array.
;
; INPUTS
;    ain = input array of angles
;          0D: assumed to be DD or HH with MM = 0 and SS = 0
;          1D: assumed to be [HH,MM,SS] or [DD,MM,SS], with
;              MM and SS optional (e.g, could be 1, 2, or 3 elements long)
;              NOTE: if 1D and length > 3, error is returned: ambiguous input
;          2D: assumed to be matrix in form
;              HH HH HH HH HH ...  (or DD)
;              MM MM MM MM MM ...
;              SS SS SS SS SS ...
;              if fewer than 3 rows, the missing entry assumed to be 0
; 
; OUTPUTS
;     output array of angles
;        dimension depends in input dimension
;        returns Inf if inputs are invalid
;
; SG 2000/08/02
;-

a = ain
aout = !VALUES.F_INFINITY

; make sure only 1 or 2 dimensions
if (size(a, /n_dim) gt 2) then begin
   print
   print, $
'ERROR in smart_sixty: angle input must be dimension 2 or less.'
   return, aout
endif

; if 0 dim, make 1D
if (size(a, /n_dim) eq 0) then begin
   a = [a, 0, 0]
endif
; if 1 dim, must be only a single value
if (size(a, /n_dim) eq 1) then begin
   ; too many elements to be a single value
   if (n_elements(a) gt 3) then begin
      print
      print, $
'ERROR in smart_sixty: You have entered an angle as a 1D vector with'
      print, $
'more than three elements.  This is not allowed.  Please either turn it'
      print, $
'into a 1D vector with 3 or fewer elements (corresponding to one angle value)'
      print, $
'or into a 2D vector with the a[*,0] giving HH, a[*,1] giving MM.'
   endif
   ; correct to make it 3 elements
   if (n_elements(a) eq 1) then begin
      a = [a, 0, 0];
   endif
   if (n_elements(a) eq 2) then begin
      a = [a, 0];
   endif
   a = ten(a[0],a[1],a[2])
endif
 
; if 2D, correct for 2nd dim length
if (size(a, /n_dim) eq 2) then begin
   if (n_elements(a[0,*]) gt 3) then begin
      print
      print, $
'ERROR in smart_sixty: You have entered the angle as a 2D matrix with'
      print, $
'more than three rows.  This is not allowed.  The rows must correspond'
      print, $
'to HH, MM, and SS, or DD, AM, and AS, where the latter two are optional.'
      return, aout
   endif
   if (n_elements(a[0,*]) eq 1) then begin
      a = tenv( a[*,0], 0, 0 )
   endif
   if (n_elements(a[0,*]) eq 2) then begin
      a = tenv( a[*,0], a[*,1], 0)
   endif
   if (n_elements(a[0,*]) eq 3) then begin
      a = tenv( a[*,0], a[*,1], a[*,2] )
   endif
endif

aout = a
return, aout

end
