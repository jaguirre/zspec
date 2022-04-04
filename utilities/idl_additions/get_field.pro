function get_field, in_struct, fieldname
; 
; $Id: get_field.pro,v 1.2 2003/10/23 20:59:31 jaguirre Exp $
; $Log: get_field.pro,v $
; Revision 1.2  2003/10/23 20:59:31  jaguirre
; *** empty log message ***
;
;
;+
; NAME:
;	get_field
;
; PURPOSE:
;	Returns the specified field of the structure.  Lets you avoid
;	having to search for the tag index yourself.
;
; CALLING SEQUENCE:
;	result = get_field(in_struct, fieldname)
;
; INPUTS:
;	in_struct: input structure
;       fieldname: name of field to return, a string
;
; OUTPUTS:
;	in_struct.fieldname
;       Since there is no "empty" variable in IDL, this routine
;       exits ungracefully if fieldname does not exist.
;
; MODIFICATION HISTORY:
; 	2001/08/11 SG
;       2002/07/23 SG Add check on length of fieldname argument,
;                     allow fieldname to be a tag number.
;-

if (n_elements(fieldname) ne 1) then begin
   message, 'fieldname argument must be a single fieldname or index'
endif

fieldnames = tag_names(in_struct)
if (size(fieldname, /type) eq 7) then begin
   index = where(strcmp(fieldnames, fieldname, /fold_case))
endif else begin
   index = fieldname
endelse

; this shouldn't happen
if n_elements(index) gt 1 then begin
   message, 'Input structure has more than one field with name ' + fieldname
endif

if n_elements(index) eq 1 then begin
   ; yes, it's dumb one has to do this
   index = index[0]
   if index eq -1 then begin
      message, 'No fields in input structure found with fieldname ' + fieldname
   endif
endif

return, in_struct.(index)

end
