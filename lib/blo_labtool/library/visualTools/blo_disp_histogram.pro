;+
;===========================================================================
;  NAME: 
;		    BLO_DISP_HISTOGRAM
;
;  DESCRIPTION: 
;		    calculate histogram of signals and display in separate 
; 		      graphics window
;
;  USAGE: 
;		    blo_disp_histogram, volts
;  
;
;  INPUT:
;      data	    (array double) data(channel, signal)
;      chan
;
;  OUTPUT:
;	categ 	    (array double) categories of histogram
;	histog	    (array double) number counts of histogram
;		    new graphics screen with plot of histogram and 
;		    OK widget to terminate
;
;  KEYWORDS:
;	question     (string) string will be displayed and
;		     answer will be returned 'Yes' or 'No' 
;
;  AUTHOR: 
;		    Bernhard Schulz (IPAC)
;
;
;  Edition History:
;
;  24/09/2002	initial test version			B.Schulz
;  11/10/2002	question keyword added			B.Schulz
;  14/10/2002	changed categ. to 12 bit resolution	B.Schulz
;
;
;===========================================================================
;-

pro blo_disp_histogram, data, chan, categ, histog, question=question

winmem = !D.WINDOW		;save drawing # of window
window, /free, title='Histogram', xsize=600, ysize=600	;make drawing window
wincur = !D.WINDOW		;current window 

volts = data(chan,*)	;pick channel

nvolts = long(n_elements(volts))

n_bins = 2L^12L				;number of histogram categories
nchan = n_elements(data(*,0))	;number of channels

hmax = 10.				;maximum histogram signal [V]
hmin = -10.				;minimum histogram signal [V]

histog = histogram(volts,min=hmin, max=hmax, nbins=n_bins)
categ = (indgen(n_bins)+0.5)/n_bins*(hmax-hmin)+hmin

plot, categ, histog, psym=10, title='Histogram', xtitle='volts', $
  xrange=[min(volts), max(volts)], xstyle=3, color=blo_color_get('white')

dystr = 0.05
sypos = 0.9
sxpos = 0.2
form = '(f7.4)'
xyouts, sxpos, sypos-1*dystr,/normal, 'Avg:     '+string(mean(volts),form=form)
xyouts, sxpos, sypos-2*dystr,/normal, 'Stdev:   '+string(stdev(volts),form=form)
xyouts, sxpos, sypos-3*dystr,/normal, 'Max:     '+string(max(volts),form=form)
xyouts, sxpos, sypos-4*dystr,/normal, 'Median:  '+string(median(volts),form=form)
xyouts, sxpos, sypos-5*dystr,/normal, 'Min:     '+string(min(volts),form=form)


if keyword_set(question) then begin
  question = dialog_message(question,/default_no, /question)
  if question EQ 'Yes' then begin
    histog = dblarr(nchan, n_bins)	;calculate all histograms if yes
    for i=0, nchan-1 do begin
      histog(i,*) = histogram(data(i,*), min=hmin, max=hmax, nbins=n_bins)
    endfor
  endif
  
endif else begin
  x = dialog_message("Click 'OK' to continue!")
endelse

wdelete, wincur
wset, winmem   ;set back to previous drawing window 

end
