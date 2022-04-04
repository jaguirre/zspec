;=======================================================================
; derive linestrength files from fourier spectra of chopped observations
;=======================================================================

pro bolo_linestrength_20031007_svsbias

  path = '/data1/SPIRE_PFM_SLW/20031007/SvsBias/'

  logfname = path+'20031007_SvsBias_frequ.txt'
  readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent

  nf = n_elements(lg_fname)

  for i=0, nf-1 do begin 

       if      lg_cfrequ[i] LT 2  then resol = 0.4 $
       else if lg_cfrequ[i] LT 6  then resol = 0.2 $
       else if lg_cfrequ[i] LT 30 then resol = 0.1 $
       else			       resol = 0.025

       filelist = findfile(path+lg_fname[i])
       interval = lg_cfrequ[i]*[1-resol, 1+resol]

       bolo_linestrength, interval,   $
     			      /goodpix, filelist=filelist, outputPath=path, inPath=path, /overwrite
  endfor

end
