;===========================================================================
;  NAME: 
;		    bolodark_plot_lowP
;   
;  DESCRIPTION: 
;		    Plot the resistances at small Powers
;
;  USAGE: 
;		    bolodark_plot_lowP, struc
;
;
;  INPUT: 	
;    struc	    (struct) structure created by bolodark_headread_hfi_file
;    
;  OUTPUT: 
;		    plots   
;
;  KEYWORDS:
;    back	    (long) background color for plot			     
;    colors         (array long) array of color indices to be used	     
;    nmed	    (int) number of datapoints to include in median at low   
;		    powers						     
;    Rstar0	    (double) resulting value for Rstar (output!)	     
;    Tstar0	    (double) resulting value for Tstar (output!)	     
;    verbose	    set for more online comments			     
;    nolegend	    if set supresses printing of labels 		     
;
;  AUTHOR: 
;		    Ken Ganga(IPAC)
; 
;  Edition History:
;
;  Date    	Programmer  Remarks
;  ---------- ----------    -------
;  2002-08-08 	B. Schulz   converted to separate file version
;  2003-03-26 	B. Schulz   nolegend keyword added
;  2003-04-04 	B. Schulz   smaller characters for labels
;
;===========================================================================
;_
 
 pro bolodark_plot_lowP, struct, $
   back = back, colors = colors, nmed = nmed, $
   Rstar0 = Rstar0, Tstar0 = Tstar0, verbose = verbose, $
   nolegend=nolegend

   nfiles = struct.nfiles
   x = dblarr(nfiles)
   y = dblarr(nfiles)
   t_c = dblarr(nfiles)
   for ifile = 0L, nfiles-1L do begin
      index = sort(struct.(ifile+1L).p)
      t_c[ifile] = median(struct.(ifile+1L).T_c[index[0L:nmed-1L]])
      x[ifile] = 1.0d0/sqrt(t_c[ifile])
      y[ifile] = median(struct.(ifile+1L).lnR[index[0L:nmed-1L]])
   endfor
   xmin = min(x, max = xmax)
   ymin = min(y, max = ymax)
   plot, /nodata, [xmin, xmax], [ymin, ymax], /ynoz, $
      back = back, color = colors[0], $
      title = struct.bolo_label + ' at Low Power', $
      xtitle = 'T!U-1/2!N (K!U-1/2!N)', $
      ytitle = 'ln(R) (R in Ohms)'
   legendnames = strarr(nfiles)
   for ifile = 0L, nfiles-1L do begin
      oplot, [x[ifile]], [y[ifile]], psym = 4, color = colors[ifile]

      if NOT keyword_set(nolegend) then begin
        legendnames = strtrim(string(t_c, form='(f5.3)'),2)+' K'

      	; Find the temperature label
      	;parts = str_sep(struct.(ifile+1L).filename, get_ops_separator() )
      	;parts = str_sep(parts[n_elements(parts)-1L], 'dark')
      	;legendnames[ifile] = parts[0L]

      endif
   endfor
   textcolors = colors[0L]

   if NOT keyword_set(nolegend) then begin
     legend, legendnames, $
     	colors = colors[lindgen(nfiles)], $
     	psym = replicate(4L, nfiles), $
     	textcolors = textcolors, $
     	charsize = 0.8
   endif
   
   result = ladfit(x, y, /double)
   Rstar0 = exp(result[0L])
   Tstar0 = result[1L]^2
   v = 2.0d0*[0.0d0, xmax]
   oplot, v, result[0]+result[1]*v, color = colors[0]
   textcolors = colors[0]
   form_r0 = '(f9.2," Ohms        ")'
   form_t0 = '(f9.3," K           ")'

   thislabel = "R!D*!N = " + string(Rstar0,form=form_r0)
   thatlabel = "T!D*!N = " + string(Tstar0,form=form_t0)

   legend, thislabel + " " + thatlabel, $
      colors = colors[0], $
      line = 0, $
      textcolors = textcolors, $
      /bottom, /right, $
      charsize = 0.5

   ; Later
   return
end
