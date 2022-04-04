;+
;===========================================================================
;
;  NAME: 
;		  BLO_GAINS
;	
;  DESCRIPTION: 
;		  Determine amplitude ratios of sine signals and switched 
;		  last channel
;
;  USAGE: 
;		  blo_gains, data, switchsine=switchsine
;
;  INPUT:
;     data	  (array float) data array, first column is time in [sec], 
;    		  other columns are sine wave signals, last channel	   
;    		  is reference channel. 				   
;
;  OUTPUT:
;    		  on screen display of text in window
;    		  gain factors can be saved into TAB separated DASgains.txt file
;
;  KEYWORDS:
;    switchsine   if set switched double sine signal is expected in 	   
;   		  last channel, otherwise normal sine expected everywhere  
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  02/10/2002	initial test version			B.Schulz
;  07/10/2002	added switched sine eval.		B.Schulz
;  09/10/2002	first fit one sine period then all	B.Schulz
;  09/10/2002	avg. of both parts of sw sine		B.Schulz
;  30/10/2002	changed eigenfrequency limit to 5	B.Schulz
;
;
;===========================================================================
;-	
pro blo_gains, data, switchsine = switchsine


;-------------------------------------------------------
;ndisp = 40		;number of displayed datapoints
form1 = '($, e13.6)'
form2 = '($, "'+string(9b)+'", e13.6)'
form3 = '($, "'+string(9b)+'", f3.1)'
form4 = '(i6,f10.6,x,f10.6,x,f10.6,x,f10.6,x,f10.6)'
form5 = '(a6,x,a10,x,a10,x,a10,x,a10,x,a10)'
form6 = '(i6,x,a10,x,a10,x,a10,x,a10,x,a10)'
nanstr = '     -    '

frequ_limit = 2.			;upper frequency limit
ampl_limit = 0.001			;amplitude limit
feigen_limit = 5.			;lower frequency limit

;-------------------------------------------------------

data = double(data)
time = reform(data(0,*))

ncols = n_elements(data(*,0))-1		;number of columns
nsig  = n_elements(time)				;number of signals

fnyquist = 1./(time(3)-time(0))		;Nyquist Frequency
feigen   = 1./(time(nsig-1)-time(0))	;Eigenfrequency of dataset

pararr = dblarr(ncols,4)				;storage for parameters


;-------------------------------------------------------
for col = 0, ncols-1 do begin

  signal = reform(data(col+1,*))		;extract signal to work on
  time = reform(data(0,*))


  if keyword_set(switchsine) AND col EQ ncols-1 then begin

    blo_sine2_start, time, signal, flg, frequ, ampl, $	;on last channel only
               phase, offset, swfreq, swphase   ;get switched sine start params
    ixsw1 = where(flg GT 0)
    ixsw2 = where(flg LE 0)
    
  endif else begin

    blo_sine_start, time, signal, frequ, ampl, phase, offset	;get start params

  endelse

;print, "Start ", frequ, ampl, phase, offset

;-------------------------------------------------------
  if frequ GT feigen*feigen_limit and frequ LE fnyquist/frequ_limit $
  		and ampl GT ampl_limit then begin
  
    a = [frequ, ampl, phase, offset]		;vector of start parameters
    weights = signal * 0.d + 1.			;generate weights for fit
    len1 = 1/frequ					;take one period only for first fit


    if keyword_set(switchsine) AND col EQ ncols-1 then begin
      signal1 = signal(ixsw1)
      time1  = time(ixsw1)
      weights1 = weights(ixsw1)
    endif else begin
      signal1 = signal
      time1  = time
      weights1 = weights
    endelse

    ix = where(time1 LE 1/frequ)

    yfit = CURVEFIT(time1(ix), signal1(ix), weights1(ix), a, sigma, $ ;do nonlinear fit
    						function_name='blo_sine_func')

								;now take everything
    yfit = CURVEFIT(time1, signal1, weights1, a, sigma, $		;do nonlinear fit
    						function_name='blo_sine_func')

    if keyword_set(switchsine) AND col EQ ncols-1 then begin

      b = a
      b(2) = b(2)+0.5
      if b(2) GT 0.5 then b(2) = b(2) - 1

      signal1  = signal(ixsw2)
      time1    = time(ixsw2)
      weights1 = weights(ixsw2)

      yfit = CURVEFIT(time1, signal1, weights1, b, sigma, $		;do nonlinear fit
    						function_name='blo_sine_func')

      b(2) = b(2)+0.5		;move phase back
      if b(2) GT 0.5 then b(2) = b(2) - 1

      a = (a + b) / 2.		;average

    endif


    frequ  = a(0)
    ampl   = a(1)
    phase  = a(2)
    offset = a(3)		;vector of start parameters

; check again if valid
    if frequ LE feigen*feigen_limit or frequ GT fnyquist/frequ_limit $
    		or ampl LE ampl_limit then begin

      pararr(col,*) = [!VALUES.F_NAN, !VALUES.F_NAN, !VALUES.F_NAN, !VALUES.F_NAN]
    endif else begin
      pararr(col,*) = a         ;save parameters in storage for results
    endelse

  endif else begin
    pararr(col,*) = [!VALUES.F_NAN, !VALUES.F_NAN, !VALUES.F_NAN, !VALUES.F_NAN]
  endelse

endfor

;----------------------------------------------------------------------

textarr = strarr(ncols)				;storage for output listing
for col = 0, ncols-1 do begin

  if finite(pararr(col,0)) then begin
    textarr(col) = string(col+1, pararr(col,0), pararr(col,1), $
                     pararr(col,2), pararr(col,3), $
                     pararr(col,1)/pararr(ncols-1,1), form=form4)
  endif else begin
    textarr(col) = string(col+1, nanstr, nanstr, nanstr, $
    						   nanstr, nanstr, form=form6)
  endelse

endfor
textarr = [string('Chan.', 'Frequ.', 'Ampl.', 'Phase', 'Offs.', 'Gain', $
			form=form5), $
           string('', '[Hz]', '[V]', '', '[V]', '', $
			form=form5), $
               textarr]


blo_textout, textarr, title='Sine Fit Parameters for all Channels'


gains = dblarr(ncols)
gains = pararr(0:ncols-1,1) / pararr(ncols-1,1)

outfile = dialog_pickfile( $
           			/write, file='DASgains.txt', FILTER = '*.txt', $
					GET_PATH=path, path=getenv('BLO_DATADIR') )

if outfile(0) EQ '' then begin

  message, /info, "No file selected!"

endif else begin
  checkfile = findfile(outfile)
  if checkfile(0) NE '' then begin
  x = dialog_message("Do you want to overwrite the file "+checkfile, /cancel )
  endif else x = 'OK'

  if x EQ 'OK' then begin

    print, "Saving file: ", outfile
    openw, un, outfile, /get_lun
    printf, un, 1.0, format=form1		;for first time column
    for i=0, ncols-1 do begin
      if finite(gains(i)) then 	printf, un, gains(i), format=form2 $
      else					printf, un, 1.0, format=form3		
    endfor
    printf, un
    free_lun, un
    
  endif else begin

    print, "No file saved!"
   
  endelse
  
endelse
 


end
