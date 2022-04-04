;========================================================================
; NAME		:   bolo_linestrength_20040716_6mv
;
; DESCRIPTION	:  derive linestrength files from fourier spectra of 
;		   chopped observations
; 
; 2004/08/04    : B. Schulz
;
; NOTE		:  This is time constant data reduction STEP 4
;========================================================================

pro bolo_linestrength_20040716_6mv

  path = '/data1/SPIRE_PFM_PMW/20040716/6mV/'

  logfname = path+'20040716_6mV_frequ.txt'
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
