pro setup_plot_azza, title = title, charsize = charsize, $
                     za_limits = za_limits, left_margin = left_margin, $
                     az_limits = az_limits

; $Id: setup_plot_azza.pro,v 1.2 2005/05/27 21:39:10 jaguirre Exp $
;
;+
; NAME:
;	setup_plot_azza
;
; PURPOSE:
;	Sets up standard astronomical style az/za plot.
;       (i.e., east on left) za increasing outward from center, 
;       az increasing CCW, az = 0 at north.
;
; CALLING SEQUENCE:
;       setup_plot_azza, title = title, charsize = charsize
;
; OPTIONAL KEYWORD PARAMETERS:
;       title: title for source plot
;       charsize: character size for annotations on plot (degrees,
;          N, S, E, W), in normalized units
;
; NOTES:
;       Assumes user has set up plot window already -- just issues
;       a few plot commands to generate the axes and grids.
;
; MODIFICATION HISTORY:
; 	2003/05/23 SG
; $Log: setup_plot_azza.pro,v $
; Revision 1.2  2005/05/27 21:39:10  jaguirre
; One last change ...
;
; Revision 1.1  2004/04/22 14:28:57  jaguirre
; First commit of SG's observing plan software.  Routines to visualize
; the sources and fields in the catalogs directory.
;
;-

if not keyword_set(title) then title = ''
if not keyword_set(charsize) then charsize = 1.0

if (keyword_set(left_margin)) then begin
    xmarg = [20,3]
    ymarg = [6,2]
endif else begin
    xmarg = [10,3]
    ymarg = [6,2]
endelse

; set up plot axes and az/za display
plot, /polar, [0], [0], /nodata, $
   xrange = [105., -105.], yrange = [-105., 105.], /xstyle, /ystyle, $
   xtitle = 'za * cos(az) [deg]', ytitle = 'za * sin(az) [deg]', $
   title = title, xmargin = xmarg, ymargin = ymarg, /iso
az_arr = findgen(360)
for k = 10, 90, 10 do begin
   oplot, /polar, k*replicate(1, n_elements(az_arr)), !DTOR*(az_arr+90), $
      linestyle = 2
   xyouts, 0, -k, $
      string(format = '(%"%0dd")', k), align = 0.5, charsize = charsize
endfor
za_arr = findgen(91)
for k = 0, 330, 30 do begin
   oplot, /polar, za_arr, !DTOR*k*replicate(1, n_elements(za_arr)), $
       linestyle = 2
   xyouts, 95 * cos(!DTOR*(90-k)), 95 * sin(!DTOR*(90-k)), $
      string(format = '(%"%0dd")', k), align = 0.5, charsize = charsize
endfor
xyouts, 0., 100, 'N', align = 0.5
xyouts, 0., -100, 'S', align = 0.5
xyouts, -100, 0., 'W', align = 0
xyouts, 100, 0., 'E', align = 1

if (keyword_set(za_limits)) then begin
    az_tmp = findgen(360)
    za_high = replicate(20.,360)
    za_low = replicate(60.,360)
    oplot,/polar,za_low,!dtor*az_tmp,thick=2,col=5
    oplot,/polar,za_high,!dtor*az_tmp,thick=2,col=5
endif

if (keyword_set(az_limits)) then begin

    oplot,/polar,[0,90],[1.,1.]*(90.-(-92.))*!dtor,col=4,thick=2
    oplot,/polar,[0,90],[1.,1.]*(90.-(-92.+444.))*!dtor,$
      col=2,thick=2
    oplot,/polar,[0,90],[1.,1.]*(90.-(-92.-444.))*!dtor,$
      col=3,thick=2


endif

end
