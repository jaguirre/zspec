;+
;===========================================================================
;  NAME: 
;		     bolodark_pl_loadcrv
;  
;  DESCRIPTION:      
;		     plot load curves from data structure
;
;  USAGE: 
;		     bolodark_pl_loadcrv, x, ichan 
;
;  INPUT:	     
;    x 		     (struct) data structure produced by   
;		      bolodark_read_loadcrv.pro
;    ichan	     (int) channel index		   
;    
;  OUTPUT: 
;		     plot
;
;  KEYWORDS:
;    yfree	     allows free y scaling of load curve display
;
;  AUTHOR: 
;		     Bernhard Schulz
; 
;  Edition History:
;
;  Date    	Programmer   Remarks
;  ---------- 	----------   -------
;  2003-05-02 	B. Schulz    initial test version
;  2003-05-07 	B. Schulz    yfree keyword introduced
;
;===========================================================================
;-

pro bolodark_pl_loadcrv, x, ichan, yfree=yfree

nf = n_elements(x)

ct = get_13colortable()
nct = n_elements(ct)
if !d.name EQ 'PS' then fgcolor = 'black' else fgcolor = 'white'

ymin = min((*x[0]).ubolo[ichan,*])
ymax = max((*x[0]).ubolo[ichan,*])

if keyword_set(yfree) then begin
  for ifile=1, nf-1 do begin
    ymn = min((*x[ifile]).ubolo[ichan,*])
    ymx = max((*x[ifile]).ubolo[ichan,*])
    if ymn LT ymin then ymin = ymn
    if ymx GT ymax then ymax = ymx
  endfor
endif

for ifile=0, nf-1 do begin

  ; bolodark_ibias,(*x[ifile]).ubolo[ichan,*], (*x[ifile]).ubias, ibias
  
  if ifile EQ 0 then begin

      if keyword_set(yfree) then yrange=[ymin,ymax] $
      else yrange = [-0.01,0.01]
      
      plot, (*x[ifile]).ubias, (*x[ifile]).ubolo[ichan,*], $
        psym=3, color=blo_color_get(fgcolor), yrange=yrange, $
         ystyle=3, $
	title = (*x[0]).ubolo_label[ichan] + ' Load Curves', $
        xtitle = 'U!Dbias!N [V]', $
        ytitle = 'U!DBolo!N [V]', $
	charsize=1.8, xthick=2, ythick=2, /nodata

      oplot, (*x[ifile]).ubias, (*x[ifile]).ubolo[ichan,*], $
        psym=3, color=blo_color_get(ct[ifile MOD nct])

  endif else begin

      oplot, (*x[ifile]).ubias, (*x[ifile]).ubolo[ichan,*], $
        psym=3, color=blo_color_get(ct[ifile MOD nct])

  endelse

endfor

end

