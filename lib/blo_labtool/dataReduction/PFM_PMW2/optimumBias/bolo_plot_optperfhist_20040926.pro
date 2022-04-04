pro bolo_plot_optperfhist_20040926

path = '/data1/SPIRE_PFM_PMW2/20040926/SvsBias/'

readfmt, path+'blo_optperf_20040926.txt', 'A13,f14,f13', pixname, pmax, pfit, skip=5

pixname = strtrim(pixname,2)

ix = where(pixname NE 'T1' and pixname NE 'T2')

psinit

plothist, abs(pmax[ix]*1000.), bin=0.5, title='Optimum Bias 20040926', yrange=[0,55],$
  xstyle=3, xrange=[13.5,19.0], xtitle='Bias [mV]', ytitle='number', linestyle=1, $
  charsize=1.6, thick=3, xthick=3, ythick=3

plothist, abs(pfit[ix]*1000.), bin=0.5, /overplot, thick=3

legend, ['fitted maxima','signal maxima'], linestyle=[0,1]

psterm, file=path+'blo_optperfhist_20040926.ps'
end
