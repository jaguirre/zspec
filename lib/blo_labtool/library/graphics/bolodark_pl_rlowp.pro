;+
;===========================================================================
;  NAME: 
;		   bolodark_pl_rlowp
;
;  DESCRIPTION: 
;		   Plot ln(R) vs. T^-0.5 
;
;  USAGE: 
;		   bolodark_pl_rlowp, T_c, Rmin
;
;  INPUT: 	
;    T_c           (array float) temperature [K] 		 
;    Rmin          (array float) resistance at minimum power [P] 
;    
;  OUTPUT: 
;		   plot    
;
;  KEYWORDS: 
;     title	   A string varible containing the title of the plots  
;     afit	   If set, plot the fit results over the data	       
;
;  AUTHOR: 
;		   Bernhard Schulz
;	
; 
;  Edition History:
;
;  Date    	Programmer   Remarks
;  ----------   ----------   -------
;  2003-05-08 	B. Schulz    initial test version
;
;===========================================================================
;-

pro bolodark_pl_rlowp, T_c, Rmin, title=title, afit = afit

if NOT keyword_set(title) then title='R at Low Power'

ct = get_13colortable()
nct = n_elements(ct)
if !d.name EQ 'PS' then fgcolor = 'black' else fgcolor = 'white'


ix = where(Rmin GT 0, cnt)

if cnt GT 1 then begin

   T_c05 = T_c[ix]^(-0.5)
   lgRmin = alog(Rmin[ix])
   nfiles = n_elements(T_c05)

   plot, /nodata, T_c05, lgRmin, /ynoz, $
      title = title, $
      xtitle = 'T!U-1/2!N [K!U-1/2!N]', $
      ytitle = 'ln(R) [ln(Ohms)]', $
      color = blo_color_get(fgcolor), $
      xthick=2, ythick=2, charsize=1.6

   for ifile = 0, nfiles-1 do begin
      oplot, [1,1]*T_c05[ifile], [1,1]*lgRmin[ifile],  $
         psym = 6, color = blo_color_get(ct[ifile MOD nct]), symsize=0.6
   endfor

   if keyword_set(afit) then begin
     oplot, T_c05, afit[0] + afit[1]*T_c05, linestyle=1, $
     		color=	blo_color_get('magenta')
   endif

endif
end
