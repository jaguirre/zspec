;===========================================================================
;  NAME: 
;		   bolodark_plot_loadcurve
;  
;  DESCRIPTION: 
;		   Plot the load curve
;
;  USAGE: 
;		   bolodark_plot_loadcurve, struct
;
;
;  INPUT: 	
;    struct	   (struct) structure created by bolodark_headread_hfi_file
;    
;  OUTPUT: 
;		   plot    
;
;
;  AUTHOR: 
;		   Ken Ganga(IPAC)
; 
;  Edition History:
;
;  Date    	Programmer  Remarks
;  ----------   ----------  -------
;  2002-08-08 	B. Schulz   converted to separate file version
;  2003-03-26 	B. Schulz   nolegend keyword added
;
;===========================================================================
;-
pro bolodark_plot_loadcurve, struct, nolegend=nolegend, $
   back = back, colors = colors, verbose = verbose

   ; Plot the load curves
   nfiles = struct.nfiles
   imax = -1.0d30
   imin =  1.0d30
   emax = -1.0d30
   emin =  1.0d30
   for ifile = 0L, nfiles-1L do begin
      imax = max([imax, struct.(ifile+1L).bias])
      imin = min([imin, struct.(ifile+1L).bias])
      emax = max([emax, struct.(ifile+1L).bolo])
      emin = min([emin, struct.(ifile+1L).bolo])
   endfor
   imax = max(abs([imax, imin]))
   imin = -imax
   emax = max(abs([emax, emin]))
   emin = -emax
   plot, /nodata, [imin, imax], [emin, emax], $
      title  = struct.bolo_label, $
      xtitle = 'I!DB!N (A)', $
      ytitle = 'V!DB!N (V)', $
      back = back, color = colors[0]
   legendnames = strarr(nfiles)
   for ifile = 0L, nfiles-1L do begin
      oplot, struct.(ifile+1L).bias, struct.(ifile+1L).bolo, $
      color = colors[ifile], psym = 3
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
     	textcolors = textcolors, $
     	charsize = 0.8

   oplot, 2.0d0*[imin, imax], [0.0d0, 0.0d0], line = 1, color = colors[0]
   oplot, [0.0d0, 0.0d0], 2.0d0*[emin, emax], line = 1, color = colors[0]

   ; Later
   return


end

