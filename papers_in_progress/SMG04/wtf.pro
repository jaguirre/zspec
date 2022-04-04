parinfo = replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0.D,0], relstep:1}, 5)
parinfo(4).fixed = 1
parinfo(*).value = [10000, 3700, 2, 10., 0.]
x = fir_ghz_fit
y = fir_mjy_fit
s = fir_mjy_err_fit
p = mpfitfun('greybody', x, y, s, parinfo=parinfo)

ploterror,x,y,s,psy=4
oplot,x,greybody(x,p),col=2

end
