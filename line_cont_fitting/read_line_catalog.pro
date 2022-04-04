; A wrapper to make the reading of the line catalog transparent to the
; user.  The logic here is that we may want to add entries, which is
; easier to handle if there's just one place where they're all read.

; The first three variables returned are ALWAYS species, transition,
; and (center) frequency

pro read_line_catalog,species,transition,frequency,profile_type,$
                      quiet = quiet

line_catalog = !zspec_pipeline_root+$
  '/line_cont_fitting/zspec_line_table.txt'

silent = 1
if ~keyword_set(quiet) then begin
    print,'Reading catalog from'
    print,line_catalog
    silent = 0
endif

readcol,line_catalog,$
  comment=';',format='(A,A,D,A)',$
  species,transition,frequency,profile_type,silent=silent

end
