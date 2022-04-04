;+
;===========================================================================
;  NAME:
; 	         blo_chrnsespec
;
;  DESCRIPTION: 
;                determine and print averages for a series of 4
;                intervals in noise spectrum
;
;  USAGE:
;                blo_chrnsespec, infile, outfile, intervals
;
;  INPUT: 	
;     infile      string) name of input file
;     outfile     (string) name of output file
;     intervals   (float array) intervals for averaging
;                 array has structure [0:1,0:nintvl], where first index
;                 determines 0: from value, 1: to value, and
;                 second index determines the interval
;
;  OUTPUT:	
;                 ASCII file with channel number, channel name, center 
;                 frequency,average value for each interval 
; 
;  KEYWORDS:
;       goodpix   If set, only the good pixles are taken 
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
; 
; 
;  Edition History:
;
;  Date    	Programmer  Remarks
;  ----------   ----------  -------
;  2003-08-07 	B. Schulz   initial version
;  2003-12-19   L. Zhang    Add goodpix keyword and rewrote part of the 
;                           program
;
;===========================================================================
;-
pro blo_chrnsespec, infile, outfile, intervals, goodpix=goodpix



blo_noise_read_auto, infile, run_info, sample_info, $
            colname1, colname2, npts, ScanRateHz, SampleTimeS, $
            paramline=paramline, $
            data=data                           ;read data

npix = n_elements(data[*,0])            ;number of pixels
nint = n_elements(intervals[0,*])       ;number of intervals

avgs = fltarr(3,nint,npix)              ;prepare output array

for ipix=0, npix-1 do $
  avgs[*,*,ipix] = blo_intvlavg(reform(data[0,*]), reform(data[ipix,*]), intervals)

blo_sepfilepath, infile, fname, path

if keyword_set(goodpix) then begin
    goodpx=blo_getgoodpix(path=path)
endif


openw, un, outfile, /get_lun
printf, un, 'Averaged Intervals in Power Spectrum'
printf, un, fname
printf, un, systime()
form1 = '(a5,x,f8.2,x,f8.2,x,f8.2,x,f8.2)'
printf, un, "from", intervals[0,0], intervals[0,1], intervals[0,2], intervals[0,3], form=form1
printf, un, "to",   intervals[1,0], intervals[1,1], intervals[1,2], intervals[1,3], form=form1
printf, un

printf, un, "pix","label", avgs[1,0,0], avgs[0,1,0], avgs[0,2,0], avgs[0,3,0], $
                             format='(a3,x,a12,x,f8.2,x,f8.2,x,f8.2,x,f8.2)'
printf, un, " ", " ", "Hz", "Hz","Hz","Hz", $
                             format='(a3,x,a12,x,a8,x,a8,x,a8,x,a8)'
printf, un, "----------------------------------------------------"

for ipix=1, npix-1 do begin 
     label=colname1[ipix]
     cnt=0
     if keyword_set(goodpix) then begin
         ix = where(goodpx EQ strtrim(strupcase(label),2), cnt)
     endif 
     if (cnt GT 0 or NOT keyword_set(goodpix) ) then begin 
     	printf, un, ipix, label, avgs[1,0,ipix], avgs[1,1,ipix], $
     				avgs[1,2,ipix], avgs[1,3,ipix], $
     				format='(i3,x,a12,x,e8.2,x,e8.2,x,e8.2,x,e8.2)'
     endif 


   ; printf, un, ipix, colname1[ipix], avgs[1,0,ipix], avgs[1,1,ipix], $
    ;                         avgs[1,2,ipix], avgs[1,3,ipix], $
    ;                         format='(i3,x,a12,x,e8.2,x,e8.2,x,e8.2,x,e8.2)'

endfor
free_lun, un

end
