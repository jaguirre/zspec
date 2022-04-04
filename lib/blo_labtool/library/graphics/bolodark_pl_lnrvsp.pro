;+
;===========================================================================
;  NAME: 
;		   bolodark_pl_lnrvsp
;
;  DESCRIPTION:    
;		   Plot the resistance versus power
;
;  USAGE: 
;		   bolodark_pl_lnRvsP, ubolo, ibias
;
;  INPUT: 	   
;    ubolo	   (array float) bolometer voltage [V] 
;    ibias	   (array float) bias current [A]      
;    
;  OUTPUT: 
;		   plot    
;
;  KEYWORDS: 
;		   none
;
;  AUTHOR: 
;	           Bernhard Schulz
; 
;  Edition History:
;
;  Date        Programmer  Remarks
;  ----------  ----------  -------
;  2003-05-08  B. Schulz   initial test version
;
;===========================================================================
;-

pro bolodark_pl_lnrvsp, ubolo, ibias, title=title

if NOT keyword_set(title) then title='ln(R) vs. P'

ct = get_13colortable()
nct = n_elements(ct)
if !d.name EQ 'PS' then fgcolor = 'black' else fgcolor = 'white'


R = ubolo / ibias
P = ubolo * ibias

ix = where(R GT 0, cnt)

if cnt GT 1 then begin

   lnR = alog(R[ix])
   p1  = p[ix]
   nfiles = n_elements(lnR)

   plot, /nodata, p1, lnR, /ynoz, /xlog, $
      title = title, xthick=2, ythick=2, charsize=1.6, $
      xtitle = 'P!DBolo!N [W]', $
      ytitle = 'ln(R!DBolo!N) [ln(Ohm)]', $
      color = blo_color_get(fgcolor)

      oplot, p1, lnR,  $
         color = blo_color_get(fgcolor), psym=3	 

endif
end
