;========================================================================
; NAME		:   bolo_linestrength_20040926_10mv
;
; DESCRIPTION	:  derive linestrength files from fourier spectra of 
;		   chopped observations
; 
; 2004/09/30    : B. Schulz
;
; NOTE		:  This is time constant data reduction STEP 4
;========================================================================

pro bolo_linestrength_20040926_10mv

  path = '/data1/SPIRE_PFM_PMW2/20040926/10mV/'

  logfname = path+'20040926_10mV_frequ.txt'
  readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent

  nf = n_elements(lg_fname)
  lg_fname = strcompress(lg_fname,/rem)

  for i=0, nf-1 do begin 

       filelist = findfile(path+lg_fname[i])

       dfrequ = 0.9	;1/2 frequency interval in [Hz]

       interval = lg_cfrequ[i] + [-dfrequ, dfrequ]

       bolo_linestrength, interval,   $
     			      /selpix, filelist=filelist, outputPath=path, /overwrite
  endfor

end
