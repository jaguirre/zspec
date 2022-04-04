; derive linestrength files from fourier spectra of chopped observations
; for optical performance measurements

pro blo_linestrength_opt_20030720

path = '/data1/SPIRE_CQM/20030720/'

logfname = path+'20030720_opt_frequ.txt'
readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent


nf = n_elements(lg_fname)

resol = 0.2 
interval = lg_cfrequ[0]*[1-resol, 1+resol]
blo_linestrength, interval,  /overwrite, $
  			 /goodpix, filelist=path+lg_fname, /noplot

end
