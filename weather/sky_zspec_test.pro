; Simple test program for sky_zpec
pro sky_zspec_test

  readcol,!ZSPEC_PIPELINE_ROOT + '/weather/' + $
          'tau_0.5mm.txt',freq_tau,tau_array,format='(F,F)'
  plot,freqid2freq(),sky_zspec(pwv2tau(0.5)),$
       psym=10,yrange=[0,.4],xrange=[240,260]
  oplot,freq_tau,tau_array,color=2

end
