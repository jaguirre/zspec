pro delete_field, in_struct, fieldname
;+
; NAME:
;	delete_field
;
; PURPOSE:
;	Replaces a field in input structure with new value.
;       Works around IDL restrictions on structure assignment.
;
; CALLING SEQUENCE:
;	delete_field, in_struct, fieldname
;
; INPUTS:
;	in_struct: input structure
;       fieldname: name of field to delete, a string, or
;          tag number of field to delete
;
; OUTPUTS:
;	modified version of structure replaces in_struct
;
; MODIFICATION HISTORY:
; 	2002/07/23 SG
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

; what elements will be in the output structure?
index_out = setdifference(indgen(n_tags(in_struct)), [index])

; create output structure
out_struct = create_struct(fieldnames[index_out[0]], in_struct.(index_out[0]))
for k = 1, n_elements(index_out)-1 do begin
   out_struct = $
      create_struct(out_struct, $
                    fieldnames[index_out[k]], in_struct.(index_out[k]))
endfor

in_struct = out_struct

end
