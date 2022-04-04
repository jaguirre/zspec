;+
;===========================================================================
;  NAME: 
;		   BLO_SINE2_START
;
;  DESCRIPTION: 
;		   Derive estimates of frequency and amplitude   
;		   from sampled double sine signal and provide   
;  		   switch flags 			         
;
;
;  USAGE: 
;		   blo_sine_start, time, sig, frequ, ampl, phase, $
;		     offset, swfreq, swphase
;
;  INPUT:
;    time	  (array float) time				       
;    sig     	  (array float) sine signal			       
;
;  OUTPUT:
;	flg       (array int) flagarray,   1 = first sine wave	       
;		 			   2 = second sine wave       
;    frequ   	  (float) frequency				       
;    ampl	  (float) estimate of amplitude 		       
;    phase   	  (float) phase (0..1), multiply by 2*!PI or 360 to    
;		   get angle 					       
;    offset  	  (float) zero offset 				       
;    swfreq  	  (float) switch frequency			       
;    swphase 	  (float) phase of switch frequency		       
;
;
;   AUTHOR: 
;		   Bernhard Schulz (IPAC)
;
;
;   Edition History:
;
;   Date	 Author	     Remarks
;   04/10/2002	 B.Schulz    initial test version   		       
;   07/10/2002	 B.Schulz    output flag array	    		       
;
;
;=================================================================
;-
pro blo_sine2_start, time, sig, flg, frequ, ampl, phase, offset, swfreq, swphase


nsig = n_elements(sig)

ampl = (max(sig)-min(sig))/2.d			;Amplitude
offset = mean(sig)				;Zero offset
signal = sig - offset				;subtract offset

dsignal = signal - shift(signal,+1)
;plot, dsignal, psym=3, xrange=[0,5000]

swipos = blo_clipsigma(dsignal, 2.)

;plot, swipos, ystyle=3, psym=10, xrange=[0,300]

dt = (time(nsig-1)-time(0))/(nsig-1)	;sampling interval

;ix1 = where(swipos GT 0)
;plot, dsignal(ix1), psym=3
;sigswitch = stddev(abs(dsignal(ix1)))		;typical switch

;ix2 = where(swipos LE 0)
;plot, dsignal(ix2), psym=3
;sigstep = stddev(abs(dsignal(ix2)))		;typical step


;--------------------------------------------------------------
ix = where(swipos GT 0, cnt)		; switches


if cnt GT 1 then begin

  switchtim = time(ix)
  deltas = switchtim - shift(switchtim,1)      ;switch time intervals
  delta = median(deltas(1:*))                  ;switch interval in time

  swfreq = 1./(2*delta)
  swphase = deltas(1)/(2*delta)
  if dsignal(1) GT 0 then swphase = 0.5-swphase

  ngroup = round(delta / dt)         ;number of points in one signal group

  if ngroup GE 2 then begin
    blo_sineworm, time, signal, swipos, ngroup, flg

    ix1 = where(flg GT 0)

    ; clean sine wave from transient signals between switches
    x = blo_clipsigma(signal(ix1)-smooth(signal(ix1),ngroup), 2)

    ix2 = where(x LE 0)
    ix3 = ix1(ix2)
    ;plot, signal(ix3)-smooth(signal(ix3),ngroup)

    flg = flg * 0       ;clean up flag array
    flg(ix3) = 1

    ; get missing startparameters
    blo_sine_start, time(ix3), sig(ix3), frequ, ampl, phase, offset
  endif else begin
    frequ= 0.              ;Error
    ampl= 0.
    phase= 0.
    offset = 0.
    swfreq = 0.
    swphase = 0.
    flg = 0.
  endelse
  
  ;print, frequ, ampl, phase, offset, swfreq, swphase


  ;fnyquist = 1./(time(3)-time(0))        ;Nyquist Frequency
  ;if frequ GT 0 and frequ LE fnyquist and ampl GT 0.001 then begin
  ;    a = [frequ, ampl, phase, offset]
  ;    weights = signal(ix1) * 0.d + 1.
  ;    yfit = CURVEFIT(time(ix1), signal(ix1), weights, a, sigma, $
  ;				function_name='blo_sine_func')
  ;endif

  ;frequ= a(0)
  ;ampl=a(1)
  ;phase=a(2)
  ;offset = a(3)

;--------------------------------------------------------------
endif else begin

  frequ= 0.			;Error
  ampl= 0.
  phase= 0.
  offset = 0.
  swfreq = 0.
  swphase = 0.
  flg = 0.
endelse
;--------------------------------------------------------------

end
