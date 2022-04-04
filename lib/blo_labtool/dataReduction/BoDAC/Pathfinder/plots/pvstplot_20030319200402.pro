; Plot P versus T

pro pvstplot_20030319200402, x

path = '/data1/BoDAC/3_Pathfinder/20030402/'
;restore, path+'20030319200402.sav'

blo_color_init

!p.multi=[0,1,3]
;psinit, /full, /letter, /color

gp = blo_getgoodpix()

ct = get_13colortable()
nct = n_elements(ct)
if !d.name EQ 'PS' then fgcolor = 'black' else fgcolor = 'white'

;-----------------------------------
;select temperature stable measurements
ixt = bolodarkx_tdrift(x, limit=0.001, tfract=0.10, below=0.4)
xx = x[ixt]

nf       = n_elements(xx)
nchan = n_elements((*xx[0]).ubolo[*,0])

;------------------------------------------

;restore R_star, T_star
bolodark_restore_rtstar, chan, r_star, t_star

nf   = n_elements(x)
npix = n_elements((*x[0]).ubolo[*,0])


;bias_offsets = fltarr(nf)
;for ifile=0, nf-1 do begin
;  ipix = 1
;  ubias = (*x[ifile]).ubias
;  ubolo = reform((*x[ifile]).ubolo[ipix,*])
;  bias_offsets[ifile] = bolodark_lcsymm_get(ubias, ubolo)	;bias offset
;  print, bias_offsets[ifile]
;endfor


for ipix = 0, npix-1 do begin

  ix = where(strtrim((*x[0]).ubolo_label[ipix],2) EQ strtrim(gp), cnt)
  if cnt GT 0 then begin
    for ifile=0, nf-1 do begin

      chname = (*x[ifile]).ubolo_label[ipix]
      ixstar = where(chan EQ chname, cnt)

      if cnt GT 0 then begin

    	ubias = (*x[ifile]).ubias
    	ubolo = reform((*x[ifile]).ubolo[ipix,*])
    	T_c   = (*x[ifile]).T_c

       ;------------------------------------
       ;remove offset in ubias
    	;offs = bolodark_lcsymm_get(ubias, ubolo) ;bias offset
    	;ubias = ubias - offs	  
    	;print, offs

    	a = bolodark_moffset(ubolo, ubias)	  ;determine bolo offset
    	uboloc = ubolo-a[0]			  ;remove bolo offset
    	

    	bolodark_ibias, uboloc, ubias, ibias

    	P = uboloc * ibias
    	R = uboloc / ibias
      
    	T = bolodark_tbolo(R, R_star[ixstar[0]], T_star[ixstar[0]])
stop
    	if ifile EQ 0 then $
    	  plot_oo, P, T, psym=3, xtitle='P [W]', ytitle = 'T [K]',  $
    	     yrange=[0.1,3], xrange=[0, 6e-11], charsize=1.6, $
    	     title = chname, color=blo_color_get(fgcolor), /nodata, $
	     xstyle=3, ystyle=3
      
    	oplot, P, T, psym=3, color=blo_color_get(ct[ifile MOD nct])

      endif

    endfor
  endif
endfor

!p.multi=0

end
