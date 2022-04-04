pro radec_plot, $
                      ptg_src_file, field_file, ra_0, $
                      src_flag = src_flag, $
                      no_2500mjy = no_2500mjy, $
                      no_500mjy = no_500mjy, $
                      no_100mjy = no_100mjy, $
                      title = title, $
                      ps_file = ps_file, $
                      xrange = xrange, $
                      yrange = yrange, $
                      legend = legend, $
                      sources = sources, $
                      fields = fields, $
                      noplot = noplot, $
                      field_name = field_name
;
; $Id: plot_srces_radec.pro,v 1.1 2004/04/22 14:28:57 jaguirre Exp $
;
;+
; NAME:
;	plot_srces_radec
;
; PURPOSE:
;	Makes ra/dec plots of a list of sources.
;       Plot is standard astronomical style, (i.e., ra decreasing to
;       left), must specify ra0 to give center of plot.
;       Projection corrects for cos(dec) factor.
;
; CALLING SEQUENCE:
;       plot_srces_radec, $
;          ptg_src_file, field_file, ra_0, $
;          src_flag = src_flag, $
;          no_2500mjy = no_2500mjy, $
;          no_500mjy = no_500mjy, $
;          no_100mjy = no_100mjy, $
;          ps_file = ps_file, $
;          xrange = xrange, $
;          yrange = yrange, $
;          nolegend = nolegend, $
;          sources = sources, $
;          fields = fields, $
;          noplot = noplot
;
; INPUTS:
;	ptg_src_file: text file containing ptg/cal sources.  
;          Should be in column form:
;             src_name  RAh RAm RAs DECd DECm DECs flux
;          Comment symbol is ';'.
;       field_file: text file containing science targets, same
;          form as ptg_src_file, flux field not necessary.  Only 
;          distinction between fields and ptg srces is that there 
;          is no flux cut on fields and they are plotted with
;          different and bigger symbols.
;       ra_0: ra "origin", hrs.  The ra that will be placed at the 
;          horizontal origin of the map.  For a plot that is useful
;          for a whole night, make this the LST at midnight local
;          time.  For something that is useful for a specific field,
;          pick ra_0 to be the ra of the field.
;	
; OPTIONAL KEYWORD PARAMETERS:
;       src_flag: set this to have source names plotted also
;       no_2500mjy, no_500mjy, no_100mjy: set these flags to
;          exclude sources with fluxes > 2500 mJy, fluxes between
;          500 and 2500 mJy, and fluxes between 100 and 500 mJy.
;          Sources with fluxes below 100 mJy are not plotted.
;          This set of flags is a kludge, should probably get replaced
;          with an 2xN array giving pairs of numbers defining source
;          flux bands.
;       ps_file: name of file to output postscript to
;       xrange, yrange : x and y range of the plot, in degrees.  Can
;          be set to zoom in on a particular region of the sky.  Set
;          in the same way as when calling "plot".  Be sure to set 
;          xrange = [xmax, xmin] to get RA in the usual orientation.
;          Default is to plot the whole sky.
;       nolegend: leave the legend off the plot
;       sources, fields: returns the names, RA's and dec's read from
;          the files into the named structure.
;       noplot: the effect of simply reading in the data from the
;          files can be achieved by setting the sources or fields
;          keywords and the noplot keyword.  If noplot is set, the
;          routine returns after reading the data but before any
;          plotting.  src_flag and ps_file have no effect in this
;          case.
;
; COMMON BLOCKS:
;	USER_COMMON: defined in startup.pro
;
; MODIFICATION HISTORY:
; 	2003/05/23 SG
; $Log: plot_srces_radec.pro,v $
; Revision 1.1  2004/04/22 14:28:57  jaguirre
; First commit of SG's observing plan software.  Routines to visualize
; the sources and fields in the catalogs directory.
;
;-

;common USER_COMMON
;set_plot, IDL_WIN.default
;device, decomposed =0
;tek_color

if not keyword_set(title) then title = ''

; Deal with the field file first.

if (size(field_file,/type) eq 7) then begin

; read file containing science fields
; This is the original behavior of the program ...
    readcol, field_file, format = 'A,F,F,F,F,F,F,F', /silent, $
      comment = ';', $
      field_name, ra_1, ra_2, ra_3, dec_1, dec_2, dec_3, dummy

endif else begin

    ra_1 = field_file[0] & ra_2 = field_file[1] & ra_3 = field_file[2]
    dec_1 = field_file[3] & dec_2 = field_file[4] & dec_3 = field_file[5]
    
    ra_0 = ten(ra_1,ra_2,ra_3)
    dec_0 = ten(dec_1,dec_2,dec_3)
; X and Y range are interpreted relative to ra_0,dec_0
; Ranges are given in degrees.
    if (keyword_set(xrange)) then begin
; Convert to degrees
        xrange = reverse(xrange); + ra_0 * 360./24. * cos(!DTOR * dec_0)
    endif else begin
        xrange = [10,-10] ; + ra_0 * 360./24. * cos(!DTOR * dec_0)
    endelse

    if (keyword_set(yrange)) then begin
; Convert to hours
        yrange = [dec_0 + yrange[0], dec_0 + yrange[1]]
    endif else begin
        yrange = dec_0 + [-10,10]
    endelse

endelse

; Jeez ... we always do things the hard way.
ra_field = ten(ra_1,ra_2,ra_3)  ;(ra_1 + ra_2/60. + ra_3/3600.) 
dec_field = ten(dec_1,dec_2,dec_3) ;dec_1 + dec_2/60. + dec_3/3600.)

fields = $
  create_struct( $
                 'name', field_name, $
                 'ra',  ra_field, $
                 'dec', dec_field)

ra_field = ra_field - ra_0

x_field = [ra_field * 360./24. * cos(!DTOR * dec_field)]
y_field = [dec_field]
n_field = n_elements(dec_field)

; read file containing ptg sources
readcol, ptg_src_file, format = 'A,F,F,F,F,F,F,F', /silent, $
   comment = ';', $
   ptg_src_name, ra_1, ra_2, ra_3, dec_1, dec_2, dec_3, flux_ptg

ra_ptg = (ra_1 + ra_2/60. + ra_3/3600.) 
dec_ptg = (dec_1 + dec_2/60. + dec_3/3600.)

sources = $
  create_struct( $
                 'name', ptg_src_name, $
                 'ra',  ra_ptg, $
                 'dec', dec_ptg)

ra_ptg = ra_ptg - ra_0
ra_ptg = ra_ptg + 24.*(ra_ptg le -12.)

x_ptg = ra_ptg * 360./24. * cos(!DTOR * dec_ptg)
y_ptg = dec_ptg
n_ptg = n_elements(dec_ptg)

if (keyword_set(noplot)) then return

; select different subsets of ptg srces
index_2500mjy = where(flux_ptg ge 2.5, n_2500mjy)
index_500mjy = where(flux_ptg ge 0.5 and flux_ptg lt 2.5, n_500mjy)
index_100mjy = where(flux_ptg ge 0.1 and flux_ptg lt 0.5, n_100mjy)

; and plot!
;window_std, xsize = 800, ysize = 800
;cleanplot, /silent
charsize = 1

if keyword_set(ps_file) then begin
   wdelete
   pageInfo = pswindow()
   set_plot, 'PS'
   device, _Extra = pageInfo, /color, filename = ps_file
   charsize = 0.75
endif   

if (keyword_set(xrange)) then xrange = xrange else xrange = [180., -180.]
if (keyword_set(yrange)) then yrange = yrange else yrange = [-90., 90.]

plot, [0], [0], /nodata, $
   xrange = xrange, yrange = yrange, /xstyle, /ystyle, $
   xtitle = textoidl('\Delta x [deg]'), ytitle = textoidl('\Delta y [deg]'), $
   title = title

y_lines = findgen(181) - 90.
for k = -12, 12, 2 do begin
   oplot, k * 15. * cos(!DTOR * y_lines), y_lines, linestyle = 2
   xyouts, k * 15., 0, $
      string(format = '(%"%0dh")', (k+ra_0) - 24.*( (k+ra_0) ge 24. ) ), $
      align = 0.5, charsize = charsize
endfor
x_lines = findgen(361) - 180. 
for k = -90, 90, 15 do begin
   oplot, x_lines * cos(!DTOR * k), k*replicate(1.,n_elements(x_lines)), $
      linestyle = 2
endfor

; edge of the world
y_edge = findgen(181) - 90.
x_edge = 180. * cos(!DTOR * y_edge)

oplot, x_field, y_field, psym = 2, symsize = 2*charsize, $
   color = !P.COLOR
if keyword_set(src_flag) then begin
   for k = 0, n_field-1 do begin
      xyouts, x_field[k], y_field[k], field_name[k], charsize = charsize
   endfor
endif

if (not keyword_set(no_2500mjy) and (n_2500mjy gt 0)) then begin
   oplot, x_ptg[index_2500mjy], y_ptg[index_2500mjy], $
      psym = 4, color = 2, symsize = charsize
   if keyword_set(src_flag) then begin
      for k = 0, n_2500mjy-1 do begin
         xyouts, x_ptg[index_2500mjy[k]], y_ptg[index_2500mjy[k]], $
            ptg_src_name[index_2500mjy[k]], $
            color = 2, charsize = charsize, $
           clip = [xrange[0],yrange[0],xrange[1],yrange[1]], $
           noclip = 0
     endfor
   endif
endif
if (not keyword_set(no_500mjy) and (n_500mjy gt 0)) then begin
   oplot, x_ptg[index_500mjy], y_ptg[index_500mjy], $
      psym = 5, color = 3, symsize = charsize
   if keyword_set(src_flag) then begin
      for k = 0, n_500mjy-1 do begin
         xyouts, x_ptg[index_500mjy[k]], y_ptg[index_500mjy[k]], $
            ptg_src_name[index_500mjy[k]], $
            color = 3, charsize = charsize, $
           clip = [xrange[0],yrange[0],xrange[1],yrange[1]], $
           noclip = 0
      endfor
   endif
endif
if (not keyword_set(no_100mjy) and (n_100mjy gt 0)) then begin
   oplot, x_ptg[index_100mjy], y_ptg[index_100mjy], $
      psym = 6, color = 4, symsize = charsize
   if keyword_set(src_flag) then begin
      for k = 0, n_100mjy-1 do begin
         xyouts, x_ptg[index_100mjy[k]], y_ptg[index_100mjy[k]], $
            ptg_src_name[index_100mjy[k]], $
            color = 4, charsize = charsize, $
           clip = [xrange[0],yrange[0],xrange[1],yrange[1]], $
           noclip = 0
     endfor
   endif
endif

if (keyword_set(legend)) then begin

    legend, /bottom, /left, $
      ['science fields', $
       '>= 2500 mJy', '>= 500 mJy, < 2500 mJy', '>= 100 mJy, < 500 mJy'], $
      psym = [2, 4, 5, 6], color = [!P.COLOR, 2, 3, 4], $
      charsize = charsize

endif

xyouts, $
   !X.CRANGE[0] + 0.05*(!X.CRANGE[1] - !X.CRANGE[0]), $
   !Y.CRANGE[0] + 0.95*(!Y.CRANGE[1] - !Y.CRANGE[0]), $
   string(format = '(%"RA origin = %4.1fh")', ra_0), $
   charsize = charsize

if keyword_set(ps_file) then begin
   xyouts, 0, !D.Y_CH_SIZE + !D.Y_SIZE, ps_file, $
      charsize = 0.5, /device 
   device, /close_file 
   set_plot, IDL_WIN.default
endif

end
