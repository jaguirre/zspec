;+
;===========================================================================
;  NAME: 
;		   BLO_DETCHOPFREQ
;
;  DESCRIPTION: 
;		   Determine chopper frequency from power spectrum
; 		   and write to output file
;
;  USAGE: 
;		   blo_detchopfreq, inpath, outfile
;  	
;  INPUT:
;    inpath	   (string) path to directory where power spectra files  
;		   are searched for.				         
;    outfile       (string) name of output file 		         
;		   will be written to <outpath> directory	         
;
;  OUTPUT:
;    		   ASCII file <outfile> with two columns: first column
;    		   is file name, second column is frequency in [Hz]
;    		   The program takes simply the highest point in the 
;    		   spectrum, excluding the very first point.
;    		   Frequency cutoff is at 0.3Hz
;	
;
;  KEYWORDS:
;    channame 	  (string) name of channel to be taken
;		  'POW CHAN 3-4' is taken as default
;
;  AUTHOR: 
;		   Bernhard Schulz (IPAC)
;
;
;  Edition History:
;
;  Date		Programmer	Remarks
;  2003/07/21   B.Schulz  	initial test version                            
;  2003/08/12   B.Schulz  	bug fix channel name recognition                
;
;
;===========================================================================
;-



pro blo_detchopfreq, inpath, outfile, channame=channame

if n_params() NE 2 then begin
  message, /info, 'Syntax:  blo_detchopfreq, <inpath>, <outfile>'
  message, /info, 'inpath:  string determining directory where power spectra are sought.'
  message, /info, 'outfile: name of output file
  return
endif
  


list = findfile(inpath+'*_pow.fits')

if NOT keyword_set(channame) then channame = 'POW CHAN 3-4'

nfiles = n_elements(list)

openw, un, outfile, /get_lun

for ifile=0, nfiles-1 do begin

  blo_noise_read_auto, list[ifile], run_info, sample_info, $
  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
  paramline=paramline, data=data

  ichan = (where(strtrim(colname1,2) EQ channame,cnt))[0]
  if cnt LT 0 then message, 'Channel name not found!'

  ix2 = where(data[0,*] GT 0.3) 			;apply frequency cutoff
  plot, data[0,ix2],data[ichan,ix2], psym=6, /xlog
 
  ix = where(data[ichan,ix2] GE max(data[ichan,ix2]), cnt)
  printf, un, drop_filepath(list[ifile]), data[0,ix2[ix[0]]], format = '(a28,f9.2)'

endfor

free_lun, un

end
