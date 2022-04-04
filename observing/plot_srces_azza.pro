pro $
   plot_srces_azza, $
     src_list, $
     ltime, yy, mm, dd, long = long, lat = lat, tz = tz, $
     sun_flag = sun_flag, moon_flag = moon_flag, $
     min_flux = min_flux, title = title, ps_file = ps_file, $
     azimuth = az, zenith_angle = za, src_name = src_name, noplot = noplot, $
     mars = mars, uranus = uranus, neptune = neptune, legend = $
     legend, za_limits = za_limits, za_cut = za_cut, $
     ra_1 = ra_1, ra_2 = ra_2, ra_3 = ra_3, $
     dec_1 = dec_1, dec_2 = dec_2, dec_3 = dec_3, flux = flux, $
     epoch = epoch, velocity = velocity, delta_velocity = delta_velocity, $
     lines = lines, jupiter = jupiter, saturn = saturn, $
     left_margin = left_margin

; $Id: plot_srces_azza.pro,v 1.2 2005/05/27 21:08:22 jaguirre Exp $
;
;+
; NAME:
;	plot_srces_azza
;
; PURPOSE:
;	Makes az/za plots of a list of sources for a given time
;       or set of times.  Plot is standard astronomical style
;       (i.e., east on left) za increasing outward from center, 
;       az increasing CCW, az = 0 at north.
;
; CALLING SEQUENCE:
;       plot_srces_azza, $
;          src_list, $
;          ltime, yy, mm, dd, long = long, lat = lat, tz = tz, $
;          min_flux = min_flux, title = title, ps_file = ps_file
;
; INPUTS:
;	src_list: Two choices:
;          1) text file containing sources.  Should be in column
;             form:   src_name  RAh RAm RAs DECd DECm DECs flux
;             Comment symbol is ';'.
;          2) array of structures with fields
;             src_name
;             ra   (decimal, hh.hhhh, not hhmmss)
;             dec  (decimal, dd.dddd, not ddmmss)
;             flux
;       ltime: time(s) at which source position is desired, hrs.  May be
;          an array, can be > 24 in order to bridge days.
;       yy, mm, dd: year, month, day for which source position is
;          desired.  Must be scalars.
;	
; OPTIONAL KEYWORD PARAMETERS:
;	long, lat: longitude, latitude of observatory, defaults to
;	   Keck if not provided.  Longitude is in degrees EAST of
;          Greenwich.
;       tz: time zone for which times are given, hours behind GMT
;          (e.g., Hawaii is +10)
;       sun_flag, moon_flag: plots position of sun and moon at 
;          time for which map is made
;       min_flux: minimum flux of sources to plot.  Defaults to 0.
;       title: title for source plot
;       ps_file: name of file to output postscript to
;
; COMMON BLOCKS:
;	USER_COMMON: defined in startup.pro
;
; MODIFICATION HISTORY:
; 	2003/05/23 SG
;       2003/05/26 SG Accept structure for src_list argument
;       2003/05/26 SG Add /sun_flag, /moon_flag
; $Log: plot_srces_azza.pro,v $
; Revision 1.2  2005/05/27 21:08:22  jaguirre
; Committing changes made during COSMOS 2005 run.
;
; Revision 1.1  2004/04/22 14:28:57  jaguirre
; First commit of SG's observing plan software.  Routines to visualize
; the sources and fields in the catalogs directory.
;
;-


;common USER_COMMON
@window_setup
set_plot, IDL_WIN.default
device, decomposed =0
tek_color

observatory, 'keck', obsinfo

if (size(src_list, /type) ne 7 AND size(src_list, /type) ne 8) then begin
   message, 'src_list must be a string or a structure'
endif
if not keyword_set(long) then long = 360. - obsinfo.longitude
if not keyword_set(lat) then lat = obsinfo.latitude
if not keyword_set(tz) then tz = obsinfo.tz 
if not keyword_set(min_flux) then min_flux = -1.0 
if not keyword_set(title) then title = ''

if (keyword_set(left_margin)) then left_margin = 1 else left_margin = 0

symarr = [1, 2, 4, 5, 6, 7]
n_syms = n_elements(symarr)
colarr = indgen(30) + 2
n_colors = n_elements(colarr)

if (size(src_list, /type) eq 7) then begin
   ; read file containing sources
    if (keyword_set(lines)) then begin
        readcol, /silent, src_list, format = 'A,F,F,F,F,F,F,F,A,F,F', $
          comment = ';', $
          src_name, ra_1, ra_2, ra_3, dec_1, dec_2, dec_3, flux, epoch, $
          velocity, delta_velocity
    endif else begin
        readcol, /silent, src_list, format = 'A,F,F,F,F,F,F,F', $
          comment = ';', $
          src_name, ra_1, ra_2, ra_3, dec_1, dec_2, dec_3, flux
    endelse
    ra = (ra_1 + ra_2/60. + ra_3/3600.) 
    dec = (dec_1 + dec_2/60. + dec_3/3600.)
endif else begin
   ; it's a structure
   src_name = src_list.src_name
   ra = src_list.ra
   dec = src_list.dec
   flux = src_list.flux
endelse

; select sources above flux cut
index = where(flux ge min_flux, count)
if (count eq 0) then begin
   message, $ 
      string(format = '(%"No sources above min_flux = %5.2f")', min_flux)
endif
src_name = src_name[index]
ra = ra[index]
dec = dec[index]
flux = flux[index]

n_time = n_elements(ltime)
n_src = n_elements(src_name)

; Make the ra and dec into nsources x ntimes arrays
ra = ra # replicate(1, n_time) 
dec = dec # replicate(1, n_time)

;stop

; get sun and moon positions if necessary
if (keyword_set(sun_flag) or keyword_set(moon_flag) or $
   keyword_set(mars) or keyword_set(uranus) or keyword_set(neptune)) $
  then begin
   ; don't need to do jd better than to the hour
   jd = julday(mm, dd, yy, floor(ltime))
   if (keyword_set(sun_flag)) then begin
       n_src = n_src+1
       sunpos, jd, ra_tmp, dec_tmp
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'SUN']      
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
   if (keyword_set(moon_flag)) then begin
       n_src = n_src+1
       moonpos, jd, ra_tmp, dec_tmp
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'MOON']      
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
   if (keyword_set(mars)) then begin
       n_src = n_src+1
       planet_coords, jd, ra_tmp, dec_tmp, planet = 'mars', /jd
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'MARS']
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
   if (keyword_set(jupiter)) then begin
       n_src = n_src+1
       planet_coords, jd, ra_tmp, dec_tmp, planet = 'jupiter', /jd
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'JUPITER']
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
   if (keyword_set(saturn)) then begin
       n_src = n_src+1
       planet_coords, jd, ra_tmp, dec_tmp, planet = 'saturn', /jd
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'SATURN']
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
   if (keyword_set(uranus)) then begin
       n_src = n_src+1
       planet_coords, jd, ra_tmp, dec_tmp, planet = 'uranus', /jd
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'URANUS']
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
   if (keyword_set(neptune)) then begin
       n_src = n_src+1
       planet_coords, jd, ra_tmp, dec_tmp, planet = 'neptune', /jd
       ra_tmp = ra_tmp * (24./360.)
       src_name = [src_name, 'NEPTUNE']
       ra = transpose([[transpose(ra)], [ra_tmp]])
       dec = transpose([[transpose(dec)], [dec_tmp]])
       flux = [flux, 999999.]
   endif
endif

;stop

; convert ra and dec to local coords

; first get lst
ct2lst, lst, long, tz, ltime, dd, mm, yy

lst = replicate(1, n_src) # lst

; then convert to local coords from ra and dec using lst
ha = lst - ra
el = 0
az = 0
getaltaz, dec, lat, ha, el, az
za = 90.-el

if (keyword_set(noplot)) then return

; and plot!
window_std, xsize = 600, ysize = 600
cleanplot, /silent
charsize = 1

if keyword_set(ps_file) then begin
   wdelete
   pageInfo = pswindow()
   set_plot, 'PS'
   device, _Extra = pageInfo, /color, filename = ps_file, /encap
   charsize = 0.75
endif   

setup_plot_azza, title = title, charsize = charsize, $
  za_limits = za_limits, left_margin = left_margin

;if (keyword_set(za_limits)) then begin
;    az_tmp = findgen(360)
;    za_high = replicate(20.,360)
;    za_low = replicate(60.,360)
;    oplot,/polar,za_low,!dtor*az_tmp,col=2,thick=2
;    oplot,/polar,za_high,!dtor*az_tmp,col=2,thick=2
;endif

; plot the positions
for k = 0, n_src-1 do begin
   za_this = za[k,*]
   az_this = az[k,*]
   ha_this = ha[k,*]
   index = where(za_this lt 90., count)
   if (count gt 0) then begin
      za_this = za_this[index]
      az_this = az_this[index]
      ha_this = ha_this[index]
      oplot, /polar, za_this, !DTOR*(90-az_this)
      if ((k+1) mod 2 eq 0) then $
        index_name = where(ha_this eq max(ha_this)) $
      else $
        index_name = where(ha_this eq min(ha_this))
      xyouts, $
         za_this[index_name] * cos(!DTOR*(90-az_this[index_name])), $
         za_this[index_name] * sin(!DTOR*(90-az_this[index_name])), $
         src_name[k], charsize = charsize*0.67
   endif
   za_this = za[k,*]
   az_this = az[k,*]
   ha_this = ha[k,*]
   if keyword_set(za_cut) then begin

       for l = 0, n_time-1 do begin
           if (za_this[l] le za_cut[0] and $
               za_this[l] ge za_cut[1]) then $
             oplot, /polar, [za_this[l]], [!DTOR*(90-az_this[l])], $
             psym = symarr[l mod n_syms], color = colarr[l mod n_colors], $
             sym=.2
       endfor
       
   endif else begin
       
       for l = 0, n_time-1 do begin
           if (za_this[l] lt 90.) then $
             oplot, /polar, [za_this[l]], [!DTOR*(90-az_this[l])], $
             psym = symarr[l mod n_syms], color = colarr[l mod n_colors]
       endfor
       
   endelse


endfor

str = string(format = '(%"local time:!C%4d/%2.2d/%2.2d")', yy, mm, dd)
for k = 0, n_time-1 do begin
   str = str + $
         string(format = '(%"!C%2.2dh%2.2dm")', $
            floor(ltime[k]), round( (ltime[k] mod 1)*60 ))
endfor

if (keyword_set(legend)) then begin
    xyouts, $
      !X.CRANGE[0] + 0.05*(!X.CRANGE[1] - !X.CRANGE[0]), $
      !Y.CRANGE[0] + 0.95*(!Y.CRANGE[1] - !Y.CRANGE[0]), $
      string(format = '(%"local time:!C%4d/%2.2d/%2.2d")', yy, mm, dd), $
      charsize = charsize
    
    labels = strarr(n_time)
    psyms = lonarr(n_time)
    colors = lonarr(n_time)
    
    for k = 0, n_time-1 do begin
        labels[k] = $
          string(format = '(%"%2.2dh%2.2dm")', $
                 floor(ltime[k]) mod 24, round( (ltime[k] mod 1)*60 ))
        psyms[k] = symarr[k mod n_syms]
        colors[k] = colarr[k mod n_colors]
    endfor
    legend, labels, $
      psym = psyms, color = colors, box = 0, position = $
      [190., 105.], $
;      [!X.CRANGE[0] + 0.05*(!X.CRANGE[1] - !X.CRANGE[0]), $
;       !Y.CRANGE[0] + 0.92*(!Y.CRANGE[1] - !Y.CRANGE[0])], $
      charsize = charsize
endif else begin

    xyouts, $
      150.,105., $
;      !X.CRANGE[0] + 0.05*(!X.CRANGE[1] - !X.CRANGE[0]), $
;      !Y.CRANGE[0] + 0.95*(!Y.CRANGE[1] - !Y.CRANGE[0]), $
      str, charsize = charsize
    
      print,str

endelse


if keyword_set(ps_file) then begin
;   xyouts, 0, !D.Y_CH_SIZE + !D.Y_SIZE, ps_file, $
;      charsize = 0.5, /device 
   device, /close_file 
   set_plot, IDL_WIN.default
endif

end
