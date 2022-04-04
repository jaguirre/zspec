pro bolo_optimum_bias_20040926

  ;input  path
  path = '/data1/SPIRE_PFM_PMW2/20040926/SvsBias/'
 
  ;Frequency file name
  ;20040926_opt_frequ.txt is prepared by looking at the spectrum by blo_labtool
  logfname = path + '20040926_SvsBias_frequ.txt'

  ;get optimum bias and performance and the plots

  !p.multi=[0,4,6]
  psinit, /letter, /full, /color

  blo_opt_bias_performance, logfname, pixeln, optBias, fitPeakBias,path=path, $
  	/plot , fintvl=[-0.022,-0.005] ;fintvl=[0.010,0.030]
  !p.multi=0
  psterm, file=path+'blo_optperf_20040926.ps'

  openw, un,  path+'blo_optperf_20040926.txt', /get_lun
  printf, un, 'Optical Performance '+systime()
  printf, un, 'Bias with Maximum Signal'
  printf, un, 'pixel', 'max', 'fitmax', form='(a12,x,a13,x,a13)'
  printf, un, '', '[V]', '[V]', form='(a12,x,a13,x,a13)'
  printf, un, '----------------------------------------'

  npix=n_elements(optBias)
  
  for ipix = 0, npix-1 do begin

   printf, un, pixeln[ipix], optBias[ipix], fitpeakBias[ipix], form='(a12,x,e13.6,x,e13.6)'

  endfor

  free_lun, un

end
