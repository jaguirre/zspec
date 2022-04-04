pro $
   plot_map_tv, $
     map, zrange = zrange, $
     x0 = x0, y0 = y0, dx = dx, dy = dy, $
     astro_orient_flag = astro_orient_flag, $
     astro_coord_flag = astro_coord_flag, $
     title = title, subtitle = subtitle, $
     xtitle = xtitle, ytitle = ytitle, ct = ct, $
     xrange = xrange, yrange = yrange, _extra=extra
;+
; NAME:
;	plot_map_tv
;
; PURPOSE:
;	Makes a proper plot of a map in tv style.
;
; CALLING SEQUENCE:
;
; INPUTS:
;	map: 2d matrix containing map.  1st index is x coord, 2nd
;	   index is y coord
;
; OPTIONAL KEYWORD PARAMETERS:
;       zrange: min and max values to plot.  Image is linearly scale
;          between these values.
;	x0, y0: origin of map (position of center of 1st pixel in each
;	   direction)
;       dx, dy: pixel size, same units as x0, y0
;       astro_orient_flag: set this to flip the map in x; i.e., x
;          coord decreasing to the right, like with astronomical maps
;       astro_coord_flag: set this to indicate you want the x and y
;          axes to use RA and dec with mm and ss instead of decimals
;       title, xtitle, ytitle: standard titling keywords for plotting
;       ct: color-table to use, see LOADCT command.  Defaults to
;          ct = 0 (256-shade grayscale)
;
; NOTES:
;       You should set up the device beforehand; i.e., create window,
;       make it the desired size, set color table, etc.  All this
;       routine does is make the plot.
;       COSINE corrections: usually, dx is in physical units.
;          But, if one wants RA or AZ along the x-axis, dx
;          should be divided by cos(y0) to convert to the right
;          coords.  We leave it to the user to do this correction.
;
; MODIFICATION HISTORY:
;       2003/11/07 SG
;       2003/11/12 SG Was getting integer roundoff when image was 
;                     not a double; fixed
;                     Was not erasing previous plot; fixed.
;                     Now returns without plotting if zrange is crap.
;       2003/11/19 SG Add subtitle keyword
;       2004/02/03 JA Just reversing the x array is not sufficient to
;                     cause the plot to have the RA axis labels
;                     increasing to the left.  You must also specify
;                     the xrange in the contour call.
;       2004/02/27 SG Add more error checking of zrange
;       2004/04/16 SG Add color-table argument
;       2004/04/22 SG Add warning if dx or dy < 0
;       2004/05/09 SG Accept maps with number of dimension > 2 as
;                     long as only 2 dimensions have length > 1
;       2004/08/21 PS Added keywords xrange and yrange, which specify
;                     ranges of the map in both directions to plot.
;-  

if (n_params() ne 1) then message, 'Requires 1 calling parameter.'

ndim = size(map, /n_dim)
sz = size(map, /dim)
if not (ndim eq 2 or (ndim gt 2 and total(sz ne 1) eq 2)) then begin
   message, /cont, $
   'map must be 2-D matrix or a n-D matrix with all but 2 dimensions having'
   message, 'length 1'
endif

if keyword_set(zrange) then begin
   if (total(finite(zrange) ne 1) ne 0) then begin
      message, /cont, $
         'zrange must be finite, zrange = ' $
         + string(zrange[0], zrange[1])
      return
   endif
   if (zrange[1] le zrange[0]) then begin
      message, /cont, $
         'zrange must be monotonic increasing, zrange = ' $
         + string(zrange[0]) + string(zrange[1])
      return
   endif
endif else begin
   zrange = [min(map, /nan), max(map, /nan)]
   if (total(finite(zrange)) ne 2) then zrange = [0., 1.]
endelse

if not keyword_set(x0) then x0 = 0
if not keyword_set(y0) then y0 = 0
if not keyword_set(dx) then dx = 1
if not keyword_set(dy) then dy = 1
if (dx lt 0 or dy lt 0) then begin 
   message, /cont, $
   'dx lt 0 or dy lt 0.  Your axes may come out with the opposite' + $
   ' orientation as you expected.  Please double check that these signs' + $
   ' are what you want.'
endif

if not keyword_set(title) then title = ''
if not keyword_set(subtitle) then subtitle = ''
if not keyword_set(xtitle) then xtitle = ''
if not keyword_set(ytitle) then ytitle = ''
if not keyword_set(xrange) then xrange = [0,n_e(map[*,0])-1] ;PS 040821
if not keyword_set(yrange) then yrange = [0,n_e(map[0,*])-1] ;PS 040821

if not keyword_set(ct) then ct = 0

image = reform(map[xrange[0]:xrange[1],yrange[0]:yrange[1]]) ;PS 040821
sz = size(image, /dim)
nx = sz[0]
ny = sz[1]

; construct x and y arrays
x = x0 + findgen(nx)*dx
y = y0 + findgen(ny)*dy 

if keyword_set(astro_orient_flag) then begin
   image = reverse(image,1) ;PS 040821
   x = reverse(x)
endif

image = $
   ( double(image) - double(zrange[0]) ) $
   / ( double(zrange[1]) - double(zrange[0]) )
image = byte( image * 255. )

posn = [0.17, 0.17, 0.92, 0.92]
!P.POSITION = posn

; store the current color table
ct_current = fltarr(!D.TABLE_SIZE, 3)
tvlct, /get, ct_current
loadct, /silent, ct
; lay down the tv image                                             
tvimage, image, /keep_aspect_ratio, position = posn, /nointerp, /erase, _extra=extra  ;PS 041018 (added _extra=extra)
; and switch back to the original color table
tvlct, ct_current

; do contour afterward because tv tends to cover up axes
if keyword_set(astro_coord_flag) then begin

   extra = $
      create_struct( $
         'position', posn, $
         'title', title, $
         'subtitle', subtitle, $
         'xtitle', xtitle, $
         'ytitle', ytitle, $
         'noerase', 1, $
         'nodata', 0, $
         'xstyle', 1, $
         'ystyle', 1, $
         'min_value', zrange[0], $
         'max_value', zrange[1] )
   
   contour_radec, fltarr(sz), x, y, _extra = extra
endif else begin
   contour, image, x, y, position = posn, $ ;PS 040821
      title = title, subtitle = subtitle, $
      xtitle = xtitle, ytitle = ytitle, /nodata, /xstyle, /ystyle, $
      /noerase, xrange = [x[0],x[nx-1]], $
      min_value = zrange[0], max_value = zrange[1]

endelse

end

