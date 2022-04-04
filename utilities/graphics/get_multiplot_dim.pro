function get_multiplot_dim, nplots, nrows = nrows
;+
; NAME:
;    get_multiplot_dim.pro
;
; PURPOSE:
;    Stupid function calculate number of x and y plots for 
;    !P.MULTI given a total number of plots. 
;
; CALLING SEQUENCE:
;    dims = get_multiplot_dim(nplots,/nrows = nrows)
;
; INPUTS:
;    nplots = total number of plots
;
; OUTPUTS:
;    2 element vector
;    1st entry = number of columns
;    2nd entry = number of rows
;
; KEYWORDS: (optional)
;    nrows = preferred number of rows.  If not set, tries to make
;            as square as possible
;
; REVISION HISTORY:
;    2000/11/13 SG
;    2001/04/06 SG Change output order to ncols, nrows to match the
;                  rest of IDL
;-

if not keyword_set(nrows) then begin
   nrows = sqrt(nplots)
   if (nrows ne fix(nrows)) then begin
      nrows = 1.0 + fix(nrows)
   endif
endif

ncols = nplots/nrows
if (ncols ne fix(ncols)) then begin
   ncols = 1.0 + fix(ncols)
endif

dims = fix([ncols, nrows])

return, dims

end
