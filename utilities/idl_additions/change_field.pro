pro change_field, in_struct, fieldname, fieldval
;+
; NAME:
;	change_field
;
; PURPOSE:
;	Replaces a field in input structure with new value.
;       Works around IDL restrictions on structure assignment.
;
; CALLING SEQUENCE:
;	change_field, in_struct, fieldname, fieldval
;
; INPUTS:
;	in_struct: input structure
;       fieldname: name of field to change, a string, or
;          tag number of field to change
;       fieldval: value to put into field.  Can be any kind of
;          variable
;
; OUTPUTS:
;	modified version of structure replaces in_struct
;
; MODIFICATION HISTORY:
; 	2001/10/11 SG
;       2002/06/23 SG Allow fieldname to be a tag number
;       2002/07/23 SG Add check on length of fieldname argument.
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


; create output structure, using fieldval if necessary
if index ne 0 then begin
   out_struct = create_struct(fieldnames[0], in_struct.(0));
endif else begin
   out_struct = create_struct(fieldnames[0], fieldval);
endelse
; now add the other fields, replacing the appropriate field if needed
for k = 1, n_tags(in_struct)-1 do begin
   if k ne index then begin
      out_struct = create_struct(out_struct, fieldnames[k], in_struct.(k));
   endif else begin
      out_struct = create_struct(out_struct, fieldnames[k], fieldval);
   endelse
endfor

in_struct = out_struct

end
