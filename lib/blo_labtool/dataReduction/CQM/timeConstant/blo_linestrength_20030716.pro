; derive linestrength files from fourier spectra of chopped observations

pro blo_linestrength_20030716

path = '/data1/SPIRE_CQM/20030716/'

logfname = path+'20030716_frequ.txt'
readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent
nf = n_elements(lg_fname)


for i=0, nf-1 do begin 

  ;if      lg_cfrequ[i] LT 2  then resol = 0.4 $
  ;else if lg_cfrequ[i] LT 5  then resol = 0.2 $
  ;else if lg_cfrequ[i] LT 30 then resol = 0.1 $
  ;else                            resol = 0.025

  if      lg_cfrequ[i] LT 2  then resol = 0.4 $
  else if lg_cfrequ[i] LT 5  then resol = 0.2 $
  else if lg_cfrequ[i] LT 30 then resol = 0.1 $
  else                            resol = 0.025

  filelist = findfile(path+lg_fname[i])
  interval = lg_cfrequ[i]*[1-resol, 1+resol]

  blo_linestrength, interval,  /overwrite, $
  			 /goodpix, filelist=filelist, /noplot
  ;c=get_kbrd(1)
endfor

end
