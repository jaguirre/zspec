;+
;============================================================================
;
;  NAME: 
;		   bolo_linestrength
; 
;  DESCRIPTION:    
;		   Calculate line intensity in frequency interval of power 
;		     spectrum
;
;  USAGE: 
;		   bolo_linestrength, interval
;
;
;  INPUT:         							    
;    interval      2 element array defining frequency interval where line   
;		   is evaluated format: [start, end] in Hz		    
;
;  OUTPUT:          
;     		   listing of line intensities
; 
;
;  KEYWORDS:
;    noplot	   if set no plots are generated (fast) 		    
;    overwrite	   if set no check is performed whether output file exists  
;		   and existing files are overwritten (Caution!)	    
;    selpix 	   if set only selected channels are used
;    filelist	   If set, use this filelist. Otherwise, pick files from    
;                  diaglog						    
;
;  Example:
;	blo_linestrength, [29.0,31.0], /noplot
;
;
;  Edition History:
;
;  Date		Programmer	Remarks
;  2003/05/14 	B. Schulz 	initial test version
;  2003/05/19 	B. Schulz 	'FREQ' as label identifying power spectra
;  2003/05/19 	B. Schulz 	good pixel keyword added
;  2003/06/10 	B. Schulz 	filelist keyword added
;  2003/06/10 	B. Schulz 	fixed bug in good pixel selection
;  2003/06/12 	B. Schulz 	fine tuning and bug fixes
;  2003/06/21 	B. Schulz 	set min # of datapoints to 5 for gaussfit
;  2003/08/12 	B. Schulz 	channel name comparison fixed
;  2003/10/01   L. Zhang        Add an outputPath keyword to give the 
;                               flexibility for output location
;  2003/10/22   L. Zhang        Calling blo_getgoodpix with path
; 	                        Add inPath keyword
;  2003/12/15   L. Zhang        Remove the inpath keyword
;  2004/06/03   B. Schulz       made selpix keyword not set possible 
;				excluded 0 Hz datapoints
;                               changed goodpix to selpix
;=====================================================================
;-

pro bolo_linestrength, interval, noplot=noplot, overwrite=overwrite,  $
			selpix=selpix, filelist=filelist, outputPath=outputPath

if n_params() NE 1 then begin
  message, /info, 'Syntax Error!  Usage: blo_linestrength, <interval> '
  return 
endif

if NOT keyword_set(filelist) then $
  filelist = dialog_pickfile( /MULTIPLE_FILES, $
                 /READ, /MUST_EXIST, FILTER = '*_pow.fits', $
                         GET_PATH=path, path=getenv('BLO_DATADIR'))



if filelist[0] EQ '' then begin
  message, /info, 'No files selected!'
  return
endif

blo_sepfilepath, filelist[0], filename, path

if keyword_set(selpix) then $ 			;selected pixel labels
   blo_read_selected_channel, path=path, $
     channel_name=selpx

;------------------------------------------------
; loop over all selected files

nfiles = n_elements(filelist)

for fi = 0, nfiles-1 do begin 

  infile = filelist[fi]

  blo_sepfilepath, infile, filename, path
  blo_sepfileext, filename, name, extens

  
  if NOT keyword_set(outputPath) then outputPath=path
  
  outfile = outputPath+name+'_pk'+  $
    string(fix(avg(interval)*10),form='(i4.4)' ) + '.txt'

  blo_noise_read_auto, infile, run_info, sample_info, $
            colname1, colname2, npts, ScanRateHz, SampleTimeS, $
            paramline=paramline, $
            data=data                           ;read data

  if strpos(strupcase(colname1[0]), 'FREQ') LT 0 then begin
    message, /info, 'File contains no power spectrum! Continuing with next file...'
  endif else begin

  ;------------------------------------------------
    ncol = n_elements(data[*,0])

    ;First column is frequcy column
    ixint = where( data[0,*] GE interval[0] AND $	;pointer to data
    		   data[0,*] LE interval[1] AND $	;within interval
    		   data[0,*] GT 0, cnt)			;within interval

    freq = reform(data[0,ixint])		;select frequency vector

    
   ;------------------------------------------------
   ; verify output filename
   
    if NOT keyword_set(overwrite) then begin
      checkfile = findfile(outfile)	      ;check for existing filename
      if checkfile(0) NE '' then begin
        blo_savename_dialog, fpath=path, extension='txt', outfile, $
        		  title='Name Conflict!', file=outfile
      endif
    endif
    if outfile EQ '' then return

   ;------------------------------------------------
   ; prepare output file
   
    openw, unit, outfile, /get_lun
    
    print, 'Processing: '+filename+', Outfile: '+outfile

    printf, unit, 'Derived from: '+filename
    printf, unit, 'Interval: '+string(interval[0])+' to '+string(interval[1])
    printf, unit
    printf, unit, 'label', 'freq', 'peak', 'gfrequ', 'gpeak', 'gwidth', 'gbase', $
      		form='(a14,x,a7,x,a10,x,a7,x,a10,x,a10,x,a10)'
    printf, unit, '----------------------------------------------------------------------------', $
      		form='(a)'


   ;------------------------------------------------
   ; loop over channels
   
    for icol = 1, ncol-1 do begin

      label = colname1[icol]

   ;------------------------------------------------
   ; check if good pixel if keyword set

      cnt = 0
      if keyword_set(selpix) then $
        ix = where(strtrim(strupcase(label),2) EQ selpx, cnt)

      if cnt GT 0 OR NOT keyword_set(selpix) then begin

   ;------------------------------------------------
   ;select data within interval
   
      	dat = reform(data[icol,ixint])	 
        ixdg = where(blo_clipsigma(dat, 2.5) EQ 0)
        
        nse = stddev(dat[ixdg])		 ;determine BG noise level
        bglvl  = median(dat[ixdg])		 ;background level
         
      	ix = reverse(sort(dat)) 	 ;find maximum
      	mxlevel = dat[ix[0]]
      	mxfreq  = freq[ix[0]]

      	if NOT keyword_set(noplot) then begin
      	  plot, freq, dat, psym=4, xrange=interval, $
      	    xtitle='frequency', ytitle='signal', charsize=1.6, $
	    xthick=2, ythick=2, title=filename+' '+label

      	  oplot, [1,1] * mxfreq, [0,mxlevel], linest=3
      	endif

   ;------------------------------------------------
   ; try gaussfit and determine line width
   
        delta_frequ = freq[1]-freq[0]	        ;frequency difference
        dinterval   = interval[1]-interval[0]	;interval size

        estimates=[mxlevel,mxfreq,delta_frequ,bglvl]	;initial guess
   
        b = -1			;set b in case it doesn't get set later

      	if min(dat) NE max(dat) AND n_elements(dat) GE 5 then $	 ;do gaussfit
      	  b = gaussfit(freq, dat, a, nterms=4, estim=estimates) $
        else a = [0,0,0,0]		;indicator for failed gauss fit
        a[2] = abs(a[2])		;ensure positive width

	;c=get_kbrd(1)
      	print, label, mxfreq, mxlevel, a[1], a[0], a[2], a[3], $
      		  form='(a14,x,f8.4,x,e10.3,x,f8.4,x,e10.3,x,e10.3,x,e10.3)'


        if a[0]-bglvl LT nse*3 OR $ 			;failure conditions
	   a[1] LT interval[0] + 2*delta_frequ OR $
	   a[1] GT interval[1] - 2*delta_frequ OR $
	   finite(total(a)) EQ 0 OR $
	   abs(a[2]) LT delta_frequ / 3. THEN begin
	      a = [0,0,0,0]      
              ;message, /info, 'Gaussfit failed! '+string(icol)+' '+infile
        endif

        if n_elements(b) GT 1 AND $		;plot if gaussfit worked
	            a[2] GT 0 $
		    then begin
     	  if NOT keyword_set(noplot) then $
      	    oplot, freq, b, linestyle=2
      	endif



   ;------------------------------------------------
   ; if first gaussfit worked but width is very small or didn't
   ; work at all

        nwidths = 5	;new interval in number of linewidths
	nminpnts = 8	;new interval: number of minimum points on each side

        if a[0] EQ 0 OR a[2] LT delta_frequ/3 then begin

	  exp_cfreq = interval[0]+dinterval/2.	      ;expected center frequ.

          ix1 = where(freq GT exp_cfreq-nwidths*a[2] AND $   ;select data
	  	      freq LT exp_cfreq+nwidths*a[2])

          if n_elements(ix1) LT 2*nminpnts then begin  ;assure min. # of data
            ix1 = where(freq GT exp_cfreq-nminpnts*delta_frequ AND $
	  	        freq LT exp_cfreq+nminpnts*delta_frequ)
          endif
	  
          dat1 = dat[ix1]
	  freq1 = freq[ix1]

      	  ix2 = reverse(sort(dat1)) 	 ;find maximum
      	  mxlevel = dat1[ix2[0]]
      	  mxfreq  = freq1[ix2[0]]

          estimates=[mxlevel,mxfreq,delta_frequ,bglvl]  ;initial guess
          if min(dat1) NE max(dat1) AND n_elements(dat1) GT 4 then $	 ;do gaussfit
            b = gaussfit(freq1, dat1, a, nterms=4, estim=estimates) $
          else a = [0,0,0,0]		;indicator for failed gauss fit

       	  print, label, mxfreq, mxlevel, a[1], a[0], a[2], a[3], $
      		  form='(a14,x,f8.4,x,e10.3,x,f8.4,x,e10.3,x,e10.3,x,e10.3)'

          a[2] = abs(a[2])		;ensure positive width

          if a[0]-bglvl LT nse*3 OR $			  ;failure conditions
	     a[1] LT interval[0] + 2*delta_frequ OR $
	     a[1] GT interval[1] - 2*delta_frequ OR $
	     finite(total(a)) EQ 0 OR $
	     abs(a[2]) LE 0 THEN begin
	  	a = [0,0,0,0]	   
          	message, /info, 'Gaussfit failed (2nd)! '+string(icol)+' '+infile		
          endif


        endif else begin
	  freq1 = freq
	  dat1 = dat
	endelse
       

      	if NOT keyword_set(noplot) then begin
      	  plot, freq, dat, psym=4, xrange=interval, $
      	    xtitle='frequency', ytitle='signal', charsize=1.6, $
	    xthick=2, ythick=2, title=filename+' '+label

      	  oplot, [1,1] * mxfreq, [0,mxlevel], linest=3
      	endif

        if n_elements(b) GT 1 $		;plot if gaussfit worked
		    then begin
     	  if NOT keyword_set(noplot) then $
      	    oplot, freq1, b, linestyle=2
      	endif

      	printf, unit, label, mxfreq, mxlevel, a[1], a[0], a[2], a[3], $
      		  form='(a14,x,f8.4,x,e10.3,x,f8.4,x,e10.3,x,e10.3,x,e10.3)'
      	;print, label, mxfreq, mxlevel, a[1], a[0], a[2], a[3], $
      	;	  form='(a14,x,f8.4,x,e10.3,x,f8.4,x,e10.3,x,e10.3,x,e10.3)'

      	if NOT keyword_set(noplot) then wait, 0.2

	;c=get_kbrd(1)

      endif		;if good pixel 
    endfor		;loop over channels icol
   ;------------------------------------------------
   ;close output file
   
    free_lun, unit
    
  ;------------------------------------------------
  endelse

endfor

end
