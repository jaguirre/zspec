;+
;===========================================================================
;  NAME: 
;		   bolodark_plot_lnRvsP
;
;  DESCRIPTION: 
;		   Plot the resistance versus power
;
;  USAGE: 
;		   bolodark_plot_lnRvsP, struc 
;
;
;  INPUT: 	
;    struc	   (struct) structure created by bolodark_headread_hfi_file
;    
;  OUTPUT: 
;		   plot    
;
;  KEYWORDS:
;    back	   background color	      
;    colors	   color table  	      
;    verbose	   set verbose mode	      
;    nolegend	   suppress plotting of legend
;
;  AUTHOR: 
;		   Ken Ganga(IPAC)
; 
;  Edition History:
;
;  Date    	Programmer  Remarks
;  ---------- 	----------  -------
;  2002-08-08 	B. Schulz   converted to separate file version
;  2003-03-26 	B. Schulz   nolegend keyword added
;
;-------------------------------------------------------------------
;-

pro bolodark_plot_lnRvsP, struct, nolegend=nolegend, $
   back = back, colors = colors, verbose = verbose

   nfiles = struct.nfiles			;number of files
   
   pmin =  1.0d30
   pmax = -1.0d30
   lnRmin =  1.0d30
   lnRmax = -1.0d30
   for ifile = 0L, nfiles-1L do begin
      pmin = min([pmin, struct.(ifile+1L).p])
      pmax = max([pmax, struct.(ifile+1L).p])
      lnRmin = min([lnRmin, struct.(ifile+1L).lnR])
      lnRmax = max([lnRmax, struct.(ifile+1L).lnR])
   endfor
   plot, /nodata, [pmin, pmax], [lnRmin, lnRmax], /xlog, /ynoz, $
      title = struct.bolo_label, $
      xtitle = 'P!DB!N (W)', $
      ytitle = 'ln(R!DB!N) (R!DB!N in Ohm)', $
      color = colors[0], back = back

   legendnames = strarr(nfiles)
   for ifile = 0L, nfiles-1L do begin
      oplot, struct.(ifile+1L).p, struct.(ifile+1L).lnR, $
         psym = 3, color = colors[ifile]

      if NOT keyword_set(nolegend) then begin
      ; Find the temperature label
      	parts = str_sep(struct.(ifile+1L).filename, get_ops_separator() )
      	parts = str_sep(parts[n_elements(parts)-1L], 'dark')
      	legendnames[ifile] = parts[0L]
      endif
   endfor
   textcolors = colors[0L]
   if NOT keyword_set(nolegend) then $
     legend, legendnames, $
     	colors = colors[lindgen(nfiles)], $
     	lines = replicate(0L, nfiles), $
     	textcolors = textcolors, /bottom, $
     	charsize = 0.8


   ; Later
   return
end
