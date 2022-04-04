


path = '/data1/SPIRE_PFM_PLW/20040601/'
flist = findfile(path+'*_lc.fits')
for i=0, n_elements(flist)-1 do $
  blovisu, /noxlog, /pps, flist[i], /psauto, ndx=6, ndy=4
 
