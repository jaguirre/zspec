pro blo_optperf_20030720

  ;input  path
  inpath = '/data1/SPIRE_CQM/20030720/'
  ;output path
  outpath='/home/zhang/work/noise_analysis/optimumBias/'

  ;Frequency file name
  ;20030720_opt_frequ.txt is prepared by looking at the spectrum by blo_labtool
  logfname = inpath + '20030720_opt_frequ.txt'

  ;get optimum bias and performance and the plots

  !p.multi=[0,4,6]
  psinit, /letter, /full, /color

  blo_opt_bias_performance, logfname, pixeln, optBias, fitPeakBias, /plot
  !p.multi=0
  psterm, file=outpath+'blo_optperf_20030720.ps'

  openw, un,  outpath+'blo_optperf_20030720.txt', /get_lun
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
