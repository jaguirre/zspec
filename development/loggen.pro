; Generrate equally spaced bins in logarithmic intervals

function loggen, r, mn, mx

t = dindgen(r * alog(mx/mn))
logi = mn * exp(t/r)

return,logi

end
