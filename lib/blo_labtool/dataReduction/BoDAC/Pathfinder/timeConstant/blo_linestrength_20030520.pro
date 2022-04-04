; derive linestrength files from fourier spectra of chopped observations

pro blo_linestrength_20030520

path = '/data1/BoDAC/3_Pathfinder/20030520/'

logfname = path+'20030520_log.txt'
readfmt, logfname, 'a23, a41, f8, f5', lg_fname, lg_txt, lg_cfrequ, lg_SR780, /silent
nf = n_elements(lg_fname)


for i=0, nf-1 do begin 

  if i LT 5 then resol = 0.1 else resol = 0.025
  filelist = findfile(path+strmid(lg_fname[i],0,13)+'*pow.fits')
  interval = lg_cfrequ[i]*[1-resol, 1+resol]

  blo_linestrength, interval,  /overwrite, $
  			  /goodpix, filelist=filelist, /noplot
  ;c=get_kbrd(1)
endfor

end
