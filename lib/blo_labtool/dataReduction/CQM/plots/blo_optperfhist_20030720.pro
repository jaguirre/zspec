pro blo_optperfhist_20030720

path = '/data1/SPIRE_CQM/20030720/'

readfmt, path+'blo_optperf_20030720.txt', 'A13,f14,f13', pixname, pmax, pfit, skip=5

pixname = strtrim(pixname,2)

ix = where(pixname NE 'CHAN 3-23' and pixname NE 'CHAN 4-23')

psinit

plothist, pmax[ix], bin=0.0002, title='Optimum Bias 20030720', yrange=[0,25],$
  xstyle=3, xrange=[0.009,0.019], xtitle='Bias [V]', ytitle='number', linestyle=1, $
  charsize=1.6, thick=3, xthick=3, ythick=3
plothist, pfit[ix], bin=0.0005, /overplot, thick=4

legend, ['signal maxima','fitted maxima'], linestyle=[0,1]

psterm, file=path+'blo_optperfhist_20030720.ps'
end
