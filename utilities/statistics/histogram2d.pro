function $
   histogram2d, $
      x, y, $
      binsize_x = binsize_x, $
      min_x = min_x, max_x = max_x, $
      binsize_y = binsize_y, $
      min_y = min_y, max_y = max_y, $
      weights = weights
; $Id: histogram2d.pro,v 1.4 2004/12/19 22:28:00 golwala Exp $
; $Log: histogram2d.pro,v $
; Revision 1.4  2004/12/19 22:28:00  golwala
; SG fixed bug in weights keyword
;
; Revision 1.3  2004/10/31 16:00:25  golwala
; SG fix some bugs, add weights keyword
;
; Revision 1.2  2003/10/23 21:18:37  jaguirre
; *** empty log message ***
;
;
;+
; NAME:
;	HISTOGRAM2D
;
; PURPOSE:
;	Does 2-dimensional histograms.
;
; CALLING SEQUENCE:
;	result = $
;          histogram2d( $
;             x, y, $
;             binsize_x = binsize_x, $
;             min_x = min_x, max_x = max_x, $
;             binsize_y = binsize_y, $
;             min_y = min_y, max_y = max_y, $
;             weights )
;
; INPUTS:
;	x, y: x and y values of data to be histogrammed.
;
; REQUIRED KEYWORD PARAMETERS:
;	binsize_x, min_x, max_x, binsize_y, min_y, max_y = same
;          meaning as for HISTOGRAM, but of course have to supply for
;          each direction separately.  These are REQUIRED, though
;          of course one of min_x and max_x may be zero and similarly
;          for min_y and max_y
;
; OPTIONAL KEYWORD PARAMETERS:
;       weights: set this to weight the entries.  Must be same length
;          as x, y.  Can take a long time (have to histogram each data
;          point separately!).
;
; OUTPUTS:
;	The 2D histogram.
;
; MODIFICATION HISTORY:
; 	2002/10/31 SG
;       2004/10/31 SG More careful use of keywords.  Add weights.
;       2004/12/19 SG Bug in weights keyword fixed.
;-

if n_params() ne 2 then begin
   message, 'Requires 2 calling parameters.'
endif

if (n_elements(x) ne n_elements(y)) then begin
   message, 'The X and Y arguments must have the same length.'
endif

if not keyword_set(min_x) then min_x = 0
if not keyword_set(max_x) then max_x = 0
if not keyword_set(min_y) then min_y = 0
if not keyword_set(max_y) then max_y = 0

if ( not keyword_set(binsize_x) OR not keyword_set(binsize_y)) then begin
   message, 'Both binsize_x and binsize_y keyword parameters are required.'
endif

if ( not keyword_set(min_x) AND not keyword_set(max_x)) then begin
   message, /cont, $
   'At least one of min_x or max_x keyword parameters must be set'
   message, /cont, $
   'to a nonzero value.'
endif

if ( not keyword_set(min_y) AND not keyword_set(max_y)) then begin
   message, /cont, $
   'At least one of min_y or max_y keyword parameters must be set'
   message, /cont, $
   'to a nonzero value.'
endif

if keyword_set(weights) then $
   if n_elements(weights) ne n_elements(x) then $
      message, 'weights keyword has wrong length.'

; we use hist_2d, but we have to put data in appropriate form first
ix = floor( (x - min_x)/binsize_x )
iy = floor( (y - min_y)/binsize_y )

max1 = -1L + ceil( (max_x - min_x)/binsize_x )
max2 = -1L + ceil( (max_y - min_y)/binsize_y )

; call hist_2d
if not keyword_set(weights) then begin
   result = $
     hist_2d( ix, iy, $
        bin1 = 1, min1 = 0, max1 = max1, bin2 = 1, min2 = 0, max2 = max2 )
endif else begin
   result = $
     hist_2d( [0], [0], $
        bin1 = 1, min1 = 0, max1 = max1, bin2 = 1, min2 = 0, max2 = max2 )
   result[*] = 0.
   for k = 0, n_elements(weights)-1 do begin
      result = result + $
        weights[k] $
        * hist_2d( [ix[k]], [iy[k]], $
             bin1 = 1, min1 = 0, max1 = max1, bin2 = 1, min2 = 0, max2 = max2 )

   endfor
endelse   

return, result

end




